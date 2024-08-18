//
//  ContentView.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 06/08/2024.
//

import SwiftUI
import MusicKit

struct ContentView: View {
    
    @Environment(\.appState) var appState
    @Environment(\.musicPlayer) var musicPlayer
    @Environment(\.musicStore) var musicStore

    @State var router: Router = .init()
    @Namespace var loginNameSpace
    @Namespace var playerNameSpace
    @Namespace var bottomPlayerNameSpace
    let loginManager: LoginManager = .init()
    
    var body: some View {
        if appState.isLoggedIn {
            musicNavigationStack
                .transition(.scale)
                .environment(router)
        } else {
            loadingView
        }
    }
    
    var loadingView: some View  {
        LoginView(matchingNameSpace: loginNameSpace)
            .environment(loginManager)
            .onReceive(loginManager.successEvent) { _ in
                withAnimation(.smooth) {
                    appState.isLoggedIn = true
                }
            }
    }
    
    var musicNavigationStack: some View {
        NavigationStack(path: $router.path) {
            MusicNavigationView(listNameSpace: playerNameSpace, bottomNameSpace: bottomPlayerNameSpace)
                .navigationDestination(for: Router.SongNavigation.self) { nav in
                    PlayingView(obs: .init(song: nav.song, musicPlayer: musicPlayer))
                        .navigationBarBackButtonHidden()
                        .navigationTransition(.zoom(sourceID: nav.song.id, in: playerNameSpace))
                }
                .fullScreenCover(item: $router.playerSheet) { nav in
                    PlayingView(obs: .init(song: nav.song, musicPlayer: musicPlayer))
                        .navigationTransition(.zoom(sourceID: nav.song.id, in:  bottomPlayerNameSpace))
                }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
