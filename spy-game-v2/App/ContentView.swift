//
//  ContentView.swift
//  spy-game-v2
//
//  Created by Алихан on 10.05.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var session = GameSession()
    @State private var packsManager = PacksManager()

    var body: some View {
        TabView {
            Tab("Игра", systemImage: "person.3.fill") {
                WelcomeView()
            }
            Tab("Паки", systemImage: "rectangle.stack.fill") {
                NavigationStack {
                    PacksListView()
                }
            }
        }
        .environment(session)
        .environment(packsManager)
        .fullScreenCover(isPresented: $session.isActive) {
            NavigationStack {
                GameConfigurationView()
            }
            .environment(session)
            .environment(packsManager)
        }
    }
}

#Preview {
    ContentView()
}
