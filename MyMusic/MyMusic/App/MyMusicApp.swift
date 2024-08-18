//
//  MyMusicApp.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 06/08/2024.
//

import SwiftUI
import SwiftData

@main
struct MyMusicApp: App {
        
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SDData.self, isAutosaveEnabled: true, isUndoEnabled: true) { result in
            switch result {
            case .success(let success):
                print("Model Container Setup success", success.configurations)
            case .failure(let failure):
                print("Model Container Setup failde", failure.localizedDescription)
            }
        }
    }
}
