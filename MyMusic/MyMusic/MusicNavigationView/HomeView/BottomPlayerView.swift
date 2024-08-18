//
//  BottomPlayerView.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 08/08/2024.
//

import SwiftUI

struct BottomPlayerView: View {
    
    @Environment(\.musicStore) var musicStore
    @Environment(\.musicPlayer) var musicPlayer
    var bottomNameSpace: Namespace.ID
    var onOpen: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            AsyncImage(url: musicStore.imageURL) { image in
                image
                    .resizable()
                    .frame(width: size.height * 0.8, height: size.height * 0.8)
                    .aspectRatio(contentMode: .fit)
                    .padding(2)
                    .overlay(content: {
                        Rectangle()
                            .stroke(lineWidth: 1)
                            .foregroundStyle(musicStore.background)
                        
                    })
                    .position(x: size.width * 0.1, y: size.height * 0.5)
                    .gesture(TapGesture()
                        .onEnded({ _ in
                            onOpen()
                            
                        }), including: .all)
            } placeholder: {
                Rectangle()
                    .fill(musicStore.mesh)
                    .frame(width: size.height * 0.8, height: size.height * 0.8)
                    .overlay(content: {
                        Rectangle()
                            .stroke(lineWidth: 1)
                    })
                    .frame(width: size.width * 0.4, height: size.height * 0.8)
                    .position(x: size.width * 0.1, y: size.height * 0.5)
            }
            
            Text(musicStore.title)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: size.width * 0.5, alignment: .leading)
                .position(x: size.width * 0.45,  y: size.height * 0.5)
            
            PlayerButtonView() { isPlaying in }
                .position(x: size.width * 0.75, y: size.height * 0.5)
            
            NextSongButtonView(scale: 0.4) {
                
            }
            .position(x: size.width * 0.85, y: size.height * 0.5)
            
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        }
        .frame(height: 55)
        .appears(if: musicStore.isSongBuffered, with: .slide, and: .smooth)
        .matchedTransitionSource(id: musicStore.song?.id, in: bottomNameSpace)
        .gesture(TapGesture()
            .onEnded({ _ in
                onOpen()
                
            }), including: .all)
    }
}

#Preview {
    @Previewable var musicStore: MusicStore = .init()
    @Previewable @Namespace var namespace
    
    BottomPlayerView(bottomNameSpace: namespace){
        
    }
    .preferredColorScheme(.dark)
    .environment(musicStore)
    .onAppear {
        // musicStore.set(1)
    }
}
