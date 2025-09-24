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
        .navigationTitle("common_help")
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private func mainView(config: ChatConfiguration) -> some View {
        VStack {
            Color.hex(.blueCloud)
                .frame(height: 1)
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.messages, id: \.self) { message in
                            ChatMessageView(message: message,
                                            config: config) { [weak viewModel] in
                                viewModel?.resendMessage()
                            }
                                .id(message)
                        }
                    }
                    .onChange(of: viewModel.messages) { _, _ in
                        DispatchQueue.main.async {
                            scrollTo(viewModel.messages.last,
                                     scrollView: scrollView)
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
                Color.hex(.blueCloud)
                    .frame(height: 1)
                HStack(alignment: .bottom, spacing: 8) {
                    ProfessionalTextView(
                        placeholder: "chat_writeHere",
                        text: $viewModel.newMessage,
                        minHeight: 54,
                        maxHeight: 120
                    )

                    Button(action: {
                        viewModel.checkIfCanSendMessage()
                    }, label: {
                        Image(systemName: "paperplane")
                            .foregroundStyle(Color(hex: config.secondaryColor))
                            .frame(width: 54, height: 54)
                            .background(RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: config.primaryColor)))
                    })
                    .buttonStyle(.plain)
                }
                .padding(.leading, 12)
                .padding(.top, 4)
                .padding(.bottom, 16)
            }
        }
    }

    private func scrollTo(_ item: Message?, scrollView: ScrollViewProxy) {
        withAnimation {
            scrollView.scrollTo(item,
                                anchor: .bottom)
        }
    }
}
