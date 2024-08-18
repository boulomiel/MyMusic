//
//  ReadScrollView.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 08/08/2024.
//

import SwiftUI

struct ReadScrollView<Content: View>: View {
    
    @ViewBuilder var content: (ScrollViewProxy) -> Content
    var axis: Axis.Set = .vertical
    
    var body: some View {
        ScrollView(axis) {
            ScrollViewReader { proxy in
                content(proxy)
            }
        }
    }
}
