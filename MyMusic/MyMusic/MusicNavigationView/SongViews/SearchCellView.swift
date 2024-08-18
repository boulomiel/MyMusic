//
//  SearchCellView.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 08/08/2024.
//

import SwiftUI
import MusicKit

struct SearchCellView: View {

    let obs: CellObservable
    @State var image: Image?
        
    var body: some View {
        HStack {
            if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50, alignment: .leading)
                    .shadow(color: obs.bgColor ?? .gray.opacity(0.3), radius: 4)
                    .background(obs.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(obs.bg)
                    .frame(width: 50, height: 50, alignment: .leading)
            }
            
            VStack {
                Text(obs.title)
                    .font(.system(size: 20))
                    .bold()
                    .kerning(0.5)
                    .fontWidth(.compressed)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Text(obs.artistName)
                    .font(.system(size: 16))
                    .bold()
                    .kerning(0.5)
                    .fontWidth(.compressed)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
        }
        .frame(height: 55)
        .task {
            let image: Image = await .init(uiImage: obs.image)
            withAnimation(.smooth) {
                self.image = image
            }
        }
    }
}

