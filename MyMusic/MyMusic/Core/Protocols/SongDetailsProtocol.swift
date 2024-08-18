//
//  SongDetailsProtocol.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 14/08/2024.
//

import MusicKit
import UIKit
import SwiftUI

protocol SongDetailsProtocol {
    var song: Song? { get }
}

extension SongDetailsProtocol {
    
    var artwork: Artwork? {
        song?.artwork
    }
    
    var bgCG: CGColor? {
      artwork?.backgroundColor
    }
    
    var imageURL: URL? {
        artwork?.url(width: 200, height: 200)
    }
    
    var background: AnyGradient {
        if let bgCG {
            Color(cgColor: bgCG).gradient
        } else {
            Color.black.gradient
        }
    }
    
    var mesh: MeshGradient {
        var colors: [Color] = []
        if let bgCG {
            let bg = Color(cgColor: bgCG)
            
            colors = [
                bg.opacity(0.8), bg, bg,
                .gray.opacity(0.1), bg.opacity(0.8), bg,
                bg, .gray.opacity(0.1), .gray.opacity(0.1)
            ]
        }
        return MeshGradient(width: 3, height: 3, points: [
            [0, 0], [1, 0], [1, 1],
            [0, 1], [1, 1], [1, 2],
            [0, 2], [1, 2], [1, 3],
        ], colors: colors)
    }
    
    var title: String {
        song?.title ?? ""
    }
    var artist: String {
        song?.artistName ?? ""
    }
    
    var duration: TimeInterval {
        song?.duration ?? 0
    }
}
