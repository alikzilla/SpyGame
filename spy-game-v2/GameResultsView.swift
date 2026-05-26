//
//  GameResultsView.swift
//  spy-game-v2
//
//  Created by Алихан on 10.05.2026.
//

import SwiftUI

struct GameResultsView: View {
    let gameState: GameState
    @Environment(\.dismiss) private var dismiss
    
    private var results: GameResults {
        gameState.getResults()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                    .frame(height: 20)
                
                // Winner Announcement
                VStack(spacing: 20) {
                    Image(systemName: results.playersWin ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(results.playersWin ? .green.gradient : .red.gradient)
                    
                    Text(results.playersWin ? "Players Win!" : "Spy Wins!")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(results.playersWin ? .green : .red)
                    
                    if results.playersWin {
                        Text("The spy was caught!")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("The spy got away!")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 20)
                
                // Spy Reveal
                VStack(alignment: .leading, spacing: 16) {
                    Label("The Spy", systemImage: "eyes")
                        .font(.headline)
                        .foregroundStyle(.red)
                    
                    HStack {
                        ForEach(Array(results.spyNumbers).sorted(), id: \.self) { spyNumber in
                            HStack {
                                Image(systemName: "person.fill.badge.minus")
                                Text("Player \(spyNumber)")
                            }
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.red.gradient)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 20)
                
                // Words Reveal
                VStack(alignment: .leading, spacing: 16) {
                    Label("Words", systemImage: "text.quote")
                        .font(.headline)
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Players' Word:")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(results.correctWord)
                                .fontWeight(.semibold)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Spy's Word:")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(results.spyWord)
                                .fontWeight(.semibold)
                        }
                    }
                    .font(.callout)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 20)
                
                // Voting Results
                if gameState.configuration.votingMode == .oneByOne {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Voting Results", systemImage: "hand.raised.fill")
                            .font(.headline)
                            .foregroundStyle(.orange)
                        
                        let voteCounts = Dictionary(grouping: gameState.votes.values, by: { $0 })
                            .mapValues { $0.count }
                            .sorted { $0.value > $1.value }
                        
                        ForEach(voteCounts, id: \.key) { player, count in
                            HStack {
                                Image(systemName: "person.circle.fill")
                                Text("Player \(player)")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(count) \(count == 1 ? "vote" : "votes")")
                                    .foregroundStyle(.secondary)
                                
                                if results.spyNumbers.contains(player) {
                                    Image(systemName: "eyes.inverse")
                                        .foregroundStyle(.red)
                                }
                            }
                            .font(.callout)
                            .padding(.vertical, 4)
                        }
                        
                        if let mostVoted = results.votedPlayer {
                            Divider()
                            HStack {
                                Image(systemName: "arrow.down.circle.fill")
                                Text("Most Voted: Player \(mostVoted)")
                                    .fontWeight(.semibold)
                                if results.spyNumbers.contains(mostVoted) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                } else {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                            .font(.callout)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20)
                }
                
                // Kicked Players (Immediate Mode)
                if gameState.configuration.votingMode == .immediate && !results.kickedPlayers.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Kicked Players", systemImage: "person.fill.xmark")
                            .font(.headline)
                            .foregroundStyle(.orange)
                        
                        ForEach(Array(results.kickedPlayers).sorted(), id: \.self) { player in
                            HStack {
                                Image(systemName: "person.circle.fill")
                                Text("Player \(player)")
                                    .fontWeight(.medium)
                                Spacer()
                                if results.spyNumbers.contains(player) {
                                    HStack {
                                        Text("Was Spy")
                                            .foregroundStyle(.red)
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    }
                                } else {
                                    Text("Innocent")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .font(.callout)
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20)
                }
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button {
                        // Navigate back to welcome screen
                        dismiss()
                    } label: {
                        Text("Back to Home")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                    .frame(height: 40)
            }
        }
        .navigationTitle("Game Results")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        var config = GameConfiguration()
        config.votingMode = .oneByOne
        var state = GameState(configuration: config)
        state.assignRoles()
        state.votes = [1: 3, 2: 3, 3: 4, 4: 3]
        return GameResultsView(gameState: state)
    }
}
