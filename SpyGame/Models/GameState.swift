//
//  GameState.swift
//  spy-game-v2
//
//  Created by Алихан on 10.05.2026.
//

import Foundation

struct PlayerRole {
    let playerNumber: Int
    let word: String
    let isSpy: Bool
}

struct GameState {
    var configuration: GameConfiguration
    var playerRoles: [PlayerRole] = []
    var startTime: Date?
    var votes: [Int: Int] = [:] // playerNumber: votedForPlayer
    var kickedPlayers: Set<Int> = []

    var currentWord: String = ""

    mutating func assignRoles(mainWord: String) {
        let pack = configuration.selectedPack
        currentWord = mainWord

        // mainWord must exist in pack.words — caller (nextWord) guarantees this
        var pool = pack.words.filter { $0 != mainWord }.shuffled()

        var spyWordPool: [String] = []
        if configuration.spyMode == .differentWord {
            for _ in 0..<configuration.spyCount {
                spyWordPool.append(pool.isEmpty ? mainWord : pool.removeFirst())
            }
        }

        var playerIndices = Array(1...configuration.playerCount)
        playerIndices.shuffle()
        let orderedSpies = Array(playerIndices.prefix(configuration.spyCount))
        let spyIndexSet = Set(orderedSpies)

        playerRoles = (1...configuration.playerCount).map { playerNumber in
            let isSpy = spyIndexSet.contains(playerNumber)
            let word: String
            if isSpy {
                if configuration.spyMode == .differentWord,
                   let position = orderedSpies.firstIndex(of: playerNumber) {
                    word = spyWordPool[position]
                } else {
                    word = "ШПИОН"
                }
            } else {
                word = currentWord
            }
            return PlayerRole(playerNumber: playerNumber, word: word, isSpy: isSpy)
        }
    }

    func getResults() -> GameResults {
        let spyNumbers = Set(playerRoles.filter { $0.isSpy }.map { $0.playerNumber })
        let spyWords = Dictionary(
            uniqueKeysWithValues: playerRoles.filter { $0.isSpy }.map { ($0.playerNumber, $0.word) }
        )

        let votedPlayers = Dictionary(grouping: votes.values, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        let mostVotedPlayer = votedPlayers.first?.key

        let playersWin: Bool
        if configuration.votingMode == .immediate {
            playersWin = !kickedPlayers.isDisjoint(with: spyNumbers)
        } else {
            if let votedPlayer = mostVotedPlayer {
                playersWin = spyNumbers.contains(votedPlayer)
            } else {
                playersWin = false
            }
        }

        return GameResults(
            playersWin: playersWin,
            spyNumbers: spyNumbers,
            votedPlayer: mostVotedPlayer,
            kickedPlayers: kickedPlayers,
            correctWord: currentWord,
            spyWords: spyWords
        )
    }
}

struct GameResults {
    let playersWin: Bool
    let spyNumbers: Set<Int>
    let votedPlayer: Int?
    let kickedPlayers: Set<Int>
    let correctWord: String
    let spyWords: [Int: String] // playerNumber → their word
}
