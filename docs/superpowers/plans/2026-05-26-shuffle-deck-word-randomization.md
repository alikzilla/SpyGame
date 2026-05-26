# Shuffle Deck Word Randomization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the per-game fresh shuffle in `assignRoles()` with a shuffle deck per pack so no word repeats until every word in the pack has been used once.

**Architecture:** `PacksManager` holds an in-memory `[UUID: [String]]` word queue per pack. A new `nextWord(for:)` method pops from the front and reshuffles when exhausted. `assignRoles()` accepts the chosen word as a parameter instead of picking it internally. `WordDistributionView` receives `PacksManager` via its init to call `nextWord()` before role assignment.

**Tech Stack:** Swift, SwiftUI, `@Observable`, `UserDefaults` (unchanged), no persistence added.

---

## File Map

| File | Change |
|------|--------|
| `spy-game-v2/PacksManager.swift` | Add `wordQueues: [UUID: [String]]` property + `nextWord(for:)` method |
| `spy-game-v2/GameModels.swift` | Change `assignRoles()` → `assignRoles(mainWord: String)` |
| `spy-game-v2/WordDistributionView.swift` | Add `packsManager: PacksManager` to `init`, call `nextWord()` there |
| `spy-game-v2/GameConfigurationView.swift` | Pass `packsManager` in the `NavigationLink` to `WordDistributionView` |
| `spy-game-v2/ActiveGameView.swift` | Update `#Preview` — fix broken `assignRoles()` call |
| `spy-game-v2/VotingView.swift` | Update `#Preview` — fix broken `assignRoles()` call |
| `spy-game-v2/GameResultsView.swift` | Update `#Preview` — fix broken `assignRoles()` call |

---

## Task 1: Add `nextWord(for:)` to `PacksManager`

**Files:**
- Modify: `spy-game-v2/PacksManager.swift`

This task is purely additive — no existing code changes, no build breaks.

- [ ] **Step 1: Add the `wordQueues` property and `nextWord(for:)` method**

In `spy-game-v2/PacksManager.swift`, insert after `private let storageKey = "customPacks"`:

```swift
private var wordQueues: [UUID: [String]] = [:]

func nextWord(for pack: WordPack) -> String {
    if wordQueues[pack.id]?.isEmpty ?? true {
        wordQueues[pack.id] = pack.words.shuffled()
    }
    return wordQueues[pack.id]!.removeFirst()
}
```

The final top of the class should look like:

```swift
@MainActor
@Observable
final class PacksManager {
    private(set) var packs: [WordPack] = []

    private let storageKey = "customPacks"
    private var wordQueues: [UUID: [String]] = [:]

    func nextWord(for pack: WordPack) -> String {
        if wordQueues[pack.id]?.isEmpty ?? true {
            wordQueues[pack.id] = pack.words.shuffled()
        }
        return wordQueues[pack.id]!.removeFirst()
    }
```

- [ ] **Step 2: Commit**

```bash
git add spy-game-v2/PacksManager.swift
git commit -m "feat: add shuffle deck word queue to PacksManager"
```

---

## Task 2: Update `assignRoles()` signature in `GameModels`

**Files:**
- Modify: `spy-game-v2/GameModels.swift`

> **Note:** This breaks all `assignRoles()` call sites. Do NOT commit until Tasks 3, 4, and 5 are also done.

- [ ] **Step 1: Replace the `assignRoles()` method body**

In `spy-game-v2/GameModels.swift`, replace the entire `assignRoles()` method:

Old:
```swift
mutating func assignRoles() {
    let pack = configuration.selectedPack
    var pool = pack.words.shuffled()

    currentWord = pool.removeFirst()

    // Pick a unique word per spy; fall back to currentWord only if pool is exhausted
    var spyWordPool: [String] = []
    if configuration.spyMode == .differentWord {
        for _ in 0..<configuration.spyCount {
            spyWordPool.append(pool.isEmpty ? currentWord : pool.removeFirst())
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
```

New:
```swift
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
```

---

## Task 3: Update `WordDistributionView` and `GameConfigurationView`

**Files:**
- Modify: `spy-game-v2/WordDistributionView.swift`
- Modify: `spy-game-v2/GameConfigurationView.swift`

