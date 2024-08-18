//
//  AppCache.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 09/08/2024.
//

import Foundation
import SwiftUI
import UIKit

class AppCache {
    var imageCache: NSCache<NSURL, UIImage> = .init()
    
    private init() {
        self.imageCache.totalCostLimit = 100_000_000
    }
    
    static let shared: AppCache = .init()
}

extension EnvironmentValues {
    @Entry var appCache: AppCache = .shared
}
