//
//  Page.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 08/08/2024.
//
import MusicKit
import Foundation

struct Page: Identifiable {
    let id: UUID = .init()
    
    var songCells: [Cell]
    var albumCell: [Cell]
    var artistsCell: [Cell]
    
    init() {
        self.songCells = [.hud(.init())]
        self.albumCell = [.hud(.init())]
        self.artistsCell = [.hud(.init())]
    }
    
    var count: Int {
        artistsCell.count + songCells.count + albumCell.count
    }
    
    var lastID: MusicItemID? {
        if case let .song(value) = songCells.last {
            return value.id
        }
        else if case let .artist(value) = artistsCell.last {
            return value.id
        }
        else if case let .album(value) = albumCell.last {
            return value.id
        }
        return nil
    }
    
    var firstID: MusicItemID? {
        if case let .song(value) = songCells.second {
            return value.id
        }
        else if case let .artist(value) = artistsCell.second {
            return value.id
        }
        else if case let .album(value) = albumCell.second {
            return value.id
        }
        return nil
    }
    
    var ids: [MusicItemID] {
        if !artistsCell.isEmpty {
            artistsCell.compactMap(\.id)
        }
        else if !albumCell.isEmpty {
            albumCell.compactMap(\.id)
        }
        else {
            songCells.compactMap(\.id)
        }
    }
    
    static func display(_ currentPage: Page, canUpdate: Bool, for offset: Int) -> Page {

        func handle(_ items: inout [Page.Cell], canUpdate: Bool, for offset: Int) {
            let maxIndex = min(offset, items.count)
            let sliced = Array(items[0..<maxIndex])
            if canUpdate && !sliced.isEmpty {
                items = sliced
            }
        }
         
        var c = currentPage
        if currentPage.songCells.count > 1 {
            handle(&c.songCells, canUpdate: canUpdate, for: offset)
        } else if currentPage.artistsCell.count > 1 {
            handle(&c.artistsCell, canUpdate: canUpdate, for: offset)
        } else {
            handle(&c.albumCell, canUpdate: canUpdate, for: offset)
        }
        return c
    }
    
    @MainActor
    mutating func update<MusicItemType>(_ collection: MusicItemCollection<MusicItemType>) where MusicItemType: MusicItem {
        updateAlbumCells(collection)
        updateArtistCells(collection)
        updateSongCells(collection)
    }
    
    @MainActor
    mutating func clean() {
        self.artistsCell = .init()
        self.albumCell = .init()
        self.songCells = .init()
    }
    
    private mutating func updateSongCells<MusicItemType>(_ collection: MusicItemCollection<MusicItemType>) where MusicItemType: MusicItem {
        if let songs = collection as? MusicItemCollection<Song> {
            let current = songCells.compactMap {
                if case let .song(value) = $0 {
                    return value
                }
                return nil
            }

            let filtered = songs.filter { song in
                !current.contains { $0.id == song.id }
            }
            let cells: [Cell] = filtered.map { .song($0) }
            self.songCells += cells
        }
    }
    
    private mutating func updateAlbumCells<MusicItemType>(_ collection: MusicItemCollection<MusicItemType>) where MusicItemType: MusicItem {
        if let albums = collection as? MusicItemCollection<Album> {
            let current = albumCell.compactMap {
                if case let .album(value) = $0 {
                    return value
                }
                return nil
            }

            let filtered = albums.filter { album in
                !current.contains(album)
            }
            
            let cells: [Cell] = filtered.map { .album($0) }
            self.albumCell += cells
        }
    }
    
    private mutating func updateArtistCells<MusicItemType>(_ collection: MusicItemCollection<MusicItemType>) where MusicItemType: MusicItem {
        if let artist = collection as? MusicItemCollection<Artist> {
            let current = artistsCell.compactMap {
                if case let .artist(value) = $0 {
                    return value
                }
                return nil
            }

            let filtered = artist.filter { artist in
                !current.contains(artist)
            }
            let cells: [Cell] = filtered.map { .artist($0) }
            self.artistsCell += cells
        }
    }
    
    enum Cell: Identifiable {
        
        var id: MusicItemID {
            switch self {
            case .song(let song):
                song.id
            case .artist(let artist):
                artist.id
            case .album(let album):
                album.id
            case .hud(let id):
                .init(id.uuidString)
            }
        }
        
        var value: Any? {
            switch self {
            case .song(let song):
                return song
            case .artist(let artist):
                return artist
            case .album(let album):
                return album
            case .hud:
                return nil
            }
        }
        
        static var removeRowID: UUID = .init()

        
        case song(Song)
        case artist(Artist)
        case album(Album)
        case hud(UUID)
    }
}


extension Array {
    
    func chunked(of size: Int) -> [[Element]] {
        guard size < count else {
            return []
        }
        let chunks = self.count / size
        var results: [[Element]] = []
        for _ in stride(from: 0, to: chunks-1, by: 1) {
            results.append(.init())
        }
        var index = 0
        let c = self.reduce(into: results) { partialResult, cell in
            guard let count = partialResult[safe: index]?.count else {
                return
            }
            if count < size {
                partialResult[index].append(cell)
            } else {
                index += 1
            }
        }
        return c
    }
}
