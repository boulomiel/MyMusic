//
//  MusicServiceAccess.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 06/08/2024.
//

import MusicKit
import StoreKit
import SwiftData

struct MusicServiceMeta {
    var authorizationStatus: MusicAuthorization.Status = .notDetermined
    var subscriptionsStatus: MusicSubscription?
}

typealias MusicServiceSearchResult =  (MusicItemCollection<Song>?, MusicItemCollection<Artist>?, MusicItemCollection<Album>?)
typealias SearchStoreItem = MusicCatalogSearchable & Decodable

actor MusicServiceAccess {
    
    private var meta: MusicServiceMeta
    
    var isAuthorized: Bool {
        meta.authorizationStatus == .authorized
    }
    
    var isSubscribed: Bool {
        meta.subscriptionsStatus?.canPlayCatalogContent ?? false
    }
    
    public static let shared: MusicServiceAccess = .init()
    
    private init(meta: MusicServiceMeta = .init()) {
        self.meta = meta
    }
    
    func requestAuthorization() async {        
        let result = await MusicAuthorization.request()
        meta.authorizationStatus = result
    }
    
    func checkSubscription() async throws {
        meta.subscriptionsStatus = try await MusicSubscription.current
    }
}

extension MusicServiceAccess {
    func search<MusicItemType: MusicCatalogSearchable>(for input: String, config: Request, with container: ModelContainer, types: MusicItemType.Type...) async throws -> MusicServiceSearchResult {
        var request = MusicCatalogSearchRequest(term: input, types: types)
        request.limit = config.limit
        request.offset = config.offset
        let response = try await request.response()
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                if !response.songs.isEmpty {
                    await self.updateRecentIds(response.songs, for: .song, in: container)
                }
            }
            group.addTask {
                if !response.albums.isEmpty {
                    await self.updateRecentIds(response.albums, for: .album, in: container)
                }
            }
            group.addTask {
                if !response.artists.isEmpty {
                    await self.updateRecentIds(response.artists, for: .artist, in: container)
                }
            }
        }
        let searchs = SearchResult.init(songs: response.songs, albums: response.albums, artists: response.artists)
        return searchs.result
    }
}

extension MusicServiceAccess {
    func loadRecentlyViewed<MusicItemType: MusicCatalogSearchable & Decodable>(with ids: [SDData], in container: ModelContainer, types: MusicItemType.Type...) async throws -> MusicServiceSearchResult {
        let artistRecentIds = ids.filter { $0.typeValue == .artist }.compactMap { MusicItemID($0.itemID) }
        let songRecentIds = ids.filter { $0.typeValue == .song }.compactMap { MusicItemID($0.itemID) }
        let albumRecentIds = ids.filter { $0.typeValue == .album }.compactMap { MusicItemID($0.itemID) }
        let requests: [(any WrapperProtocol)?] = types.map { type in
            if type is Song.Type {
                return songRecentIds.isEmpty ? nil : Wrapper(value: MusicCatalogResourceRequest<Song>(matching: \.id, memberOf: songRecentIds))
            }
            else if type is Artist.Type {
                return artistRecentIds.isEmpty ? nil : Wrapper(value: MusicCatalogResourceRequest<Artist>(matching: \.id, memberOf: artistRecentIds))
            }
            else {
                return albumRecentIds.isEmpty ? nil : Wrapper(value: MusicCatalogResourceRequest<Album>(matching: \.id, memberOf: albumRecentIds))
            }
        }
        
        let searchResults = await withThrowingTaskGroup(of: Void.self) { group in
            let searchResult: SearchResult = .init()
            requests.forEach { wrapper in
                if let songRequest = (wrapper?.value as? MusicCatalogResourceRequest<Song>) {
                    group.addTask {
                        let songs = try await songRequest.response()
                        searchResult.addSongs(songs: songs.items)
                    }
                }
                else if let artistsRequests = (wrapper?.value as? MusicCatalogResourceRequest<Artist>) {
                    group.addTask {
                        let artists = try await artistsRequests.response()
                        searchResult.addArtists(artists: artists.items)
                    }
                }
                else if let albumRequests = (wrapper?.value as? MusicCatalogResourceRequest<Album>) {
                    group.addTask {
                        let albums = try await albumRequests.response()
                        searchResult.addAlbums(albums: albums.items)
                    }
                }
            }
            return searchResult
        }
        return searchResults.result
    }
}

extension MusicServiceAccess {
    
    @MainActor
    private func updateRecentIds<MusicItemType: MusicItem>(_ collections: MusicItemCollection<MusicItemType>, for type: SDDataType, in container: ModelContainer) {
        let sdData = collections.map { SDData(itemID: $0.id.rawValue, type: type) }
        let moc = container.mainContext
        let v = type.rawValue
        do {
            try moc.delete(model: SDData.self,
                           where: #Predicate { d in
                d.type == v
            })
        } catch {
            print(#function, error.localizedDescription)
        }
        sdData.forEach { data in
            moc.insert(data)
        }
        do {
            try moc.save()
        } catch {
            print(#function, error.localizedDescription)
        }
    }
}

extension MusicServiceAccess {
    class SearchResult {
        private var _songs: MusicItemCollection<Song>
        private var songs: MusicItemCollection<Song>? {
            return if _songs.isEmpty {
                nil
            } else {
                _songs
            }
        }
        private var _albums: MusicItemCollection<Album>
        private var albums: MusicItemCollection<Album>? {
            return if _albums.isEmpty {
                nil
            } else {
                _albums
            }
        }
        
        private var _artists: MusicItemCollection<Artist>
        private var artists: MusicItemCollection<Artist>? {
            return if _artists.isEmpty {
                nil
            } else {
                _artists
            }
        }
        
        var result: MusicServiceSearchResult {
            (songs, artists, albums)
        }
        
        fileprivate init(songs: MusicItemCollection<Song>, albums: MusicItemCollection<Album>, artists: MusicItemCollection<Artist>) {
            self._songs = songs
            self._albums = albums
            self._artists = artists
        }
        
        fileprivate init() {
            self._songs = .init()
            self._albums = .init()
            self._artists = .init()
        }
        
        func addSongs(songs: MusicItemCollection<Song>) {
            self._songs = songs
        }
        
        func addAlbums(albums: MusicItemCollection<Album>) {
            self._albums = albums
        }
        
        func addArtists(artists: MusicItemCollection<Artist>) {
            self._artists = artists
        }
    }
    
    struct Request {
        var limit: Int
        var offset: Int
        var baseOffset: Int
        
        init(limit: Int, offset: Int) {
            self.limit = limit
            self.offset = offset
            self.baseOffset = offset
        }
    }
}
