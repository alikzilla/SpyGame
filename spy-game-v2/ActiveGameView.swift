//
//  ActiveGameView.swift
//  spy-game-v2
//
//  Created by Алихан on 10.05.2026.
//

import SwiftUI

struct ActiveGameView: View {
    @State var gameState: GameState
    @State private var timeElapsed: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Game Status
            VStack(spacing: 20) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green.gradient)
                
                Text("Игра началась!")
                    .font(.system(size: 42, weight: .bold, design: .rounded))

                Text("Обсуждайте и найдите шпиона")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            // Timer
            VStack(spacing: 10) {
                Text("Прошло времени")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(timeString(from: timeElapsed))
                    .font(.system(size: 56, weight: .bold, design: .monospaced))
                    .foregroundStyle(.blue)
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // Game Info
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "person.3.fill")
                    Text("\(gameState.configuration.playerCount) игроков")
                    Spacer()
                    Image(systemName: "eyes.inverse")
                    Text("\(gameState.configuration.spyCount) \(gameState.configuration.spyCount == 1 ? "шпион" : gameState.configuration.spyCount < 5 ? "шпиона" : "шпионов")")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                
                if gameState.configuration.votingMode == .immediate && !gameState.kickedPlayers.isEmpty {
                    Divider()
                    HStack {
                        Image(systemName: "person.fill.xmark")
                        Text("Выгнаны: \(gameState.kickedPlayers.sorted().map { String($0) }.joined(separator: ", "))")
                        Spacer()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.orange)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Action Buttons
            NavigationLink(destination: VotingView(gameState: $gameState)) {
                HStack {
                    Image(systemName: gameState.configuration.votingMode == .immediate ? "person.fill.xmark" : "hand.raised.fill")
                    Text(gameState.configuration.votingMode == .immediate ? "Выгнать игрока" : "Начать голосование")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.orange.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 40)
            
            Spacer()
                .frame(height: 60)
        }
        .navigationTitle("Активная игра")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            gameState.startTime = Date()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeElapsed += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
        ActiveGameView(gameState: state)
    }
}
