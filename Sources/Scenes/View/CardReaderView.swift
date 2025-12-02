//
//  CardReaderView.swift
//  PokéScan
//
//  Created by João Guilherme on 26/11/25.
//

import SwiftUI

struct CardReaderView: View {
    @StateObject private var viewModel = CardReaderViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Register Pokemon Card:")
            TextField("Name", text: $viewModel.cardName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            TextField("Collection 1", text: $viewModel.collection1)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            TextField("Collection 2", text: $viewModel.collection2)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Button {
                Task {
                    await viewModel.readPokemonCard()
                }
            } label: {
                Text("Create Pokémon")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(viewModel.isLoading)
            .padding(.horizontal)
            
            if let card = viewModel.card {
                Image.fromURL(card.img_url ?? .empty)
                    .scaledToFit()
                    .frame(width: 229, height: 300)
                Text(card.name ?? .empty)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.4)
                            .tint(.white)
                        
                        Text("Searching...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(24)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                }
                .transition(.opacity)
                .animation(.easeInOut, value: viewModel.isLoading)
            }
        }
    }
}

#Preview {
    CardReaderView()
}
