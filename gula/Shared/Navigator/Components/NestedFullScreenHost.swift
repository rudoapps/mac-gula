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
            #if canImport(UIKit)
            Color(.systemBackground).ignoresSafeArea()
            #else
            Color(NSColor.windowBackgroundColor).ignoresSafeArea()
            #endif
            content
        }
        .sheet(item: $navigator.fullOverSheet) { page in
            ZStack {
                #if canImport(UIKit)
                Color(.systemBackground).ignoresSafeArea()
                #else
                Color(NSColor.windowBackgroundColor).ignoresSafeArea()
                #endif
                page
            }
            .sheet(item: $navigator.fullOverNestedSheet) { nested in
                ZStack {
                    #if canImport(UIKit)
                    Color(.systemBackground).ignoresSafeArea()
                    #else
                    Color(NSColor.windowBackgroundColor).ignoresSafeArea()
                    #endif
                    nested
                }
            }
        }
    }
}
