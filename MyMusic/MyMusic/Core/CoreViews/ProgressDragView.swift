//
//  ProgressDragView.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 14/08/2024.
//

import SwiftUI

struct ProgressDragView: View {
    
    var height: CGFloat = 24
    var color: Color = .white
    @Binding var currentProgress: Double
    @State private var scale: Double = 1.0
    @State private var opacity: Double = 0.6
    var onProgressChange: (Double) -> Void
    var onRelease: (Double) -> Void

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let height = size.height / 3
            Group {
                let cornerRadius = height / 2 * scale
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color.opacity(0.2))
                    .frame(height: height * scale)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color.opacity(opacity))
                    .frame(width: size.width * currentProgress, height: height * scale)
            }
            .gesture(
                dragGesture(size),
                including: .all
            )
        }
        .frame(height: height)
    }
    
    func dragGesture(_ size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged({ value in
                let x = value.location.x
                let ratioLocation = x / size.width
                onProgressChange(ratioLocation)
                self.currentProgress = ratioLocation
                withAnimation(.bouncy) {
                    self.scale = 2.0
                    self.opacity = 1.0
                }
            })
            .onEnded { value  in
                let x = value.location.x
                let ratioLocation = x / size.width
                onRelease(ratioLocation)
                withAnimation(.bouncy) {
                    self.scale = 1.0
                    self.opacity = 0.6
                }
            }
    }
}
