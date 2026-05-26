//
//  GameConfigurationView.swift
//  spy-game-v2
//
//  Created by Алихан on 10.05.2026.
//

import SwiftUI

struct GameConfigurationView: View {
    @State private var configuration = GameConfiguration()
    @State private var navigateToWordDistribution = false
    
    var body: some View {
        Form {
            // Player Count Section
            Section {
                Stepper("Players: \(configuration.playerCount)", value: $configuration.playerCount, in: 3...20)
            } header: {
                Text("Players")
            } footer: {
                Text("Total number of players in the game")
            }
            
            // Spy Count Section
            Section {
                Stepper("Spies: \(configuration.spyCount)", value: $configuration.spyCount, in: 1...min(configuration.playerCount - 2, 5))
            } header: {
                Text("Spies")
            } footer: {
                Text("Number of spies in the game")
            }
            
            // Spy Mode Section
            Section {
                Picker("Spy Mode", selection: $configuration.spyMode) {
                    ForEach(SpyMode.allCases, id: \.self) { mode in
                        VStack(alignment: .leading) {
                            Text(mode.rawValue)
                            Text(mode.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .tag(mode)
                    }
                }
                .pickerStyle(.inline)
            } header: {
                Text("Spy Configuration")
            } footer: {
                if configuration.spyMode == .differentWord {
                    Text("Spy will receive a different word and won't know they're the spy")
                } else {
                    Text("Spy will see 'SPY' and know their role immediately")
                }
            }
            
            // Word Pack Section
            Section {
                Picker("Word Pack", selection: $configuration.selectedPack) {
                    ForEach(WordPacks.allPacks, id: \.self) { pack in
                        HStack {
                            Text(pack.name)
                            Spacer()
                            Text("\(pack.words.count) words")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .tag(pack)
                    }
                }
                .pickerStyle(.inline)
            } header: {
                Text("Word Pack")
            } footer: {
                Text("Selected: \(configuration.selectedPack.name)")
            }
            
            // Voting Mode Section
            Section {
                Picker("Voting Mode", selection: $configuration.votingMode) {
                    ForEach(VotingMode.allCases, id: \.self) { mode in
                        VStack(alignment: .leading) {
                            Text(mode.rawValue)
                            Text(mode.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .tag(mode)
                    }
                }
                .pickerStyle(.inline)
            } header: {
                Text("Voting Configuration")
            } footer: {
                if configuration.votingMode == .oneByOne {
                    Text("Players will vote one by one to select who they think is the spy")
                } else {
                    Text("Players can kick suspects immediately during the game")
                }
            }
        }
        .navigationTitle("Game Setup")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                NavigationLink(destination: WordDistributionView(configuration: configuration)) {
                    Text("Continue")
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        GameConfigurationView()
    }
}
