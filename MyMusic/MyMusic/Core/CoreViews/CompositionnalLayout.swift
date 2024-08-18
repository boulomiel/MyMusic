//
//  CompositionnalLayout.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 08/08/2024.
//

import SwiftUI

struct CompositionnalLayout<Content: View>: View {
    
    
    var count: Int = 3
    var spacing: CGFloat = 6.0
    var axis: Axis.Set = .vertical
    var geo: GeometryProxy
    @ViewBuilder var content: Content
    
    var body: some View {
        Group(subviews: content) { subviews in
            let chunked = subviews.chunked(count)
            ForEach(chunked) { chunk in
                switch chunk.layoutID {
                case 1: Row1(chunk.collection)
                case 2: Row2(chunk.collection)
                case 3: Row3(chunk.collection)
                default: Row4(chunk.collection)
                }
            }
        }
    }
    
    private func Row1(_ collection: [SubviewsCollection.Element]) -> some View {
        GeometryReader { geo in
            let size = geo.size
            HStack(spacing: spacing) {
                if let first = collection.first {
                    first
                        .id(first.id)
                        .frame(width: collection.count == 1 ? size.width : size.width * 0.5)
                }
                VStack(spacing: spacing) {
                    ForEach(collection.dropFirst()) {
                        $0
                            .id($0.id)
                    }
                }
            }
        }
        .frame(height: 180)
    }
    
    private func Row2(_ collection: [SubviewsCollection.Element]) -> some View {
        GeometryReader { geo in
            let size = geo.size
            HStack(spacing: spacing) {
                VStack(spacing: spacing) {
                    ForEach(collection.dropFirst()) {
                        $0
                            .id($0.id)
                    }
                }
                if let first = collection.first {
                    first
                        .id(first.id)
                        .frame(width: collection.count == 1 ? size.width : size.width * 0.5)
                }
            }
        }
        .frame(height: 220)
    }
    
    private func Row3(_ collection: [SubviewsCollection.Element]) -> some View {
        GeometryReader { geo in
            let size = geo.size
            HStack(spacing: spacing) {
                if let first = collection.first {
                    first
                        .id(first.id)
                        .frame(width: collection.count == 1 ? size.width : size.width * 0.5)
                    
                }
                VStack(spacing: spacing) {
                    ForEach(collection.dropFirst(), id: \.id) {
                        $0
                            .id($0.id)
                        
                    }
                }
            }
            
        }
        .frame(height: 240)
    }
    
    private func Row4(_ collection: [SubviewsCollection.Element]) -> some View {
        HStack(spacing: spacing) {
            ForEach(collection) {
                $0
                    .id($0.id)
                
            }
        }
        .frame(height: 140)
    }
}

fileprivate extension SubviewsCollection {
    
    func chunked(_ size: Int) -> [ChunkedCollection] {
        return stride(from: 0, to: self.count, by: size).map {
            let collection = Array(self[$0..<Swift.min($0 + size, count)])
            let layoutID = ($0/size) % 4
            return .init(layoutID: layoutID, collection: collection)
        }
    }
    
    struct ChunkedCollection: Identifiable {
        let id: UUID = .init()
        var layoutID: Int
        var collection: [SubviewsCollection.Element]
    }
}
