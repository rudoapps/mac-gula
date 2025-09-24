//
//  ChatFloatingButton.swift
//
//
//  Created by Jorge on 22/7/24.
//

import SwiftUI

@available(macOS 15.0, *)
struct ChatFloatingButton: View {
    @State var showHelper = true
    @StateObject var viewModel: ChatFloatingButtonViewModel

    var body: some View {
        HStack {
            if let configuration = viewModel.configuration {
                mainView(config: configuration)
            }
        }
        .onAppear {
            viewModel.getConfiguration()
        }
    }

    @ViewBuilder
    private func mainView(config: ChatConfiguration) -> some View {
        HStack {
            if showHelper {
                HStack(spacing: 10) {
                    Button(action: {
                        showHelper = false
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.leading, 13)
                            .foregroundStyle(Color(hex: config.textColor, opacity: 0.4))
                    })
                    Text(config.firstMessage)
                        .padding(.trailing, 12)
                        .font(Font.system(size: 14))
                }
                .frame(height: 48)
                .background(RoundedRectangle(cornerRadius: 30)
                    .foregroundStyle(Color(hex: config.primaryColor, opacity: 0.4)))
            }
            Button {
                viewModel.goToChat()
            } label: {
                Image(systemName: "message")
                    .resizable()
                    .frame(width: 26, height: 26)
                    .foregroundStyle(Color(hex: config.secondaryColor))
                    .frame(width: 56, height: 56)
                    .background(Color(hex: config.primaryColor))
                    .clipShape(RoundedRectangle(cornerRadius: 40))
            }
        }
    }
}
