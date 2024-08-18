//
//  TaskErrorModifier.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 06/08/2024.
//

import SwiftUI

struct TaskErrorModifier: ViewModifier {
    
    var handle: () async throws -> Void
    
    func body(content: Content) -> some View {
        content
            .task {
                do {
                    try await handle()
                } catch {
                    print(error)
                }
            }
    }
}

extension View {
    func failableTask(handle: @escaping () async throws -> Void) -> some View {
        return modifier(TaskErrorModifier(handle: handle))
    }
}
