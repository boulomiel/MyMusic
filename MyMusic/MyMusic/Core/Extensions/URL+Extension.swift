//
//  URL+Extension.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 07/08/2024.
//
import Foundation

extension URL {
    var nsURL: NSURL {
        NSURL(string: self.absoluteString)!
    }
}
