//
//  ActionPlayerView.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 15/08/2024.
//

import SwiftUI

struct ActionPlayerView: View {
    
    @Bindable var obs: PlayingView.Obs
    @Binding var imageScaleFactor: Double
    
    var body: some View {
        Content()
    }
    
    func Content() -> some View {
        HStack {
            
            Spacer()
            
            NextSongButtonView(scale: 0.6) {
                obs.previous()
            }
            .rotationEffect(.degrees(180), anchor: .center)
            
            Spacer()
            
            
            PlayerButtonView(height: 40) { isPlaying in
                withAnimation(.bouncy) {
                    imageScaleFactor = isPlaying ? 1.6 : 1.0
                }
            }
            
            Spacer()
            
            
            NextSongButtonView(scale: 0.6) {
                obs.next()
            }
            
            Spacer()
        }
    }
}
