//
//  MusicPlayer.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 13/08/2024.
//

import SwiftUI
import MusicKit
import Combine

@Observable
class AppMusicPlayer {
    
    private let musicPlayer = SystemMusicPlayer.shared
    private var subscriptions: Set<AnyCancellable> = .init()
    
    var playbackTime: TimeInterval {
        musicPlayer.playbackTime
    }
    
    var status: MusicPlayer.PlaybackStatus = .stopped
    
    var isPlaying: Bool {
        status == .playing
    }
    
    init() {
        observePlayerState()
    }
    
    func playNew(song: Song) async {
        do {
            try await musicPlayer.prepareToPlay()
        } catch let error as NSError {
            print(#function,"prepareToPlay" ,error.code, error.domain, error.localizedDescription )
        }
        do {
            try await musicPlayer.queue.insert(song, position: .afterCurrentEntry)
            try await musicPlayer.skipToNextEntry()
            try await musicPlayer.play()
        } catch let error as NSError {
            print(#function, error.code, error.domain, error.localizedDescription)
        }
    }
    
    func resume() async {
        do {
            try await musicPlayer.play()
        } catch let error as NSError {
            print(#function, error.code, error.domain, error.localizedDescription)
        }
    }
    
    func move(to progress: Double, in duration: Double) {
        self.musicPlayer.playbackTime = duration * progress
    }
    
    func observePlayerState() {
        musicPlayer.state.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.status = self.musicPlayer.state.playbackStatus
            }
            .store(in: &subscriptions)
    }
}

extension AppMusicPlayer {
    
    func pause() {
        musicPlayer.pause()
    }
    
    func stop() {
        musicPlayer.stop()
    }
    
    func next() {
        Task {
            do {
                try await musicPlayer.skipToNextEntry()
            } catch {
                print(error)
            }
        }
    }
    
    func previous() {
        Task {
            do {
                try await musicPlayer.skipToPreviousEntry()
            } catch {
                print(error)
            }
        }
    }
}

extension EnvironmentValues {
    
    @Entry var musicPlayer: AppMusicPlayer = .init()
    
}
