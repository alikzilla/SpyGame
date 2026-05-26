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
        .navigationTitle(isImmediateMode ? "Kick Player" : "Voting")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isImmediateMode ? false : currentVoterIndex > 0)
        .alert("Confirm Action", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button(isImmediateMode ? "Kick" : "Vote", role: .destructive) {
                confirmAction()
            }
        } message: {
            if let selected = selectedPlayer {
                Text(isImmediateMode ? "Kick Player \(selected)?" : "Player \(currentVoter) votes for Player \(selected)?")
            }
        }
    }
    
    private var immediateKickView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "person.fill.xmark")
                    .font(.system(size: 70))
                    .foregroundStyle(.orange.gradient)
                
                Text("Select Player to Kick")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text("Choose a player you suspect is the spy")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Player Grid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                ForEach(availablePlayers, id: \.self) { playerNumber in
                    Button {
                        selectedPlayer = playerNumber
                        showingConfirmation = true
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                            Text("Player \(playerNumber)")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.white)
                        .frame(width: 80, height: 80)
                        .background(.orange.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .padding(.horizontal, 40)
            
            if !gameState.kickedPlayers.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Already Kicked:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(gameState.kickedPlayers.sorted().map { "Player \($0)" }.joined(separator: ", "))
                        .font(.callout)
                        .foregroundStyle(.orange)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 40)
            }
            
            Spacer()
            
            NavigationLink(destination: GameResultsView(gameState: gameState)) {
                Text("Finish Voting")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 40)
            
            Spacer()
                .frame(height: 40)
        }
    }
    
    private var oneByOneVotingView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.blue.gradient)
                
                Text("Player \(currentVoter)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                
                Text("Who do you think is the spy?")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                
                Text("Voter \(currentVoterIndex + 1) of \(availablePlayers.count)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
            
            // Player Grid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                ForEach(availablePlayers, id: \.self) { playerNumber in
                    Button {
                        selectedPlayer = playerNumber
                        showingConfirmation = true
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: playerNumber == currentVoter ? "person.circle" : "person.circle.fill")
                                .font(.system(size: 40))
                            Text("Player \(playerNumber)")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.white)
                        .frame(width: 80, height: 80)
                        .background(playerNumber == currentVoter ? .gray.gradient : .blue.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(playerNumber == currentVoter)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            if currentVoterIndex < availablePlayers.count - 1 {
                Text("Waiting for vote...")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding()
            }
            
            Spacer()
                .frame(height: 40)
        }
    }
    
    private func confirmAction() {
        guard let selected = selectedPlayer else { return }
        
        if isImmediateMode {
            gameState.kickedPlayers.insert(selected)
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
}

#Preview {
    NavigationStack {
        var config = GameConfiguration()
        var state = GameState(configuration: config)
        state.assignRoles()
        return VotingView(gameState: .constant(state))
    }
}
