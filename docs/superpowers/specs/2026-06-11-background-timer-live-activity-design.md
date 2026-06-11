# Background-Surviving Timer + Dynamic Island Live Activity

**Date:** 2026-06-11
**Status:** Approved

## Problem

1. The game timer in `ActiveGameView` counts ticks with a foreground `Timer`
   (`timeElapsed += 1`). iOS suspends timers when the app is backgrounded, so
   elapsed time is lost. Additionally, `onAppear` resets `gameState.startTime`
   on every appearance, so returning from the voting screen also resets it.
2. There is no Dynamic Island presence: when the phone is locked or the user
   switches apps mid-game, the timer is invisible.

## Design

### Part 1 — Wall-clock timer

- `gameState.startTime` is set exactly once, on the first `onAppear` of
  `ActiveGameView` (guard on `startTime == nil`).
- The display uses `Text(startTime, style: .timer)` — a system-rendered,
  self-updating count-up timer. No `Timer` object, nothing to suspend; always
  correct after returning from background.
- `timeElapsed`, `timer`, `startTimer()`, `stopTimer()` are deleted.
- Timer stays **count-up only** (user decision; no countdown/time-limit mode).

### Part 2 — Live Activity (Dynamic Island)

New widget extension target **SpyGameWidgetExtension** (folder
`SpyGameWidget/`) plus a `Shared/` folder synced into both targets.

**Shared model** — `Shared/GameActivityAttributes.swift`:
- Static attributes: `playerCount: Int`, `spyCount: Int`, `startTime: Date`.
- `ContentState`: `phase` — `.discussion` ("Обсуждение") / `.voting`
  ("Голосование").
- No word/role information ever appears on the island (user decision:
  island shows timer + players/spies count + game phase).

**Island UI** (`SpyGameWidget/SpyGameLiveActivity.swift`):
- Compact: spy eyes icon (leading) + live count-up timer (trailing).
- Minimal: timer.
- Expanded: big timer, phase title, "N игроков · M шпионов" row.
- Lock screen banner: same info for non-Island devices.

**Lifecycle** — `spy-game-v2/LiveActivityManager.swift` (`@MainActor`,
singleton):
- `start()` when `ActiveGameView` first appears (ends any stale activities
  first).
- `update(phase:)` entering `VotingView` (.voting) and returning to
  `ActiveGameView` (.discussion).
- `end()` when `GameResultsView` appears.

**Project config:**
- `INFOPLIST_KEY_NSSupportsLiveActivities = YES` on the app target.
- Widget target wired by hand into `project.pbxproj` (objectVersion 77,
  file-system-synchronized groups). Fallback if Xcode rejects the hand edit:
  user adds an empty Widget Extension target via Xcode GUI, code is already
  in place.

## Error handling

- `ActivityAuthorizationInfo().areActivitiesEnabled` guard — if the user
  disabled Live Activities, the game runs unchanged without one.
- `Activity.request` failures are non-fatal (activity is a bonus feature).
- Stale activities from force-quit sessions are ended on next game start.

## Testing

- Build verification via `xcodebuild` (app + extension).
- Manual: run on simulator/device, background the app during a game, verify
  the timer is correct on return and the island shows the live timer.
