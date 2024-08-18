//
//  PlayerButtonView.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 08/08/2024.
//
import SwiftUI

struct PlayerButtonView: View {
    
    @Environment(\.musicStore) var musicStore
    @Environment(\.musicPlayer) var musicPlayer
    
    @State private var isPlaying: Bool = false
    var height: CGFloat = 20
    var color: Color = .white
    var onPlay: (Bool) -> Void
    
    private let playName: String = "play.fill"
    private let pauseName: String = "pause.fill"
    
    var body: some View {
        Button {
            Task {
                await handlePlayButton()
                onPlay(musicPlayer.isPlaying)
            }
        } label: {
            if isPlaying {
                Image(systemName: pauseName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .symbolEffect(.bounce ,value: isPlaying)
                    .frame(width: height, height: height)
                    .foregroundStyle(color)
                    .transition(.scale)
            } else {
                Image(systemName: playName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .symbolEffect(.bounce ,value: isPlaying)
                    .frame(width: height, height: height)
                    .foregroundStyle(color)
                    .transition(.scale)
            }
        }
        .padding(height / 2)
        .background {
            KeyframeAnimator(initialValue: Anim.init(), trigger: isPlaying) { v in
                Circle()
                    .fill(Color.white.opacity(v.opacity))

            } keyframes: { v in
                KeyframeTrack(\.opacity) {
                    CubicKeyframe(0.2, duration: 0.2)
                    SpringKeyframe(0)
                }
            }
        }
        .onChange(of: musicPlayer.isPlaying, { oldValue, newValue in
            withAnimation(.bouncy) {
                self.isPlaying = newValue
            }
        })
        .onAppear {
            self.isPlaying = musicPlayer.isPlaying
        }
    }
    
    struct Anim {
        var opacity: CGFloat = 0.0
        var scale: CGFloat = 0.0
    }
    
    func handlePlayButton() async {
        switch musicPlayer.status {
        case .stopped:
            if let song = musicStore.song {
                await musicPlayer.playNew(song: song)
            }
        case .playing:
            musicPlayer.pause()
        case .paused:
            await musicPlayer.resume()
        case .interrupted:
            await musicPlayer.resume()
        case .seekingForward:
            break
        case .seekingBackward:
            break
        @unknown default:
            break
        }
    }
}

#Preview {
    
    PlayerButtonView(height: 20, color: .white, onPlay: { _ in
        
    })
    .preferredColorScheme(.dark)
}
