//
//  UserMenuButton.swift
//  Gula
//
//  Created by Claude Code
//

import SwiftUI

@available(macOS 15.0, *)
struct UserMenuButton: View {
    @State private var showingMenu = false
    @State private var isHovered = false
    let onLogout: () -> Void

    var body: some View {
        Menu {
            Button {
                // TODO: Navigate to profile
            } label: {
                Label("Perfil", systemImage: "person.circle")
            }

            Divider()

            Button(role: .destructive) {
                onLogout()
            } label: {
                Label("Cerrar Sesión", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            ZStack {
                // Background circle with gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.0, green: 0.48, blue: 1.0),
                                   Color(red: 0.0, green: 0.78, blue: 1.0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 26, height: 26)

                // Person icon
                Image(systemName: "person.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            .shadow(
                color: Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.4),
                radius: isHovered ? 8 : 4,
                x: 0,
                y: isHovered ? 3 : 1
            )
            .scaleEffect(isHovered ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
        }
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .onHover { hovering in
            withAnimation {
                isHovered = hovering
            }
        }
        .help("Menú de usuario")
    }
}

// MARK: - Preview
@available(macOS 15.0, *)
struct UserMenuButton_Previews: PreviewProvider {
    static var previews: some View {
        UserMenuButton {
            print("Logout tapped")
        }
        .padding()
    }
}
