//
//  MusicNavigationView.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 06/08/2024.
//

import SwiftUI
import MusicKit

struct MusicNavigationView: View {
    
    @Environment(\.musicStore) var store
    let songStore = SongSearchStore()
    let albumStore = AlbumSearchStore()
    let artistStore = ArtistSearchStore(limit: 12, offset: 12)
    var listNameSpace: Namespace.ID
    var bottomNameSpace: Namespace.ID

    var body: some View {
        TabView {
            Group {
                SearchSongListView(store: songStore, matchingNameSpace: listNameSpace)
                    .tabItem {
                        Label("Songs", systemImage: "music.note.list")
                        
                    }
                SearchAlbumView(store: albumStore)
                    .tabItem {
                        Label("Albums", systemImage: "opticaldisc")
                    }
                
                SearchArtistView(store: artistStore)
                    .tabItem {
                        Label("Artists", systemImage: "guitars")
                    }
            }
            .tint(.red)
            .toolbarBackground(.black, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        }
        .bottomPlayerDisplayer(bottomNameSpace: bottomNameSpace)
    }
}


#Preview {
    @Previewable @Namespace var space
    @Previewable @Namespace var bottom

    NavigationStack {
        MusicNavigationView(listNameSpace: space, bottomNameSpace: bottom)
    }
    .preferredColorScheme(.dark)
    .environment(MusicStore.init())
}
