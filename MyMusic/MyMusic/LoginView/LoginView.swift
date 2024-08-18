//
//  LoginView.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 06/08/2024.
//

import Combine
import SwiftUI

struct LoginView: View {
    
    enum ViewState {
        case loading
        case connected
        
        var image: String {
            switch self {
            case .loading:
                "arrow.triangle.2.circlepath"
            case .connected:
                "music.note"
            }
        }
    }
    
    struct Config {
        var imageName: String = ViewState.loading.image
        var state: ViewState = .loading
        var hasAppeared: Bool = false
        var rotation: Angle = .degrees(0)
        var scale: Double = 1.0
        var animation: Animation = .smooth(duration: 0.5, extraBounce: 0.2)
        var textOffset: CGFloat = -1000
        var textScale: CGFloat = 0
    }
    
    var matchingNameSpace: Namespace.ID
    
    @Environment(LoginManager.self) var loginManager
    @State var config: Config = .init()
    
    static var navigationSource: String = String(describing: Self.self)
    
    var body: some View {
        canvasContent
            .onAppear(perform: onViewAppeared)
            .onTapGesture(perform: onViewTapGesture)
            .onReceive(loginManager.successEvent, perform: { _ in
                config.state = .connected
            })
            .failableTask(handle: onViewFailableTask)
            .preferredColorScheme(config.state == .loading ? .dark : .light)
            .matchedTransitionSource(id: LoginView.navigationSource, in: matchingNameSpace)
            .onDisappear {
                withAnimation {
                    config.state = .loading
                }
            }
    }
    
    private var canvasContent: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width/2, y: size.height/2.5)
            guard let loadingSymbol = context.resolveSymbol(id: 1) else {
                return
            }
            
            context.draw(loadingSymbol, at: center, anchor: .center)
            
            guard let welcomeTextSymbol = context.resolveSymbol(id: 2) else {
                return
            }
            
            context.draw(welcomeTextSymbol, at: .init(x: size.width / 2, y: size.height * 0.8))
            
            
        } symbols: {
            loadingStateImage
                .tag(1)
            
            welcomeText
                .tag(2)
        }
    }
    
    private var welcomeText: some View {
        Text("Welcome")
            .font(.system(size: 50))
            .fontWidth(.compressed)
            .fontWeight(.bold)
            .kerning(5)
            .lineLimit(1)
            .offset(x:config.textOffset)
            .scaleEffect(config.textScale)
    }
    
    @ViewBuilder
    private var loadingStateImage: some View {
        let condition = config.imageName == ViewState.loading.image
        let repeating = condition
        
        KeyframeAnimator(initialValue: config,
                         repeating: repeating) { value in
            
            let rotation = condition ? value.rotation : .zero
            let scale = condition ? value.scale : 1.5
            
            Image(systemName: config.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .rotationEffect(rotation)
                .scaleEffect(CGSize(width: scale, height: scale))
                .onChange(of: config.state) { oldValue, newValue in
                    withAnimation(config.animation) {
                        config.imageName = newValue.image
                        config.rotation = .zero
                        config.scale = 2.0
                    }
                    withAnimation(config.animation.delay(0.3)) {
                        config.textScale = newValue == .connected ? 1 : 0
                        config.textOffset = newValue == .connected ? 0 : -1000
                    }
                }
        } keyframes: { value in
            KeyframeTrack(\.scale) {
                CubicKeyframe(1.3, duration: 1.0)
                CubicKeyframe(1.0, duration: 1.0)
            }
            KeyframeTrack(\.rotation) {
                CubicKeyframe(.degrees(180), duration: 2.0)
            }
        }
    }
    
    private var loadedImage: some View  {
        Image(systemName: ViewState.connected.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 150, height: 150)
    }
    
    private func onViewFailableTask() async throws {
        try await Task.sleep(for: .seconds(1))
        await loginManager.appleMusicLogin()
    }
    
    private func onViewAppeared() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: .init(block: {
            config.hasAppeared.toggle()
        }))
    }
    
    private func onViewTapGesture() {
#if targetEnvironment(simulator)
        if config.state == .connected {
            config.state = .loading
        } else {
            config.state = .connected
        }
#endif
    }
}

#Preview {
    ContentView()
}

@Observable
class LoginManager {
    
    private let musicService: MusicServiceAccess
    let successEvent: PassthroughSubject<Void, Never>
    
    init(musicService: MusicServiceAccess = .shared) {
        self.musicService = musicService
        successEvent = .init()
    }
    
    func appleMusicLogin() async {
        await MusicServiceAccess.shared.requestAuthorization()
        let isok = await MusicServiceAccess.shared.isAuthorized
        await MainActor.run {
            if isok {
                successEvent.send()
            }
        }
    }
}


extension View {
    
    static var navigationSource: String {
        String(describing: Self.self)
    }
    
}
