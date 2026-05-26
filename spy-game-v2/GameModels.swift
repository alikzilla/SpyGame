//
//  GameModels.swift
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

struct WordPack: Identifiable, Codable {
    var id: UUID
    var name: String
    var words: [String]
    var isBuiltIn: Bool

    init(id: UUID = UUID(), name: String, words: [String], isBuiltIn: Bool = false) {
        self.id = id
        self.name = name
        self.words = words
        self.isBuiltIn = isBuiltIn
    }
}

extension WordPack: Equatable {
    static func == (lhs: WordPack, rhs: WordPack) -> Bool { lhs.id == rhs.id }
}

extension WordPack: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct GameConfiguration {
    var playerCount: Int = 4
    var spyCount: Int = 1
    var spyMode: SpyMode = .differentWord
    var votingMode: VotingMode = .immediate
    var selectedPack: WordPack = WordPacks.footballPlayers
}

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

        // Build spy word pool from all words except mainWord
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

struct WordPacks {
    static let footballPlayers = WordPack(
        name: "Футболисты",
        words: [
            "Лионель Месси", "Криштиану Роналду", "Неймар", "Килиан Мбаппе",
            "Эрлинг Холанн", "Кевин Де Брёйне", "Мохамед Салах", "Роберт Левандовски",
            "Лука Модрич", "Карим Бензема", "Вирджил ван Дейк", "Тибо Куртуа",
            "Гарри Кейн", "Сон Хын Мин", "Бруну Фернандеш", "Садио Мане",
            "Джошуа Киммих", "Тони Кроос", "Казмиру", "Серхио Рамос",
            "Джанлуиджи Доннарумма", "Эдерсон", "Алиссон Беккер", "Ян Облак",
            "Мануэль Нойер", "Нголо Канте", "Поль Погба", "Френки де Йонг",
            "Педри", "Гави", "Джуд Беллингем", "Фил Фоден",
            "Рахим Стерлинг", "Джек Грилиш", "Бернарду Силва", "Жоау Канселу",
            "Рубен Диаш", "Маркиньюс", "Тьягу Силва", "Эндрю Робертсон",
            "Трент Александер-Арнольд", "Кайл Уокер", "Ашраф Хакими", "Тео Эрнандес",
            "Винисиус Жуниор", "Родриго", "Федерико Вальверде", "Эдуарду Камавинга",
            "Антуан Гризманн", "Оливье Жиру"
        ],
        isBuiltIn: true
    )

    static let builtIn: [WordPack] = [footballPlayers]
}
