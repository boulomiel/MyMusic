//
//  OptionnalTransionModifier.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 14/08/2024.
//

import SwiftUI

struct OptionnalMatchModifier<ID: Hashable>: ViewModifier {
    
    let id: ID?
    var bottomNameSpace: Namespace.ID
    
    func body(content: Content) -> some View {
        if let id {
            content
                .matchedTransitionSource(id: id, in: bottomNameSpace)
        } else {
            content
        }
    }
}

extension View {
    func matchedTransitionSource<ID: Hashable>(id: ID?, in nameSpace: Namespace.ID ) -> some View {
        modifier(OptionnalMatchModifier(id: id, bottomNameSpace: nameSpace))
    }
}
