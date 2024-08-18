//
//  Collection + Extension.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 09/08/2024.
//

import Foundation

extension Collection {
    
    var second: Element? {
        let i = index(startIndex, offsetBy: 1)
        let d = distance(from: startIndex, to: i)
        if d < count {
            return self[i]
        }
        return nil
    }
}

extension Collection {

    /// Returns the element at the specified index if it exists, otherwise nil.
    subscript (safe index: Index) -> Element? {
        get {
            indices.contains(index) ? self[index] : nil
        }
    }
}
