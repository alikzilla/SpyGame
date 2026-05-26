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
    
    init(configuration: GameConfiguration, packsManager: PacksManager) {
        self.configuration = configuration
        let word = packsManager.nextWord(for: configuration.selectedPack)
        var state = GameState(configuration: configuration)
        state.assignRoles(mainWord: word)
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
                    
                    Text("Игрок \(currentPlayer.playerNumber)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))

                    Text("Приготовься увидеть своё слово")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    Text("Убедись, что другие не смотрят!")
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
                    Text("Показать моё слово")
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

                        Text("ТЫ ШПИОН!")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.red)
                    } else {
                        Image(systemName: "text.quote")
                            .font(.system(size: 80))
                            .foregroundStyle(.green.gradient)

                        Text("Твоё слово:")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }

                    Text(currentPlayer.word)
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .padding(30)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    Text("Запомни это слово!")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isLastPlayer {
                    NavigationLink(destination: ActiveGameView(gameState: gameState)) {
                        Text("Начать игру")
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
                        currentPlayerIndex += 1
                        isWordRevealed = false
                    } label: {
                        Text("Следующий игрок")
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
        .navigationTitle("Раздача слов")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        WordDistributionView(configuration: GameConfiguration(), packsManager: PacksManager())
    }
}
