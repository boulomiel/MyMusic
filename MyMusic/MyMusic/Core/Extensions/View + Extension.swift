//
//  View + Extension.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 12/08/2024.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func hide(if condition: Bool) -> some View {
        if !condition {
            self
        }
    }
    
    @ViewBuilder
    func show(if condition: Bool) -> some View {
        if condition {
            self
        }
    }
}
