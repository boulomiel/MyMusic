//
//  TitleActionView.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 15/08/2024.
//

import SwiftUI

struct TitleActionView: View {
    
    let title: String
    let artist: String
    var onFavoriteClicked: () -> Void
    var onMoreClicked: () -> Void

    
    var body: some View {
        HStack {
            TitleView()
            ActionView()
        }
        .padding(.top, 40)
        .padding(.horizontal, 12)
    }
    
    func TitleView() -> some View {
        VStack(spacing: 4) {
            Group {
                Text(title)
                    .font(.system(size: 16).bold())
                    .foregroundStyle(.white)
                    
                Text(artist)
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .frame(maxWidth: 300, alignment: .leading)
        }
    }
    
    func ActionView() -> some View {
        HStack(spacing: 12) {
            Group {
                Button {
                    onFavoriteClicked()
                } label: {
                    Image(systemName: "star")
                        .resizable()
                        .scaledToFit()
                }

                
                Button {
                    onMoreClicked()
                } label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(width: 16, height: 16)
            .padding(4)
            .background(Circle().fill(Color.white.opacity(0.2)))
            .foregroundStyle(.white)
        }
    }
}
