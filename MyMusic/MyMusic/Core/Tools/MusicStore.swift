//
//  MusicStore.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 08/08/2024.
//

import SwiftUI
import Combine
import MusicKit

@Observable
class MusicStore: SongDetailsProtocol {
    
    enum BottomPlayerState {
        case shown
        case hidden
    }
    
    let showBottomPlayerEvent: PassthroughSubject<BottomPlayerState, Never>
    var isSongBuffered: Bool {
        song != nil 
    }
    private(set) var song: Song?
    private let musicService: MusicServiceAccess
    
    init(musicService: MusicServiceAccess = .shared) {
        self.musicService = musicService
        self.showBottomPlayerEvent = .init()
    }
    
    func set(_ song: Song) {
        self.song = song
    }
}

extension EnvironmentValues {
    @Entry var musicStore: MusicStore = .init()
}
