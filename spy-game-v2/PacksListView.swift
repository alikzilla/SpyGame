//
//  PacksListView.swift
//  spy-game-v2
//
//  Created by Алихан on 10.05.2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct PacksListView: View {
    @Environment(PacksManager.self) private var manager
    @State private var showImporter = false
    @State private var pendingImport: WordPack?
    @State private var showAddPack = false
    @State private var newPackName = ""
    @State private var importError = ""
    @State private var showImportError = false

    private var builtIn: [WordPack] { manager.packs.filter(\.isBuiltIn) }
    private var custom: [WordPack] { manager.packs.filter { !$0.isBuiltIn } }

    var body: some View {
        List {
            Section("Встроенные") {
                ForEach(builtIn) { pack in
                    NavigationLink(value: pack) {
                        PackRowView(pack: pack)
                    }
                }
            }

            Section("Мои паки") {
                ForEach(custom) { pack in
                    NavigationLink(value: pack) {
                        PackRowView(pack: pack)
                    }
                }
                .onDelete { offsets in
                    manager.deletePacks(at: offsets, in: custom)
                }

                if custom.isEmpty {
                    ContentUnavailableView(
                        "Нет паков",
                        systemImage: "rectangle.stack.badge.plus",
                        description: Text("Создайте свой пак или импортируйте из файла")
                    )
                }
            }
        }
        .navigationTitle("Паки слов")
        .navigationDestination(for: WordPack.self) { pack in
            PackDetailView(pack: pack)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Импорт", systemImage: "square.and.arrow.down") {
                    showImporter = true
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Добавить", systemImage: "plus") {
                    newPackName = ""
                    showAddPack = true
                }
            }
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.plainText, .commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result: result)
        }
        .sheet(item: $pendingImport) { pack in
            ImportConfirmSheet(pack: pack) { confirmed in
                if confirmed { manager.addPack(pack) }
                pendingImport = nil
            }
            .presentationDetents([.medium])
        }
        .alert("Ошибка импорта", isPresented: $showImportError) {
        } message: {
            Text(importError)
        }
        .alert("Новый пак", isPresented: $showAddPack) {
            TextField("Название", text: $newPackName)
            Button("Создать") {
                let trimmed = newPackName.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty {
                    manager.addPack(WordPack(name: trimmed, words: []))
                }
            }
            Button("Отмена", role: .cancel) {}
        }
    }

    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            do {
                pendingImport = try manager.importPack(from: url)
            } catch {
                importError = error.localizedDescription
                showImportError = true
            }
        case .failure(let error):
            importError = error.localizedDescription
            showImportError = true
        }
    }
}

private struct PackRowView: View {
    let pack: WordPack

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(pack.name)
            Text("\(pack.words.count) слов")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

private struct ImportConfirmSheet: View {
    let pack: WordPack
    let onDismiss: (Bool) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 56))
                .foregroundStyle(.blue.gradient)

            VStack(spacing: 8) {
                Text("Импортировать пак?")
                    .font(.title2.bold())
                Text("«\(pack.name)»")
                    .font(.headline)
                Text("\(pack.words.count) слов")
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                Button {
                    onDismiss(true)
                } label: {
                    Text("Импортировать")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue.gradient)
                        .clipShape(.rect(cornerRadius: 14))
                }

                Button("Отмена", role: .cancel) {
                    onDismiss(false)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(32)
    }
}

#Preview {
    NavigationStack {
        PacksListView()
            .environment(PacksManager())
    }
}
