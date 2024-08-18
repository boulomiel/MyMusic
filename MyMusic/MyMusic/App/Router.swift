//
//  Router.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 14/08/2024.
//

import MusicKit
import SwiftUI

@Observable
class Router {
    
    struct MusicNavigation: Hashable {}
    
    struct SongNavigation: Hashable {
        let song: Song
    }
    
    struct SongNavigationBottomView: Hashable, Identifiable {
        var id: MusicItemID {
            song.id
            
        }
        let song: Song
    }

    var path: NavigationPath = .init()
    var playerSheet: SongNavigationBottomView?
    
    func toMusicNavigationViewFromLogin() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: .init(block: {
            self.path.append(MusicNavigation())
        }))
    }
    
    func toPlayerView(_ song: Song?) {
        guard let song else { return }
        self.path.append(SongNavigation(song: song))
    }
    
    func toPlayerViewFromBottom(_ song: Song?) {
        guard let song else { return }
        self.playerSheet = .init(song: song)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        self.path.removeLast()
    }
}
