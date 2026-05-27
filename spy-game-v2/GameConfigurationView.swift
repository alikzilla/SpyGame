//
//  GameConfigurationView.swift
//  spy-game-v2
//
//  Created by Алихан on 10.05.2026.
//

import SwiftUI

struct GameConfigurationView: View {
    @Environment(PacksManager.self) private var packsManager
    @State private var configuration = GameConfiguration()
    @State private var navigateToWordDistribution = false
    @State private var selectedWord = ""
    
    var body: some View {
        Form {
            // Player Count Section
            Section {
                Stepper("Игроков: \(configuration.playerCount)", value: $configuration.playerCount, in: 3...20)
            } header: {
                Text("Игроки")
            } footer: {
                Text("Общее количество игроков")
            }

            // Spy Count Section
            Section {
                Stepper("Шпионов: \(configuration.spyCount)", value: $configuration.spyCount, in: 1...min(configuration.playerCount - 2, 5))
            } header: {
                Text("Шпионы")
            } footer: {
                Text("Количество шпионов")
            }

            // Spy Mode Section
            Section {
                Picker("Режим шпиона", selection: $configuration.spyMode) {
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
                .labelsHidden()
            } header: {
                Text("Настройки шпиона")
            } footer: {
                if configuration.spyMode == .differentWord {
                    Text("Шпион получит другое слово и не будет знать, что он шпион")
                } else {
                    Text("Шпион увидит «ШПИОН» и сразу узнает свою роль")
                }
            }

            // Word Pack Section
            Section {
                Picker("Набор слов", selection: $configuration.selectedPack) {
                    ForEach(packsManager.packs) { pack in
                        HStack {
                            Text(pack.name)
                            Spacer()
                            Text("\(pack.words.count) слов")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .tag(pack)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            } header: {
                Text("Набор слов")
            } footer: {
                Text("Выбрано: \(configuration.selectedPack.name)")
            }

            // Voting Mode Section
            Section {
                Picker("Режим голосования", selection: $configuration.votingMode) {
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
                .labelsHidden()
            } header: {
                Text("Настройки голосования")
            } footer: {
                if configuration.votingMode == .oneByOne {
                    Text("Игроки голосуют по одному за того, кого считают шпионом")
                } else {
                    Text("Игроки могут сразу выгнать подозреваемого во время игры")
                }
            }
        }
        .navigationTitle("Настройка игры")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToWordDistribution) {
            WordDistributionView(configuration: configuration, mainWord: selectedWord)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    selectedWord = packsManager.nextWord(for: configuration.selectedPack)
                    navigateToWordDistribution = true
                } label: {
                    Text("Продолжить")
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
    .environment(PacksManager())
}
