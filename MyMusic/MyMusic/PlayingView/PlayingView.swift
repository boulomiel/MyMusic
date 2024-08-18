//
//  PlayingView.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 13/08/2024.
//

import SwiftUI
import MusicKit
import AVFoundation
import MediaPlayer
import Combine

struct PlayingView: View {
    
    @State var obs: Obs
    @State var imageScaleFactor: Double = 1.6
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(obs.mesh)
                .ignoresSafeArea()
            
            VStack {
                
                CloseTopButtonView()
                
                Spacer()
                                
                AsyncImage(url: obs.imageURL)
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .scaleEffect(imageScaleFactor)
                    .shadow(radius: 8)
                
                .padding(.top, 40)
                
                Spacer()
                
                TitleActionView(title: obs.title, artist: obs.artist) {
                    
                } onMoreClicked: {
                    
                }

                
                Spacer()
                
                SongPlayerView(obs: obs, currentProgress: obs.elapsedTime / obs.duration)
                    .padding(.top, 20)
                
                Spacer()
                
                ActionPlayerView(obs: obs, imageScaleFactor: $imageScaleFactor)
                    .padding(.top, 20)
                
                Spacer()
                
                VolumeView()
                
                Spacer()
                
            }
        }
        .onDisappear {
            obs.clean()
        }
    }
    
    @ViewBuilder
    func CloseTopButtonView() -> some View {
        let height: CGFloat = 6
        RoundedRectangle(cornerRadius: height / 2)
            .fill(Color.white.opacity(0.6))
            .frame(width:30, height: 6)
    }
    
    @Observable
    class Obs: SongDetailsProtocol {
        
        @ObservationIgnored private var cancellable: AnyCancellable?
        @ObservationIgnored private var timer: Publishers.Autoconnect<Timer.TimerPublisher>
        @ObservationIgnored private var playerEvent: CurrentValueSubject<PlayerEvent, Never>
        
        private let musicPlayer: AppMusicPlayer
        
        let song: Song?
        var elapsedTime: TimeInterval
        
        var timePlayed: String {
            let minutes: Int = Int(elapsedTime) / 60
            let seconds: Int = Int(elapsedTime) % 60
            let secondStr = seconds < 10 ? "0\(seconds)" : "\(seconds)"
            return "\(minutes):\(secondStr)"
            
        }
        
        var timeLeft: String {
            let currentTime = duration - elapsedTime
            let minutes: Int = Int(currentTime) / 60
            let seconds: Int = Int(currentTime) % 60
            let secondStr = seconds < 10 ? "0\(seconds)" : "\(seconds)"
            return "-\(minutes):\(secondStr)"
        }
        
        @MainActor var isPlaying: Bool {
            musicPlayer.isPlaying
        }
        
        init(song: Song, musicPlayer: AppMusicPlayer) {
            self.musicPlayer = musicPlayer
            self.song = song
            self.elapsedTime = musicPlayer.playbackTime
            self.timer = Timer.publish(every: 1.0, on: .main, in: RunLoop.Mode.common).autoconnect()
            self.playerEvent = .init(.play)
            self.observeDuration()
        }
        
        func move(to progress: Double) {
            musicPlayer.move(to: progress, in: duration)
        }
        
        func update(to progress: Double) {
            elapsedTime = progress * duration
        }
        
        func play() {
            Task {
                await musicPlayer.resume()
                await MainActor.run {
                    playerEvent.send(.play)
                }
            }
        }
        
        func pause() {
            musicPlayer.pause()
            playerEvent.send(.pause)
        }
        
        func previous() {
            musicPlayer.previous()
        }
        
        func next() {
            musicPlayer.next()
        }
        
        func clean() {
            cancellable?.cancel()
            cancellable = nil
        }
        
        private func observeDuration() {
            cancellable = timer
                .combineLatest(playerEvent)
                .sink { timer, event in
                    switch event {
                    case .next:
                        break
                    case .previous:
                        break
                    case .play:
                        self.elapsedTime += 1
                    case .pause:
                        break
                    }
                }
        }
        
        enum PlayerEvent {
            case next
            case previous
            case play
            case pause
        }
    }
}


#Preview {
    Rectangle()
        .fill(
            MeshGradient(width: 2, height: 2, points: [
                [0, 0], [1, 0],
                [0, 1], [1, 1]
            ], colors: [
                .indigo, .cyan,
                .purple, .pink
            ])
        )
}
