//
//  PacksManager.swift
//  spy-game-v2
//
//  Created by Алихан on 10.05.2026.
//

import Foundation
import UniformTypeIdentifiers
import Observation

@MainActor
@Observable
final class PacksManager {
    private(set) var packs: [WordPack] = []

    private let storageKey = "customPacks"
    private var wordQueues: [UUID: [String]] = [:]

    func nextWord(for pack: WordPack) -> String {
        guard !pack.words.isEmpty else { return "" }
        if wordQueues[pack.id]?.isEmpty ?? true {
            wordQueues[pack.id] = pack.words.shuffled()
        }
        return wordQueues[pack.id]!.removeFirst()
    }

    init() {
        reload()
    }

    func reload() {
        var all = WordPacks.builtIn
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let custom = try? JSONDecoder().decode([WordPack].self, from: data) {
            all += custom
        }
        packs = all
    }

    func addPack(_ pack: WordPack) {
        packs.append(pack)
        saveCustomPacks()
    }

    func updatePack(_ updated: WordPack) {
        guard let index = packs.firstIndex(where: { $0.id == updated.id }) else { return }
        packs[index] = updated
        wordQueues[updated.id] = nil
        saveCustomPacks()
    }

    func deletePacks(at offsets: IndexSet, in section: [WordPack]) {
        let ids = offsets.map { section[$0].id }
        ids.forEach { wordQueues.removeValue(forKey: $0) }
        packs.removeAll { ids.contains($0.id) && !$0.isBuiltIn }
        saveCustomPacks()
    }

    func importPack(from url: URL) throws -> WordPack {
        guard url.startAccessingSecurityScopedResource() else {
            throw ImportError.accessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }

        let content = try String(contentsOf: url, encoding: .utf8)
        let isCsv = url.pathExtension.lowercased() == "csv"

        var tokens: [String]
        if isCsv {
            tokens = content.components(separatedBy: CharacterSet.newlines.union(CharacterSet(charactersIn: ",")))
        } else {
            tokens = content.components(separatedBy: .newlines)
        }
        tokens = tokens
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard let name = tokens.first else { throw ImportError.emptyFile }
        let words = Array(tokens.dropFirst())
        guard words.count >= 2 else { throw ImportError.notEnoughWords }

        return WordPack(name: name, words: words)
    }

    private func saveCustomPacks() {
        let custom = packs.filter { !$0.isBuiltIn }
        if let data = try? JSONEncoder().encode(custom) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    enum ImportError: LocalizedError {
        case accessDenied, emptyFile, notEnoughWords

        var errorDescription: String? {
            switch self {
            case .accessDenied: return "Нет доступа к файлу"
            case .emptyFile: return "Файл пустой"
            case .notEnoughWords: return "Нужно минимум 2 слова"
            }
        }
    }
}
