//
//  CellObservable.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 16/08/2024.
//

import SwiftUI
import MusicKit

@Observable
class CellObservable {
    
    let artist: Artist?
    let song: Song?
    let album: Album?
    let artwortSize: Int
    let queued: QueuedTask
    
    var artwork: Artwork? {
        if let song {
             song.artwork
        }
        else if let artist {
            artist.artwork
        }
        else if let album {
            album.artwork
        }
        else {
            nil
        }
    }
    
    var artistName: String {
        if let song {
            song.artistName
        } else if let artist {
            artist.name
        } else if let album {
            "\(album.artistName)"
        } else {
            ""
        }
    }
    
    var title: String {
        if let song {
            song.title
        } else if let artist {
            artist.name
        } else if let album {
            album.title
        } else {
            ""
        }
    }
    
    var bgColor: Color? {
        if let art = artwork, let c = art.backgroundColor {
            return Color(cgColor: c)
        }
        return nil
    }
    
    var bg: AnyGradient {
        return bgColor?.gradient ?? Color.gray.gradient
    }
    
    var mesh: MeshGradient {
        var colors: [Color] = []
        if let bgCG = artwork?.backgroundColor {
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
    
    var artworkURL: URL? {
        artwork?.url(width: artwortSize, height: artwortSize)
    }
    
    var image: UIImage {
        get async {
            if let url = artworkURL,
               let image = await UIImage.fetch(url, queued: queued) {
                return image
            } else {
                if let url = artworkURL {
                    return await queued.result.first(where: { $0.0 == url.nsURL })?.1 ?? .init()
                } else {
                    return .init()
                }
            }
        }
    }
        
    init(artist: Artist?, album: Album?, song: Song?, artwortSize: Int = 200) {
        self.artist = artist
        self.album = album
        self.song = song
        self.artwortSize = artwortSize
        self.queued = .init()
    }
}

