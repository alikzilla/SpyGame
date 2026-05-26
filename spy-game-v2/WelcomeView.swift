//
//  WelcomeView.swift
//  spy-game-v2
//
//  Created by Алихан on 10.05.2026.
//

import SwiftUI

struct WelcomeView: View {
    @State private var showConfiguration = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                // Game Icon
                Image(systemName: "person.3.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)
                
                // Game Title
                Text("Spy Game")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                
                // Game Description
                Text("Find the spy among your friends!\n\nMost players get the same word, but the spy gets a different one. Discuss and vote to catch the spy before they figure out the word!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // Start Button
                NavigationLink(destination: GameConfigurationView()) {
                    Text("Start New Game")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                    .frame(height: 60)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    WelcomeView()
}
