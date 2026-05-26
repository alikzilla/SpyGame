//
//  WordDistributionView.swift
//  spy-game-v2
//
//  Created by Алихан on 10.05.2026.
//

import SwiftUI

struct WordDistributionView: View {
    let configuration: GameConfiguration
    @State private var gameState: GameState
    @State private var currentPlayerIndex = 0
    @State private var isWordRevealed = false
    @State private var navigateToGame = false
    
    init(configuration: GameConfiguration) {
        self.configuration = configuration
        var state = GameState(configuration: configuration)
        state.assignRoles()
        _gameState = State(initialValue: state)
    }
    
    private var currentPlayer: PlayerRole {
        gameState.playerRoles[currentPlayerIndex]
    }
    
    private var isLastPlayer: Bool {
        currentPlayerIndex == gameState.playerRoles.count - 1
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            if !isWordRevealed {
                // Player Ready Screen
                VStack(spacing: 20) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue.gradient)
                    
                    Text("Player \(currentPlayer.playerNumber)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                    
                    Text("Get ready to see your word")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    Text("Make sure other players are not looking!")
                        .font(.callout)
                        .foregroundStyle(.orange)
                        .padding()
                        .background(.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isWordRevealed = true
                    }
                } label: {
                    Text("Show My Word")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 40)
                
            } else {
                // Word Revealed Screen
                VStack(spacing: 20) {
                    if currentPlayer.isSpy && configuration.spyMode == .knowsSpy {
                        Image(systemName: "eyes")
                            .font(.system(size: 80))
                            .foregroundStyle(.red.gradient)
                        
                        Text("YOU ARE THE SPY!")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.red)
                    } else {
                        Image(systemName: "text.quote")
                            .font(.system(size: 80))
                            .foregroundStyle(.green.gradient)
                        
                        Text("Your Word:")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(currentPlayer.word)
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .padding(30)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Text("Remember this word!")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if isLastPlayer {
                    NavigationLink(destination: ActiveGameView(gameState: gameState)) {
                        Text("Start Game")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.green.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 40)
                } else {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            currentPlayerIndex += 1
                            isWordRevealed = false
                        }
                    } label: {
                        Text("Next Player")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 40)
                }
            }
            
            Spacer()
                .frame(height: 60)
        }
        .navigationTitle("Word Distribution")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        WordDistributionView(configuration: GameConfiguration())
    }
}
