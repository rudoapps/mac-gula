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

    var body: some View {
        switch message.type {
        case .user:
            HStack {
                Spacer()
                Text(message.message)
                    .font(.system(size: 15))
                    .padding(.all, 12)
                    .background(RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#F9F9F9")))
            }
            .padding(.leading, 56)
            .padding(.trailing, 16)
            .padding(.top, 12)
        case .bot:
            HStack {
                Text(message.message)
                    .font(.system(size: 15))
                    .padding(.all, 12)
                    .background(RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: config.primaryColor, opacity: 0.4)))
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.trailing, 56)
            .padding(.top, 12)
        case .loading:
            HStack {
                Text(message.message)
                    .font(.system(size: 15))
                    .padding(.all, 12)
                    .foregroundStyle(Color(hex: config.textColor, opacity: 0.4))
                    .background(RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: config.primaryColor, opacity: 0.4)))
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.trailing, 56)
            .padding(.top, 12)
        case .error:
            HStack {
                Text(message.message)
                    .foregroundStyle(Color(hex: config.textColor))
                    .padding([.leading, .vertical], 12)
                    .font(.system(size: 15))
                Button {
                    action()
                } label: {
                    Text("common_tryAgain")
                        .foregroundStyle(Color(hex: config.textColor))
                        .font(.system(size: 15))
                        .underline()
                }
                .padding(.trailing, 12)
            }
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.15)))
            .padding(.horizontal, 25)
            .padding(.top, 12)
        case .warning:
            HStack {
                Spacer()
                HStack(alignment: .bottom) {
                    Text(message.message)
                        .font(.system(size: 15))
                        .padding([.leading, .vertical], 12)
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .padding([.trailing, .vertical], 12)
                }
                .background(RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#F9F9F9")))
            }
            .padding(.leading, 56)
            .padding(.trailing, 16)
            .padding(.top, 12)
        }
    }
}
