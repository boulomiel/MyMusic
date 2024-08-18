//
//  VolumeView.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 14/08/2024.
//

import SwiftUI

struct VolumeView: View {
    
    var body: some View {
        Content()
    }
    
    func Content() -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "speaker.fill")
                    .foregroundStyle(.white)
                    .frame(height: 10)
                    .foregroundStyle(Color.white.opacity(0.6))
        
                GeometryReader {
                    let frame = $0.frame(in: .global)
                    VolumeSlideView(height: frame.height)
                }
                .frame(height: 15)
                
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundStyle(.white)
                    .frame(height: 10)
                    .foregroundStyle(Color.white.opacity(0.6))

            }
        }
        .padding(.horizontal, 16)
    }
}
