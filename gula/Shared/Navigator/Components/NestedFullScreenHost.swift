//
//  NestedFullScreenHost.swift
//  Gula
//
//  Created by Joan Cremades on 18/8/24.
//

import SwiftUI

struct NestedFullScreenHost<Content: View>: View {
    @State private var navigator: NavigatorProtocol
    private let content: Content

    init(navigator: NavigatorProtocol = Navigator.shared, @ViewBuilder content: () -> Content) {
        self._navigator = State(initialValue: navigator)
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color(.lightGray).ignoresSafeArea()
            content
        }
        .sheet(item: $navigator.fullOverSheet) { page in
            ZStack {
                Color(.lightGray).ignoresSafeArea()
                page
            }
            .sheet(item: $navigator.fullOverNestedSheet) { nested in
                ZStack {
                    Color(.lightGray).ignoresSafeArea()
                    nested
                }
            }
        }
    }
}
