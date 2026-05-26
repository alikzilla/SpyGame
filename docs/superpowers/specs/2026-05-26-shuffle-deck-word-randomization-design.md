# Shuffle Deck Word Randomization

**Date:** 2026-05-26

## Problem

`GameState.assignRoles()` calls `pack.words.shuffled()` fresh every game — pure random with replacement. This causes the same word to repeat frequently (e.g. the same person's name appearing 5 times in 10 games).

## Goal

Guarantee no word repeats within a full cycle of the pack. Once all words have been used, reshuffle and start the next cycle. History is in-memory only and resets when the app is fully killed.

## Design

### 1. Word Queue in `PacksManager`

Add a private in-memory dictionary to `PacksManager`:

```swift
private var wordQueues: [UUID: [String]] = [:]
```

Add a public method to pop the next word:

```swift
func nextWord(for pack: WordPack) -> String {
    if wordQueues[pack.id]?.isEmpty ?? true {
        wordQueues[pack.id] = pack.words.shuffled()
    }
    return wordQueues[pack.id]!.removeFirst()
}
```

- When a pack has no queue or an empty queue, the full word list is shuffled and stored.
- Each call pops the front element.
- When the queue is exhausted, it automatically reshuffles for the next cycle.
- No persistence — the dictionary lives only in memory and resets on app kill.

### 2. Decouple Word Selection from `assignRoles()`

Change `GameState.assignRoles()` signature to accept the main word as a parameter:

```swift
mutating func assignRoles(mainWord: String)
```

Internally, `currentWord = mainWord`. Spy words continue to be picked from a local shuffle of remaining pack words (excluding `mainWord`) — same behavior as today.

### 3. Call Site

`assignRoles()` is called in four places, but three of them are `#Preview` blocks (ActiveGameView, VotingView, GameResultsView). The only production call is in `WordDistributionView.init` at line 20.

**Problem:** `@Environment` is not available in `init`, so `packsManager.nextWord()` can't be called there directly.

**Solution:** Pass `PacksManager` as a parameter to `WordDistributionView.init`. The caller (`GameConfigurationView`) already has `@Environment(PacksManager.self)` and passes it in:

```swift
// WordDistributionView.init
init(configuration: GameConfiguration, packsManager: PacksManager) {
    self.configuration = configuration
    let word = packsManager.nextWord(for: configuration.selectedPack)
    var state = GameState(configuration: configuration)
    state.assignRoles(mainWord: word)
    _gameState = State(initialValue: state)
}
```

```swift
// GameConfigurationView — update the NavigationLink destination
WordDistributionView(configuration: configuration, packsManager: packsManager)
```

The `#Preview` call sites in `ActiveGameView`, `VotingView`, and `GameResultsView` must also be updated since the signature changes. For previews, pick a word inline:

```swift
var s = GameState(configuration: GameConfiguration())
let word = GameConfiguration().selectedPack.words.randomElement() ?? ""
s.assignRoles(mainWord: word)
```

## What Does NOT Change

- Spy word selection — still picks randomly from remaining words, not from the queue.
- `WordPack` model — no changes.
- Persistence logic in `PacksManager` — no changes.
- All UI views — no changes except the call site that triggers `assignRoles()`.

## Trade-offs

- **In-memory only:** Queue resets on app kill. Acceptable per user preference.
- **Queue per pack:** Each pack has its own independent cycle, so switching packs doesn't interfere.
- **Spy words excluded from queue:** Spy words are seen by only 1–2 players and are less likely to feel repetitive, so applying the queue only to the main word is sufficient.
