//
//  ListCell.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 09/08/2024.
//

import SwiftUI
import MusicKit

struct ListCell<MusicItemType: MusicCatalogSearchable & Decodable,SongCell: View, ArtistCell: View, AlbumCell: View>: View {
    @Environment(\.appCache) var appCache

    let cell: Page.Cell
    @Bindable var store: SearchStore<MusicItemType>
    
    var songCell : (Song) -> SongCell
    var artistCell : (Artist) -> ArtistCell
    var albumCell : (Album) -> AlbumCell
    
    init(cell: Page.Cell,
         store: SearchStore<MusicItemType>,
         @ViewBuilder songCell: @escaping (Song) -> SongCell,
         @ViewBuilder artistCell: @escaping (Artist) -> ArtistCell,
         @ViewBuilder albumCell: @escaping (Album) -> AlbumCell) {
        self.cell = cell
        self.store = store
        self.songCell = songCell
        self.artistCell = artistCell
        self.albumCell = albumCell
    }
    
    var body: some View {
        switch cell {
        case .song(let song):
            songCell(song)
                .id(cell.id)
        case .artist(let artist):
            artistCell(artist)
                .id(cell.id)
        case .album(let album):
            albumCell(album)
                .id(cell.id)
        case .hud(let id):
            RemoveRecentRow()
                .id(id)
        }
    }
    
    @ViewBuilder
    private func RemoveRecentRow() -> some View {
        if !store.hasSearched, store.currentPage.count > 0 {
            HStack {
                Text("Recent search")
                    .font(.system(size: 16).bold())
                Spacer()
                
                Button {
                    store.showRemoveRecentDialog.toggle()
                } label: {
                    Text("Delete")
                        .font(.system(size: 16).bold())
                        .foregroundStyle(.red)
                }
            }
            .padding(.vertical, 8)
            .id(cell.id)
        }
    }
}

extension ListCell where ArtistCell == EmptyView, AlbumCell == EmptyView, MusicItemType == Song {
    
    init(cell: Page.Cell,
         store: SearchStore<MusicItemType>,
         @ViewBuilder songCell: @escaping (Song) -> SongCell,
         @ViewBuilder artistCell: @escaping (Artist) -> ArtistCell = { _ in EmptyView() },
         @ViewBuilder albumCell: @escaping (Album) -> AlbumCell = { _ in EmptyView() }) {
        self.cell = cell
        self.store = store
        self.songCell = songCell
        self.artistCell = artistCell
        self.albumCell = albumCell
    }
    
}

extension ListCell where SongCell == EmptyView, AlbumCell == EmptyView, MusicItemType == Artist {
    
    init(cell: Page.Cell,
         store: SearchStore<MusicItemType>,
         @ViewBuilder artistCell: @escaping (Artist) -> ArtistCell,
         @ViewBuilder songCell: @escaping (Song) -> SongCell = { _ in EmptyView() },
         @ViewBuilder albumCell: @escaping (Album) -> AlbumCell = { _ in EmptyView() }) {
        self.cell = cell
        self.store = store
        self.songCell = songCell
        self.artistCell = artistCell
        self.albumCell = albumCell
    }
    
}

extension ListCell where SongCell == EmptyView, ArtistCell == EmptyView, MusicItemType == Album {
    
    init(cell: Page.Cell,
         store: SearchStore<MusicItemType>,
         @ViewBuilder albumCell: @escaping (Album) -> AlbumCell = { _ in EmptyView() },
         @ViewBuilder artistCell: @escaping (Artist) -> ArtistCell = { _ in EmptyView() },
         @ViewBuilder songCell: @escaping (Song) -> SongCell = { _ in EmptyView() } ) {
        self.cell = cell
        self.store = store
        self.songCell = songCell
        self.artistCell = artistCell
        self.albumCell = albumCell
    }
}

extension ListCell where SongCell == EmptyView, ArtistCell == EmptyView, MusicItemType == Artist {
    
    init(cell: Page.Cell,
         store: SearchStore<MusicItemType>,
         @ViewBuilder albumCell: @escaping (Album) -> AlbumCell = { _ in EmptyView() },
         @ViewBuilder artistCell: @escaping (Artist) -> ArtistCell = { _ in EmptyView() },
         @ViewBuilder songCell: @escaping (Song) -> SongCell = { _ in EmptyView() } ) {
        self.cell = cell
        self.store = store
        self.songCell = songCell
        self.artistCell = artistCell
        self.albumCell = albumCell
    }
}

