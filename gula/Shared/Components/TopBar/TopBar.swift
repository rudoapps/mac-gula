//
//  TopBar.swift
//  Gula
//
//  Created by Claude Code
//

import SwiftUI

@available(macOS 15.0, *)
struct TopBar: View {
    let onLogout: () -> Void

    var body: some View {
        HStack {
            // Logo/Title on the left
            HStack(spacing: 8) {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.blue)

                Text("Gula")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }

            Spacer()

            // User menu on the right
            UserMenuButton(onLogout: onLogout)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Color(NSColor.controlBackgroundColor)
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        )
    }
}

// MARK: - Preview
@available(macOS 15.0, *)
struct TopBar_Previews: PreviewProvider {
    static var previews: some View {
        TopBar {
            print("Logout")
        }
        .frame(width: 600)
    }
}
