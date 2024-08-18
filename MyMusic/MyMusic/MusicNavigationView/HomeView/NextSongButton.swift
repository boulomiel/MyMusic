//
//  NextSongButton.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 08/08/2024.
//

import SwiftUI

struct NextSongButtonView: View {
    
    var height: CGFloat = 40
    var scale: Double = 1.0
    var onNext: () -> Void
    var color: Color = .white
    @State private var toggle: Bool = false
    
    var body: some View {
        Button {
            toggle.toggle()
            onNext()
        } label: {
            if toggle {
                canvas
                    .transition(.scale)
            } else {
                canvas
                    .transition(.scale)
            }
        }
        .scaleEffect(scale)
        .padding(height / 2)
        .background {
            KeyframeAnimator(initialValue: Anim.init(), trigger: toggle) { v in
                Circle()
                    .fill(Color.white.opacity(v.opacity))
                    .scaleEffect(scale)


            } keyframes: { v in
                KeyframeTrack(\.opacity) {
                    CubicKeyframe(0.2, duration: 0.2)
                    SpringKeyframe(0)
                }
            }

        }
    }
    
    @ViewBuilder
    var canvas: some View {
        let image1 = Image(systemName: "play.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: height)
            .foregroundStyle(.white)
        
        let image2 = Image(systemName: "play.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: height)
            .foregroundStyle(.white)
            .padding(.leading, 30)
        
        Canvas { context, size in
           // let ratio = height / size.width
           // print(ratio)
            if let image1 = context.resolveSymbol(id: 1),
               let image2 = context.resolveSymbol(id: 2) {
                let p1 = CGPoint(x: size.width * 0.1, y: size.height/2)
                context.draw(image1, at: p1, anchor: .leading)
                let p2 = CGPoint(x: size.width * 0.2 - size.width * 0.1, y: size.height/2)
                context.draw(image2, at: p2, anchor: .leading)
                
            }
        } symbols: {
            image1
                .tag(1)
            
            image2
                .tag(2)
        }
        .frame(width: height * 2, height: height)
    }
    
    
    struct Anim {
        var opacity: CGFloat = 0.0
        var scale: CGFloat = 0.0
    }
}

#Preview {
    NextSongButtonView(scale: 0.4 ,onNext: {
        
    }, color: .white)
    .preferredColorScheme(.dark)
}
