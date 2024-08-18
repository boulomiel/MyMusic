//
//  SongPlayerView.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 14/08/2024.
//

import SwiftUI

struct SongPlayerView: View {
    
    @Bindable var obs: PlayingView.Obs
    @State var currentProgress: Double = 0.0
    @State private var isTouching: Bool = false
    
    var body: some View {
        Content()
    }
    
    func Content() -> some View {
        VStack(spacing: 8) {
            ProgressDragView(currentProgress: $currentProgress) { progress in
                obs.update(to: progress)
                guard !isTouching else { return }
                toggleTouching(true)
            } onRelease: { progress in
                toggleTouching(false)
                obs.move(to: progress)
            }
            HStack {
                Group {
                    Text(obs.timePlayed)
                        .frame(maxWidth: 100, alignment: .leading)
                    Spacer()
                    Text(obs.timeLeft)
                        .frame(maxWidth: 100, alignment: .trailing)
                }
                .font(isTouching ? .body.bold() : .caption)
                .foregroundStyle(Color.white.opacity(isTouching ? 1.0 : 0.2))
            }
        }
        .padding(.horizontal, 12)
        .onChange(of: obs.elapsedTime) { _, newValue in
            currentProgress = newValue / obs.duration
        }
    }
    
    func toggleTouching(_ isTouching: Bool, with animation: Animation = .bouncy) {
        withAnimation(animation) {
            self.isTouching = isTouching
        }
    }
}
