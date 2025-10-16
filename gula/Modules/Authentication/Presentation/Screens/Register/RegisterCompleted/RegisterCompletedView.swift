//
//  RegisterCompletedView.swift
//  Gula
//
//  Created by María on 5/8/24.
//

import SwiftUI

@available(macOS 15.0, *)
struct RegisterCompletedView: View {
    @ObservedObject var viewModel: RegisterCompletedViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 50) {
                Text(Config.appName)
                    .font(.system(size: 20))
                    .padding(.top, 18)
                Image(systemName: "pencil")
                    .frame(width: 100, height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(.gray)
                    )

                VStack(spacing: 35) {
                    Text("auth_RegisterCompletedTitle")
                        .font(.system(size: 20))
                    Text("auth_registerCompleted")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 34)
                        .font(.system(size: 18))
                    Button {
                        // TODO: -  Remove in destination app
                        viewModel.goToMainMenu()
                    } label: {
                        Text("auth_goBackToHome")
                            .font(.system(size: 14))
                            .foregroundStyle(.black)
                            .underline()
                    }
                }
                Spacer()
            }
            #if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
            #endif
            .padding(.horizontal, 16)
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    if #available(macOS 15.0, *) {
        RegisterCompletedBuilder().build()
    }
}
