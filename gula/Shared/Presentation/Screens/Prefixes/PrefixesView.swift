//
//  PrefixesView.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 5/9/25.
//

import SwiftUI

struct PrefixesView: View {
    @StateObject var viewModel: PrefixesViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Seleccionar Prefijo")
                .padding()
            ScrollViewReader { proxy in
                ScrollView {
                    ForEach(
                        viewModel.prefixes,
                        id: \.self
                    ) { prefix in
                        VStack {
                            Button {
                                viewModel.changeSelectedPrefix(prefix)
                            } label: {
                                HStack(alignment: .center) {
                                    Image(viewModel.selectedPrefix.id == prefix.id ? "ic_radioButton_selected" : "ic_radioButton_unselected")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    Text("\(prefix.prefix) \(prefix.name)")
                                    Spacer()
                                }
                                .id(prefix.id)
                            }
                            .tint(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)

                            if prefix.id != viewModel.prefixes.last?.id {
                                Divider()
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .onAppear {
                    proxy.scrollTo(viewModel.selectedPrefix.id, anchor: .top)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
