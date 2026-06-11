//
//  PackDetailView.swift
//  spy-game-v2
//
//  Created by Алихан on 10.05.2026.
//

import SwiftUI

struct PackDetailView: View {
    @Environment(PacksManager.self) private var manager
    let pack: WordPack

    @State private var name: String
    @State private var wordItems: [WordItem]
    @State private var editMode: EditMode = .inactive

    private var isEditing: Bool { editMode == .active }

    init(pack: WordPack) {
        self.pack = pack
        _name = State(initialValue: pack.name)
        _wordItems = State(initialValue: pack.words.map { WordItem(text: $0) })
    }

    var body: some View {
        Form {
            Section("Название") {
                if pack.isBuiltIn || !isEditing {
                    Text(name)
                        .foregroundStyle(.secondary)
                } else {
                    TextField("Название пака", text: $name)
                }
            }

            Section("Слова (\(wordItems.count))") {
                ForEach($wordItems) { $item in
                    if pack.isBuiltIn || !isEditing {
                        Text(item.text)
                    } else {
                        TextField("Слово", text: $item.text)
                    }
                }
                .onDelete(perform: isEditing && !pack.isBuiltIn ? { wordItems.remove(atOffsets: $0) } : nil)
                .onMove(perform: isEditing && !pack.isBuiltIn ? { wordItems.move(fromOffsets: $0, toOffset: $1) } : nil)

                if !pack.isBuiltIn && isEditing {
                    Button("Добавить слово", systemImage: "plus") {
                        wordItems.append(WordItem(text: ""))
                    }
                }
            }

            if wordItems.isEmpty && !pack.isBuiltIn {
                ContentUnavailableView(
                    "Нет слов",
                    systemImage: "text.badge.plus",
                    description: Text(isEditing ? "Нажмите «Добавить слово», чтобы начать" : "Нажмите «Редактировать», чтобы добавить слова")
                )
            }
        }
        .environment(\.editMode, $editMode)
        .navigationTitle(pack.isBuiltIn ? pack.name : name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !pack.isBuiltIn {
                ToolbarItem(placement: .topBarTrailing) {
                    if isEditing {
                        Button("Сохранить", systemImage: "checkmark") {
                            save()
                            editMode = .inactive
                        }
                    } else {
                        Button("Редактировать", systemImage: "pencil") {
                            editMode = .active
                        }
                    }
                }
            }
        }
    }

    private func save() {
        var updated = pack
        updated.name = name.trimmingCharacters(in: .whitespaces).isEmpty ? pack.name : name.trimmingCharacters(in: .whitespaces)
        updated.words = wordItems
            .map { $0.text.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        manager.updatePack(updated)
    }
}

private struct WordItem: Identifiable {
    var id = UUID()
    var text: String
}

#Preview {
    NavigationStack {
        PackDetailView(pack: WordPacks.footballPlayers)
            .environment(PacksManager())
    }
}
