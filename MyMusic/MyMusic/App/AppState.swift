//
//  AppState.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 09/08/2024.
//

import SwiftUI

@Observable
class AppState {
    var isLoggedIn: Bool
    
    init(isLoggedIn: Bool) {
        self.isLoggedIn = isLoggedIn
    }
}


extension EnvironmentValues {
    @Entry var appState: AppState = .init(isLoggedIn: false)
}
