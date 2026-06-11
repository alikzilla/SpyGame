//
//  GameConfiguration.swift
//  spy-game-v2
//
//  Created by Алихан on 10.05.2026.
//

import Foundation

enum SpyMode: String, CaseIterable, Codable {
    case differentWord = "Другое слово"
    case knowsSpy = "Знает о роли"

    var description: String {
        switch self {
        case .differentWord:
            return "Шпион получает другое слово"
        case .knowsSpy:
            return "Шпион знает свою роль"
        }
    }
}

enum VotingMode: String, CaseIterable, Codable {
    case oneByOne = "По одному"
    case immediate = "Немедленное исключение"

    var description: String {
        switch self {
        case .oneByOne:
            return "Голосование по очереди"
        case .immediate:
            return "Исключить немедленно"
        }
    }
}

struct GameConfiguration {
    var playerCount: Int = 4
    var spyCount: Int = 1
    var spyMode: SpyMode = .differentWord
    var votingMode: VotingMode = .immediate
    var selectedPack: WordPack = WordPacks.footballPlayers
}
