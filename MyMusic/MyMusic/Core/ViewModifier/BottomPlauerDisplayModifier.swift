//
//  BottomPlauerDisplayModifier.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 08/08/2024.
//

import SwiftUI

struct BottomPlayerDisplayModifier: ViewModifier {
    @Environment(\.musicStore) var store
    @Environment(\.musicPlayer) var musicPlayer
    @Environment(Router.self) var router

    var bottomNameSpace: Namespace.ID
    @State private  var showPlayingSheet: Bool = false
    
    func body(content: Content) -> some View {
        content
            .onReceive(store.showBottomPlayerEvent, perform: { event in
                switch event {
                case .hidden: break
                case .shown: router.toPlayerViewFromBottom(store.song)
                }
            })
            .overlay(alignment: .bottom) {
                BottomPlayerView(bottomNameSpace: bottomNameSpace) {
                    store.showBottomPlayerEvent.send(.shown)
                }
                .padding(.bottom, 44)
            }
    }
}

extension View {
    func bottomPlayerDisplayer(bottomNameSpace: Namespace.ID) -> some View {
        modifier(BottomPlayerDisplayModifier(bottomNameSpace: bottomNameSpace))
    }
}

#Preview {
    @Previewable var musicStore: MusicStore = .init()
    @Previewable @Namespace var namespace

    Rectangle()
        .fill(Color.red)
        .bottomPlayerDisplayer(bottomNameSpace: namespace)
        .environment(musicStore)
        .ignoresSafeArea()
        .onAppear {
            //musicStore.set("Hello")
        }
}
