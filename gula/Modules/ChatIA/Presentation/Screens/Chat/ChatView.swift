//
//  ChatView.swift
//
//
//  Created by Jorge on 23/7/24.
//

import SwiftUI

struct ChatView: View {
    @State var viewModel: ChatViewModel

    var body: some View {
        VStack {
            if let configuration = viewModel.configuration {
                mainView(config: configuration)
            }
        }
        .onAppear {
            viewModel.getConfiguration()
        }
        .navigationTitle(LocalizedStringKey("common_help"))
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private func mainView(config: ChatConfiguration) -> some View {
        VStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            ChatMessageView(
                                message: message,
                                config: config,
                                action: { [weak viewModel] in
                                    viewModel?.resendMessage()
                                },
                                currentAction: viewModel.currentAction,
                                actionProgress: viewModel.actionProgress
                            )
                            .id(message.id)
                        }



                        // Phantom element at the very end for scroll targeting
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")

                    }
                    .padding(.bottom, 8)
                    .onChange(of: viewModel.messages) { _, newValue in
                        // Simple: scroll to bottom when new messages arrive
                        if !newValue.isEmpty {
                            DispatchQueue.main.async {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    // Scroll to the phantom element at the very bottom
                                    scrollView.scrollTo("bottom", anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                .onTapGesture {
                    #if os(macOS)
                    NSApp.keyWindow?.makeFirstResponder(nil)
                    #else
                    let resign = #selector(UIResponder.resignFirstResponder)
                    UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
                    #endif
                }

                VStack(spacing: 8) {
                    ProfessionalTextView(
                        placeholder: "chat_writeHere",
                        text: $viewModel.newMessage,
                        minHeight: 40,
                        maxHeight: 260,
                        onSubmit: {
                            viewModel.checkIfCanSendMessage()
                        },
                        suggestedActions: viewModel.isProjectAgent ? viewModel.suggestedActionButtons : nil,
                        onActionTap: { action in
                            viewModel.executeAction(action)
                        },
                        isExecutingAction: viewModel.currentAction != nil
                    )
                }
                .padding(.horizontal, 12)
                .padding(.top, 4)
                .padding(.bottom, 16)
            }
        }
    }

}
