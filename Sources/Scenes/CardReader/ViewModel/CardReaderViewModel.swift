//
//  CardReaderViewModel.swift
//  PokéScan
//
//  Created by João Guilherme on 26/11/25.
//
import SwiftUI

@MainActor
final class CardReaderViewModel: ObservableObject {
    @Published var cardName: String = .empty
    @Published var collection1: String = .empty
    @Published var collection2: String = .empty
    @Published var card: Card?
    @Published var isLoading = false
    
    private let service = CardService()
    
    func readPokemonCard() async {
        isLoading = true
        defer { isLoading = false }
        do {
            card = nil
            let response = try await service.readPokemonCard(name: cardName, collection1: collection1, collection2: collection2)
            card = response
        } catch {
            print("❌ Error:", error)
        }
    }
}


