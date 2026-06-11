//
//  LiveActivityManager.swift
//  spy-game-v2
//

import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()

    private var activity: Activity<GameActivityAttributes>?

    private init() {}

    func start(configuration: GameConfiguration, startTime: Date) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        endAll()

        let attributes = GameActivityAttributes(
            playerCount: configuration.playerCount,
            spyCount: configuration.spyCount,
            startTime: startTime
        )
        let content = ActivityContent(
            state: GameActivityAttributes.ContentState(phase: .discussion),
            staleDate: nil
        )
        activity = try? Activity.request(attributes: attributes, content: content)
    }

    func update(phase: GameActivityAttributes.GamePhase) {
        guard let activity else { return }
        let content = ActivityContent(
            state: GameActivityAttributes.ContentState(phase: phase),
            staleDate: nil
        )
        Task { await activity.update(content) }
    }

    func end() {
        guard let activity else { return }
        self.activity = nil
        Task { await activity.end(nil, dismissalPolicy: .immediate) }
    }

    /// Ends every activity for this app, including ones orphaned by a force-quit.
    func endAll() {
        activity = nil
        for orphan in Activity<GameActivityAttributes>.activities {
            Task { await orphan.end(nil, dismissalPolicy: .immediate) }
        }
    }
}
