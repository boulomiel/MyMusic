//
//  AppearingTransitionModifier.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 08/08/2024.
//

import SwiftUI

struct AppearingTransitionModifier: ViewModifier {
    
    var isShown: Bool
    var animation: Animation? = .smooth
    var transition: AnyTransition
    
    func body(content: Content) -> some View {
        ZStack {
            if isShown {
                content
                    .transition(transition)
            }
        }
        .animation(animation, value: isShown)
    }
}

extension View {
    
    func appears(if isShown: Bool, with transition: AnyTransition, and animation: Animation?) -> some View {
        modifier(AppearingTransitionModifier(isShown: isShown, animation: animation, transition: transition))
    }
}
