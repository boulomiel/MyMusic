//
//  SearchSongStore.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 08/08/2024.
//

import SwiftUI
import MusicKit
import Combine
import SwiftData

@Observable
class SearchStore<Item: SearchStoreItem>: Identifiable {
    
    let id: UUID = .init()
    
    var searchInput: String
    var hasSearched: Bool = false
    var showRemoveRecentDialog: Bool = false
    var currentPage: Page
    var displayedPage: Page {
        Page.display(currentPage, canUpdate: !searchInput.isEmpty, for: serviceRequestConfig.offset)
    }
    
    private var serviceRequestConfig: MusicServiceAccess.Request
    private let service: MusicServiceAccess
    
    @ObservationIgnored private var isSearching = false
    @ObservationIgnored var inputPublisher: PassthroughSubject<String, Never>
    @ObservationIgnored private var searchCancellable: AnyCancellable?
    
    init(service: MusicServiceAccess = .shared, limit: Int = 25, offset: Int = 25) {
        self.service = service
        self.inputPublisher = .init()
        self.searchInput = ""
        self.serviceRequestConfig = .init(limit: limit, offset: offset)
        self.currentPage = .init()
    }
    
    func loadRecentlyViewed(with ids: [SDData], in container: ModelContainer) async {
        do {
            let result = try await service.loadRecentlyViewed(with: ids, in: container, types: Item.self)
            await handleMusicSearchResult(result)
        } catch {
            print(#function, error)
        }
    }
    
    private func search(for input: String, with container: ModelContainer) async {
        do {
            let result = try await service.search(for: input, config: serviceRequestConfig, with: container, types: Item.self)
            await handleMusicSearchResult(result)
        } catch {
            print("\(#function), \(error)")
        }
    }
    
    private func handleMusicSearchResult(_ result: MusicServiceSearchResult) async {
        let (songs, artists, albums) = result
        if let songs {
            await self.updatePage(songs)
        }
        else if let artists {
            await self.updatePage(artists)
        }
        else if let albums {
            await self.updatePage(albums)
        }
    }
    
    @MainActor
    private func updatePage<MusicItemType>(_ collection: MusicItemCollection<MusicItemType>) async where MusicItemType: MusicItem {
        if collection.count >= serviceRequestConfig.baseOffset-1 {
            serviceRequestConfig.offset += serviceRequestConfig.baseOffset
        }
        self.currentPage.update(collection)
    }
    
    @MainActor
    func cleanPage() {
        currentPage.clean()
    }
    
    func onRefreshFromBottom(with container: ModelContainer) async {
        guard !searchInput.isEmpty else { return }
        guard isSearching == false else { return }
        isSearching = true
        await search(for: searchInput, with: container)
        self.isSearching = false
    }
    
    func observeInput(in container: ModelContainer) {
        searchCancellable = inputPublisher
            //.debounce(for: .seconds(0.2), scheduler: RunLoop.current)
            .filter { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink {[weak self] input in
                guard let self else { return }
                self.hasSearched = true
                self.serviceRequestConfig.offset = 0
                self.currentPage = .init()
                Task {
                    await self.search(for: String(input), with: container)
                }
            }
    }
    
    func clean() {
        serviceRequestConfig.offset = 0
        hasSearched = false
        searchInput = ""
        searchCancellable?.cancel()
    }
}

class SongSearchStore: SearchStore<Song> { }
class AlbumSearchStore: SearchStore<Album> { }
class ArtistSearchStore: SearchStore<Artist> { }

