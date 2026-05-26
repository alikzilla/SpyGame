//
//  GameModels.swift
//  spy-game-v2
//
//  Created by Алихан on 10.05.2026.
//

import Foundation

enum SpyMode: String, CaseIterable, Codable {
    case differentWord = "Different Word"
    case knowsSpy = "Knows They're Spy"
    
    var description: String {
        switch self {
        case .differentWord:
            return "Spy gets different word"
        case .knowsSpy:
            return "Spy knows their role"
        }
    }
}

enum VotingMode: String, CaseIterable, Codable {
    case oneByOne = "One by One"
    case immediate = "Immediate Kick"
    
    var description: String {
        switch self {
        case .oneByOne:
            return "Vote one by one"
        case .immediate:
            return "Kick immediately"
        }
    }
}

struct WordPack: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let words: [String]
    let spyWords: [String]
}

struct GameConfiguration {
    var playerCount: Int = 4
    var spyCount: Int = 1
    var spyMode: SpyMode = .differentWord
    var votingMode: VotingMode = .oneByOne
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
    var spyWord: String = ""
    
    mutating func assignRoles() {
        guard let pack = configuration.selectedPack as WordPack? else { return }
        
        // Select random words
        currentWord = pack.words.randomElement() ?? ""
        spyWord = pack.spyWords.randomElement() ?? ""
        
        // Create array of player indices
        var playerIndices = Array(1...configuration.playerCount)
        playerIndices.shuffle()
        
        // Assign spy roles
        let spyIndices = Set(playerIndices.prefix(configuration.spyCount))
        
        playerRoles = (1...configuration.playerCount).map { playerNumber in
            let isSpy = spyIndices.contains(playerNumber)
            let word: String
            
            if isSpy {
                word = configuration.spyMode == .differentWord ? spyWord : "SPY"
            } else {
                word = currentWord
            }
            
            return PlayerRole(playerNumber: playerNumber, word: word, isSpy: isSpy)
        }
    }
    
    func getResults() -> GameResults {
        let spyNumbers = Set(playerRoles.filter { $0.isSpy }.map { $0.playerNumber })
        let votedPlayers = Dictionary(grouping: votes.values, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        let mostVotedPlayer = votedPlayers.first?.key
        
        let playersWin: Bool
        if configuration.votingMode == .immediate {
            // Players win if any spy was kicked
            playersWin = !kickedPlayers.isDisjoint(with: spyNumbers)
        } else {
            // Players win if most voted player is a spy
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
            spyWord: spyWord
        )
    }
}

struct GameResults {
    let playersWin: Bool
    let spyNumbers: Set<Int>
    let votedPlayer: Int?
    let kickedPlayers: Set<Int>
    let correctWord: String
    let spyWord: String
}

struct WordPacks {
    static let footballPlayers = WordPack(
        name: "Football Players",
        words: [
            "Lionel Messi", "Cristiano Ronaldo", "Neymar Jr", "Kylian Mbappé",
            "Erling Haaland", "Kevin De Bruyne", "Mohamed Salah", "Robert Lewandowski",
            "Luka Modrić", "Karim Benzema", "Virgil van Dijk", "Thibaut Courtois",
            "Harry Kane", "Son Heung-min", "Bruno Fernandes", "Sadio Mané",
            "Joshua Kimmich", "Toni Kroos", "Casemiro", "Sergio Ramos",
            "Gianluigi Donnarumma", "Ederson", "Alisson Becker", "Jan Oblak",
            "Manuel Neuer", "N'Golo Kanté", "Paul Pogba", "Frenkie de Jong",
            "Pedri", "Gavi", "Jude Bellingham", "Phil Foden",
            "Raheem Sterling", "Jack Grealish", "Bernardo Silva", "João Cancelo",
            "Rúben Dias", "Marquinhos", "Thiago Silva", "Andrew Robertson",
            "Trent Alexander-Arnold", "Kyle Walker", "Achraf Hakimi", "Theo Hernández",
            "Vinícius Júnior", "Rodrygo", "Federico Valverde", "Eduardo Camavinga",
            "Antoine Griezmann", "Olivier Giroud"
        ],
        spyWords: [
            "LeBron James", "Stephen Curry", "Tom Brady", "Serena Williams",
            "Roger Federer", "Rafael Nadal", "Novak Djokovic", "Tiger Woods",
            "Lewis Hamilton", "Usain Bolt", "Michael Phelps", "Simone Biles",
            "Conor McGregor", "Floyd Mayweather", "Mike Tyson", "Kobe Bryant"
        ]
    )
    
    static let allPacks = [footballPlayers]
}