- [ ] **Step 1: Update `WordDistributionView.init` to accept `PacksManager`**

In `spy-game-v2/WordDistributionView.swift`, replace the `init`:

Old:
```swift
init(configuration: GameConfiguration) {
    self.configuration = configuration
    var state = GameState(configuration: configuration)
    state.assignRoles()
    _gameState = State(initialValue: state)
}
```

New:
```swift
init(configuration: GameConfiguration, packsManager: PacksManager) {
    self.configuration = configuration
    let word = packsManager.nextWord(for: configuration.selectedPack)
    var state = GameState(configuration: configuration)
    state.assignRoles(mainWord: word)
    _gameState = State(initialValue: state)
}
```

- [ ] **Step 2: Update the `NavigationLink` in `GameConfigurationView`**

In `spy-game-v2/GameConfigurationView.swift`, replace the `NavigationLink` at line 111:

Old:
```swift
NavigationLink(destination: WordDistributionView(configuration: configuration)) {
    Text("Продолжить")
        .fontWeight(.semibold)
}
```

New:
```swift
NavigationLink(destination: WordDistributionView(configuration: configuration, packsManager: packsManager)) {
    Text("Продолжить")
        .fontWeight(.semibold)
}
```

---

## Task 4: Fix `#Preview` call sites

**Files:**
- Modify: `spy-game-v2/ActiveGameView.swift`
- Modify: `spy-game-v2/VotingView.swift`
- Modify: `spy-game-v2/GameResultsView.swift`

These are preview-only blocks. They use `assignRoles()` with no arguments and will fail to compile after Task 2.

- [ ] **Step 1: Fix `ActiveGameView.swift` preview**

Old (lines 126–130):
```swift
@Previewable @State var state: GameState = {
    var s = GameState(configuration: GameConfiguration())
    s.assignRoles()
    return s
}()
```

New:
```swift
@Previewable @State var state: GameState = {
    var s = GameState(configuration: GameConfiguration())
    let word = GameConfiguration().selectedPack.words.randomElement() ?? ""
    s.assignRoles(mainWord: word)
    return s
}()
```

- [ ] **Step 2: Fix `VotingView.swift` preview**

Old (lines 187–191):
```swift
@Previewable @State var state: GameState = {
    var s = GameState(configuration: GameConfiguration())
    s.assignRoles()
    return s
}()
```

New:
```swift
@Previewable @State var state: GameState = {
    var s = GameState(configuration: GameConfiguration())
    let word = GameConfiguration().selectedPack.words.randomElement() ?? ""
    s.assignRoles(mainWord: word)
    return s
}()
```

- [ ] **Step 3: Fix `GameResultsView.swift` preview**

Old (lines 226–232):
```swift
@Previewable @State var state: GameState = {
    var config = GameConfiguration()
    config.votingMode = .oneByOne
    var s = GameState(configuration: config)
    s.assignRoles()
    s.votes = [1: 3, 2: 3, 3: 4, 4: 3]
    return s
}()
```

New:
```swift
@Previewable @State var state: GameState = {
    var config = GameConfiguration()
    config.votingMode = .oneByOne
    var s = GameState(configuration: config)
    let word = config.selectedPack.words.randomElement() ?? ""
    s.assignRoles(mainWord: word)
    s.votes = [1: 3, 2: 3, 3: 4, 4: 3]
    return s
}()
```

- [ ] **Step 4: Build the project to confirm zero errors**

Open the project in Xcode and press `⌘B`, or run:

```bash
xcodebuild -project /Users/nuspekov/Documents/swift-projects/spy-game-v2/spy-game-v2.xcodeproj \
  -scheme spy-game-v2 \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build 2>&1 | grep -E "error:|warning:|BUILD"
```

Expected output contains: `BUILD SUCCEEDED`

- [ ] **Step 5: Commit tasks 2–4 together**

```bash
git add spy-game-v2/GameModels.swift \
        spy-game-v2/WordDistributionView.swift \
        spy-game-v2/GameConfigurationView.swift \
        spy-game-v2/ActiveGameView.swift \
        spy-game-v2/VotingView.swift \
        spy-game-v2/GameResultsView.swift
git commit -m "feat: use shuffle deck for word selection — no repeats within a pack cycle"
```
