//
//  VotingView.swift
//  spy-game-v2
//
//  Created by Алихан on 10.05.2026.
//

import SwiftUI

struct VotingView: View {
    @Binding var gameState: GameState
    @State private var currentVoterIndex = 0
    @State private var selectedPlayer: Int?
    @State private var showingConfirmation = false
    @State private var navigateToResults = false
    
    private var availablePlayers: [Int] {
        (1...gameState.configuration.playerCount).filter { !gameState.kickedPlayers.contains($0) }
    }
    
    private var currentVoter: Int {
        availablePlayers[min(currentVoterIndex, availablePlayers.count - 1)]
    }
    
    private var isImmediateMode: Bool {
        gameState.configuration.votingMode == .immediate
    }
    
    var body: some View {
        VStack(spacing: 30) {
            if isImmediateMode {
                // Immediate Kick Mode
                immediateKickView
            } else {
                // One by One Voting Mode
                oneByOneVotingView
            }
        }
        .navigationTitle(isImmediateMode ? "Выгнать игрока" : "Голосование")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isImmediateMode ? false : currentVoterIndex > 0)
        .navigationDestination(isPresented: $navigateToResults) {
            GameResultsView(gameState: gameState)
        }
        .alert("Подтвердите действие", isPresented: $showingConfirmation) {
            Button("Отмена", role: .cancel) { }
            Button(isImmediateMode ? "Выгнать" : "Голосовать", role: .destructive) {
                confirmAction()
            }
        } message: {
            if let selected = selectedPlayer {
                Text(isImmediateMode ? "Выгнать игрока \(selected)?" : "Игрок \(currentVoter) голосует за игрока \(selected)?")
            }
        }
    }
    
    private var immediateKickView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Image(systemName: "person.fill.xmark")
                    .font(.system(size: 60))
                    .foregroundStyle(.orange.gradient)

                Text("Выберите игрока для исключения")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)

                Text("Выберите игрока, которого подозреваете")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)

            List(availablePlayers, id: \.self) { playerNumber in
                Button {
                    selectedPlayer = playerNumber
                    showingConfirmation = true
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.orange)
                        Text("Игрок \(playerNumber)")
                            .font(.body)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .foregroundStyle(.primary)
            }
            .listStyle(.inset)
        }
    }
    
    private var oneByOneVotingView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue.gradient)

                Text("Игрок \(currentVoter)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))

                Text("Кто, по-твоему, шпион?")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Text("Голосует \(currentVoterIndex + 1) из \(availablePlayers.count)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)

            List(availablePlayers, id: \.self) { playerNumber in
                playerRow(for: playerNumber)
            }
            .listStyle(.inset)
        }
    }
    
    private func confirmAction() {
        guard let selected = selectedPlayer else { return }
        
        if isImmediateMode {
            gameState.kickedPlayers.insert(selected)
            navigateToResults = true
        } else {
            gameState.votes[currentVoter] = selected
            
            if currentVoterIndex < availablePlayers.count - 1 {
                currentVoterIndex += 1
            } else {
                navigateToResults = true
            }
        }
        
        selectedPlayer = nil
    }
    
    @ViewBuilder
    private func playerRow(for playerNumber: Int) -> some View {
        let isCurrentVoter = playerNumber == currentVoter

        Button {
            selectedPlayer = playerNumber
            showingConfirmation = true
        } label: {
            HStack(spacing: 16) {
                Image(systemName: isCurrentVoter ? "person.circle" : "person.circle.fill")
                    .font(.title2)
                    .foregroundStyle(isCurrentVoter ? Color.secondary : Color.blue)
                Text("Игрок \(playerNumber)")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(isCurrentVoter ? .secondary : .primary)
                if isCurrentVoter {
                    Text("(голосует)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if !isCurrentVoter {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .disabled(isCurrentVoter)
    }
}

#Preview {
    @Previewable @State var state: GameState = {
        var s = GameState(configuration: GameConfiguration())
        let word = GameConfiguration().selectedPack.words.randomElement() ?? ""
        s.assignRoles(mainWord: word)
        return s
    }()
    
    NavigationStack {
        VotingView(gameState: $state)
    }
}
