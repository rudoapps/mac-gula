//
//  SocialLoginButton.swift
//  Gula
//
//  Created by Axel Pérez Gaspar on 27/8/24.
//

import SwiftUI

enum SocialButtonType {
    case apple, google

    var text: LocalizedStringKey {
        switch self {
        case .apple:
            "common_continueWithApple"
        case .google:
            "common_continueWithGoogle"
        }
    }

    var foregroundColor: Color {
        switch self {
        case .apple:
                .white
        case .google:
                .black.opacity(0.5)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .apple:
                .black
        case .google:
                .white
        }
    }

    var image: Image {
        switch self {
        case .apple:
            Image(systemName: "applelogo")
        case .google:
            Image(.logoGoogle)
        }
    }
}

struct SocialLoginButton: View {
    let buttonType: SocialButtonType
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }, label: {
            HStack {
                buttonType.image
                Spacer()
                Text(buttonType.text)
                    .font(.system(size: 16))
                Spacer()
            }
        })
        .padding()
        .foregroundStyle(buttonType.foregroundColor)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(buttonType.backgroundColor)
                .stroke(.black, lineWidth: 1)
        )
    }
}
