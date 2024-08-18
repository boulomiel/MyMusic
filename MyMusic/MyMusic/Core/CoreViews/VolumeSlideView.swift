//
//  VolumeSlideView.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 13/08/2024.
//

import SwiftUI
import MediaPlayer
import AVFoundation

struct VolumeSlideView: View {
    
    var height: CGFloat = 20
    @State private var scaleEffect: Double = 1.0
    
    var body: some View {
        GeometryReader {
            let frame = $0.frame(in: .local)
            VolumeSliderViewRepresentable(frame: frame) {
                withAnimation(.bouncy) {
                    scaleEffect = 2.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.bouncy) {
                        scaleEffect = 1.0
                    }
                }
            }
            .tint(scaleEffect > 1 ? .white : .white.opacity(0.6))
            .scaleEffect(y: scaleEffect)
        }
        .frame(height: height)
        
    }
}

struct VolumeSliderViewRepresentable: UIViewRepresentable {
    
    let frame: CGRect
    let onPan: () -> Void
    
    func makeUIView(context: Context) -> MPVolumeView {
        let v: MPVolumeView =  .init(frame: frame)
        v.setVolumeThumbImage(UIImage(), for: .normal)
        v.volumeThumbRect(forBounds: frame, volumeSliderRect: frame, value: 0)
        context.coordinator.listenVolumeButton()
        return v
    }
    
    func updateUIView(_ uiView: MPVolumeView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        .init(parent: self, onPan: onPan)
    }
    
    class Coordinator: NSObject {
        
        private let session = AVAudioSession.sharedInstance()
        private let onPan: () -> Void
        private let key: String = "outputVolume"
        private var observer : NSKeyValueObservation?
        
        init(parent: VolumeSliderViewRepresentable, onPan: @escaping () -> Void) {
            self.onPan = onPan
        }
        
        func listenVolumeButton() {
            do {
               // try session.setActive(true)
                session.addObserver(self, forKeyPath: key, options: NSKeyValueObservingOptions.new, context: nil)
            } catch let error as NSError{
                print(#function, error.code, error.domain, error.localizedDescription)
            }
        }
        
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "outputVolume" {
                onPan()
            }
        }
        
        deinit {
            AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: key)
        }
    }
    
    typealias UIViewType = MPVolumeView
}


#Preview {
    VolumeSlideView(height: 40)
        .preferredColorScheme(.dark)
}
