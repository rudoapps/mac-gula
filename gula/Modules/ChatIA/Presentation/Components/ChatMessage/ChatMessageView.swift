//
//  ChatMessageView.swift
//
//
//  Created by Axel Pérez Gaspar on 29/7/24.
//

import SwiftUI

struct ChatMessageView: View {
    let message: Message
    let config: ChatConfiguration
    let action: (() -> Void)
    let currentAction: ChatViewModel.ExecutingAction?
    let actionProgress: Double

    var body: some View {
        switch message.type {
        case .user:
            HStack {
                Spacer()
                Text(message.message)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.8), Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .frame(maxWidth: .infinity * 0.8, alignment: .trailing)
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 8)
        case .bot:
            HStack(alignment: .top, spacing: 8) {
                // Bot avatar
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: config.primaryColor), Color(hex: config.primaryColor).opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

                HStack(alignment: .bottom) {
                    Text(message.message)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)

                    // Show logs button if available
                    if let logs = message.logs, !logs.isEmpty {
                        MessageLogsButton(logs: logs)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(NSColor.systemGray).opacity(0.15),
                                    Color(NSColor.systemGray).opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
                        )
                )
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                .frame(maxWidth: .infinity * 0.8, alignment: .leading)

                Spacer()
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 8)
        case .loading:
            HStack(alignment: .top, spacing: 8) {
                // Bot avatar with animated loading
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: config.primaryColor), Color(hex: config.primaryColor).opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .scaleEffect(0.8)
                            .opacity(0.7)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            .scaleEffect(1.1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

                VStack(alignment: .leading, spacing: 8) {
                    Text(message.message)
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    // Show inline progress if there's a current action
                    if let currentAction = currentAction {
                        InlineActionProgressView(
                            executingAction: currentAction,
                            progress: actionProgress
                        )
                        .fixedSize()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(NSColor.systemGray).opacity(0.2),
                                    Color(NSColor.systemGray).opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
                        )
                )
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                .frame(maxWidth: .infinity * 0.8, alignment: .leading)

                Spacer()
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 8)
        case .error:
            HStack(spacing: 12) {
                // Error icon
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.red.opacity(0.8), Color.red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "exclamationmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 8) {
                    Text(message.message)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.red)

                    Button {
                        action()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 12, weight: .medium))
                            Text(LocalizedStringKey("common_tryAgain"))
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.red.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.red.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.red.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: Color.red.opacity(0.1), radius: 8, x: 0, y: 2)
            .padding(.horizontal, 25)
            .padding(.top, 8)
        case .warning:
            HStack {
                Spacer()
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.orange)

                    Text(message.message)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.orange.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                        )
                )
                .shadow(color: Color.orange.opacity(0.1), radius: 4, x: 0, y: 2)
                .frame(maxWidth: .infinity * 0.8, alignment: .trailing)
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 8)
        }
    }
}
