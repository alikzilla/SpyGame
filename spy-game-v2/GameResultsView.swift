//
//  GameResultsView.swift
//  spy-game-v2
//
//  Created by Алихан on 10.05.2026.
//

import SwiftUI

struct GameResultsView: View {
    let gameState: GameState
    @Environment(GameSession.self) private var session

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
                        .foregroundStyle(results.playersWin ? Color.green.gradient : Color.red.gradient)
                    
                    Text(results.playersWin ? "Игроки победили!" : (results.spyNumbers.count > 1 ? "Шпионы победили!" : "Шпион победил!"))
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(results.playersWin ? Color.green : Color.red)

                    if results.playersWin {
                        Text(results.spyNumbers.count > 1 ? "Шпионы пойманы!" : "Шпион пойман!")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(results.spyNumbers.count > 1 ? "Шпионы ушли!" : "Шпион ушёл!")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 20)
                
                // Spy Reveal
                VStack(alignment: .leading, spacing: 16) {
                    Label(results.spyNumbers.count > 1 ? "Шпионы" : "Шпион", systemImage: "eyes")
                        .font(.headline)
                        .foregroundStyle(Color.red)
                    
                    HStack {
                        ForEach(Array(results.spyNumbers).sorted(), id: \.self) { spyNumber in
                            HStack {
                                Image(systemName: "person.fill.badge.minus")
                                Text("Игрок \(spyNumber)")
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
                    Label("Слова", systemImage: "text.quote")
                        .font(.headline)
                        .foregroundStyle(Color.blue)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Слово игроков:")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(results.correctWord)
                                .fontWeight(.semibold)
                        }

                        let sortedSpyWords = results.spyWords.sorted(by: { $0.key < $1.key })
                        ForEach(sortedSpyWords, id: \.key) { playerNumber, word in
                            Divider()
                            HStack {
                                Text(sortedSpyWords.count > 1 ? "Слово шпиона \(playerNumber):" : "Слово шпиона:")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(word)
                                    .fontWeight(.semibold)
                            }
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
                        Label("Результаты голосования", systemImage: "hand.raised.fill")
                            .font(.headline)
                            .foregroundStyle(Color.orange)
                        
                        let voteCounts = Dictionary(grouping: gameState.votes.values, by: { $0 })
                            .mapValues { $0.count }
                            .sorted { $0.value > $1.value }
                        
                        ForEach(voteCounts, id: \.key) { player, count in
                            HStack {
                                Image(systemName: "person.circle.fill")
                                Text("Игрок \(player)")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(count) \(count == 1 ? "голос" : count < 5 ? "голоса" : "голосов")")
                                    .foregroundStyle(.secondary)
                                
                                if results.spyNumbers.contains(player) {
                                    Image(systemName: "eyes.inverse")
                                        .foregroundStyle(Color.red)
                                }
                            }
                            .font(.callout)
                            .padding(.vertical, 4)
                        }
                        
                        if let mostVoted = results.votedPlayer {
                            Divider()
                            HStack {
                                Image(systemName: "arrow.down.circle.fill")
                                Text("Лидер голосования: Игрок \(mostVoted)")
                                    .fontWeight(.semibold)
                                if results.spyNumbers.contains(mostVoted) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.green)
                                } else {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Color.red)
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
                        Label("Исключённые игроки", systemImage: "person.fill.xmark")
                            .font(.headline)
                            .foregroundStyle(Color.orange)
                        
                        ForEach(Array(results.kickedPlayers).sorted(), id: \.self) { player in
                            HStack {
                                Image(systemName: "person.circle.fill")
                                Text("Игрок \(player)")
                                    .fontWeight(.medium)
                                Spacer()
                                if results.spyNumbers.contains(player) {
                                    HStack {
                                        Text("Был шпионом")
                                            .foregroundStyle(Color.red)
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color.green)
                                    }
                                } else {
                                    Text("Невиновен")
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
                        session.isActive = false
                    } label: {
                        Text("На главную")
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
        .navigationTitle("Результаты игры")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            LiveActivityManager.shared.end()
        }
    }
}

#Preview {
    @Previewable @State var state: GameState = {
        var config = GameConfiguration()
        config.votingMode = .oneByOne
        var s = GameState(configuration: config)
        let word = config.selectedPack.words.randomElement() ?? ""
        s.assignRoles(mainWord: word)
        s.votes = [1: 3, 2: 3, 3: 4, 4: 3]
        return s
    }()
    
    NavigationStack {
        GameResultsView(gameState: state)
            .environment(GameSession())
    }
}
