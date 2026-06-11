//
//  WelcomeView.swift
//  spy-game-v2
//
//  Created by Алихан on 10.05.2026.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(GameSession.self) private var session

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "person.3.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)

            Text("Игра в шпиона")
                .font(.system(size: 48, weight: .bold, design: .rounded))

            Text("Найдите шпиона среди друзей!\n\nБольшинство игроков получают одинаковое слово, но шпион получает другое. Обсуждайте и голосуйте, чтобы поймать шпиона!")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)

            Spacer()

            Button {
                session.isActive = true
            } label: {
                Text("Начать новую игру")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue.gradient)
                    .clipShape(.rect(cornerRadius: 16))
                    .padding(.horizontal, 40)
            }

            Spacer()
                .frame(height: 60)
        }
    }
}

#Preview {
    WelcomeView()
        .environment(GameSession())
}
