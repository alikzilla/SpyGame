//
//  WordPack.swift
//  spy-game-v2
//
//  Created by Алихан on 10.05.2026.
//

import Foundation

struct WordPack: Identifiable, Codable {
    var id: UUID
    var name: String
    var words: [String]
    var isBuiltIn: Bool

    init(id: UUID = UUID(), name: String, words: [String], isBuiltIn: Bool = false) {
        self.id = id
        self.name = name
        self.words = words
        self.isBuiltIn = isBuiltIn
    }
}

extension WordPack: Equatable {
    static func == (lhs: WordPack, rhs: WordPack) -> Bool { lhs.id == rhs.id }
}

extension WordPack: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct WordPacks {
    static let footballPlayers = WordPack(
        name: "Футболисты",
        words: [
            "Лионель Месси", "Криштиану Роналду", "Неймар", "Килиан Мбаппе",
            "Эрлинг Холанн", "Кевин Де Брёйне", "Мохамед Салах", "Роберт Левандовски",
            "Лука Модрич", "Карим Бензема", "Вирджил ван Дейк", "Тибо Куртуа",
            "Гарри Кейн", "Сон Хын Мин", "Бруну Фернандеш", "Садио Мане",
            "Джошуа Киммих", "Тони Кроос", "Казмиру", "Серхио Рамос",
            "Джанлуиджи Доннарумма", "Эдерсон", "Алиссон Беккер", "Ян Облак",
            "Мануэль Нойер", "Нголо Канте", "Поль Погба", "Френки де Йонг",
            "Педри", "Гави", "Джуд Беллингем", "Фил Фоден",
            "Рахим Стерлинг", "Джек Грилиш", "Бернарду Силва", "Жоау Канселу",
            "Рубен Диаш", "Маркиньюс", "Тьягу Силва", "Эндрю Робертсон",
            "Трент Александер-Арнольд", "Кайл Уокер", "Ашраф Хакими", "Тео Эрнандес",
            "Винисиус Жуниор", "Родриго", "Федерико Вальверде", "Эдуарду Камавинга",
            "Антуан Гризманн", "Оливье Жиру"
        ],
        isBuiltIn: true
    )

    static let builtIn: [WordPack] = [footballPlayers]
}
