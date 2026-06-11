//
//  SpyGameLiveActivity.swift
//  SpyGameWidgetExtension
//

import ActivityKit
import SwiftUI
import WidgetKit

struct SpyGameLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GameActivityAttributes.self) { context in
            LockScreenGameView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.7))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.state.phase.title, systemImage: context.state.phase.systemImage)
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(.orange)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .frame(maxHeight: .infinity)
                        .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    GameTimerText(startTime: context.attributes.startTime)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundStyle(.green)
                        .frame(width: 72, alignment: .trailing)
                        .frame(maxHeight: .infinity)
                        .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 16) {
                        Label(playersLabel(context.attributes.playerCount), systemImage: "person.3.fill")
                        Label(spiesLabel(context.attributes.spyCount), systemImage: "eyes")
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                }
            } compactLeading: {
                Image(systemName: "eyes")
                    .foregroundStyle(.orange)
            } compactTrailing: {
                GameTimerText(startTime: context.attributes.startTime)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
                    .frame(maxWidth: 52)
            } minimal: {
                Image(systemName: "eyes")
                    .foregroundStyle(.orange)
            }
        }
    }
}

/// Self-updating count-up timer rendered by the system — keeps ticking
/// while the app is suspended.
private struct GameTimerText: View {
    let startTime: Date

    var body: some View {
        Text(startTime, style: .timer)
            .monospacedDigit()
            .multilineTextAlignment(.trailing)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }
}

private struct LockScreenGameView: View {
    let context: ActivityViewContext<GameActivityAttributes>

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Label(context.state.phase.title, systemImage: context.state.phase.systemImage)
                    .font(.headline)
                    .foregroundStyle(.orange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Spacer()
                GameTimerText(startTime: context.attributes.startTime)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundStyle(.green)
                    .frame(maxWidth: 100)
            }

            HStack(spacing: 16) {
                Label(playersLabel(context.attributes.playerCount), systemImage: "person.3.fill")
                Label(spiesLabel(context.attributes.spyCount), systemImage: "eyes")
                Spacer()
            }
            .font(.footnote)
            .foregroundStyle(.white.opacity(0.7))
        }
        .padding()
    }
}

private func playersLabel(_ count: Int) -> String {
    let mod10 = count % 10
    let mod100 = count % 100
    if mod10 == 1 && mod100 != 11 { return "\(count) игрок" }
    if (2...4).contains(mod10) && !(12...14).contains(mod100) { return "\(count) игрока" }
    return "\(count) игроков"
}

private func spiesLabel(_ count: Int) -> String {
    let mod10 = count % 10
    let mod100 = count % 100
    if mod10 == 1 && mod100 != 11 { return "\(count) шпион" }
    if (2...4).contains(mod10) && !(12...14).contains(mod100) { return "\(count) шпиона" }
    return "\(count) шпионов"
}

#Preview(
    "Island expanded",
    as: .dynamicIsland(.expanded),
    using: GameActivityAttributes(playerCount: 6, spyCount: 1, startTime: .now)
) {
    SpyGameLiveActivity()
} contentStates: {
    GameActivityAttributes.ContentState(phase: .discussion)
    GameActivityAttributes.ContentState(phase: .voting)
}
