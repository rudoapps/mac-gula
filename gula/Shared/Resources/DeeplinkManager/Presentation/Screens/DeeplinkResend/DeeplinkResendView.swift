//
//  Gula
//
//  DeeplinkResendView.swift
//
//  Created by Rudo Apps on 9/5/25
//

import SwiftUI

@available(macOS 15.0, *)
struct DeeplinkResendView: View {
    @StateObject var viewModel: DeeplinkResendViewModel

    var body: some View {
        VStack(spacing: 50) {
            Image(systemName: "pencil")
                .frame(width: 100, height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(.gray)
                )
            VStack(spacing: 35) {
                Text(viewModel.config.title)
                    .font(.system(size: 20))
                    .bold()
                Text(viewModel.config.message)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 34)
                    .font(.system(size: 18))
                VStack(spacing: 0) {
                    Text("auth_emailNotReceived")
                        .font(.system(size: 14))
                    Button {
                        switch viewModel.config.messageType {
                        case .emailVerification:
                            viewModel.resendLinkVerification()
                        case .recoverPassword:
                            viewModel.dismiss()
                        }
                    } label: {
                        Text("auth_sendAgain")
                            .font(.system(size: 14))
                            .bold()
                            .foregroundStyle(.black)
                            .underline()
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Config.appName)
                    .font(.system(size: 20))
                    .bold()
            }
            #if os(iOS)
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // TODO: -  Remove in destination app
                    viewModel.goToMainMenu()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.black)
                        .frame(width: 19, height: 19)
                }
            }
            #else
            ToolbarItem(placement: .automatic) {
                Button {
                    // TODO: -  Remove in destination app
                    viewModel.goToMainMenu()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.black)
                        .frame(width: 19, height: 19)
                }
            }
            #endif
        }
    }
}
