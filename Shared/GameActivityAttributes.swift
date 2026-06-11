//
//  GameActivityAttributes.swift
//  spy-game-v2
//
//  Shared between the app and the widget extension — keep both targets in sync.
//

import ActivityKit
import Foundation

nonisolated struct GameActivityAttributes: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable {
        var phase: GamePhase
    }

    nonisolated enum GamePhase: String, Codable, Hashable {
        case discussion
        case voting

        var title: String {
            switch self {
            case .discussion: "Обсуждение"
            case .voting: "Голосование"
            }
        }

        var systemImage: String {
            switch self {
            case .discussion: "bubble.left.and.bubble.right.fill"
            case .voting: "hand.raised.fill"
            }
        }
    }

    var playerCount: Int
    var spyCount: Int
    var startTime: Date
}
