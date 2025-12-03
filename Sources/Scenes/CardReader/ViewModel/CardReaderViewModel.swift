//
//  CardReaderViewModel.swift
//  PokéScan
//
//  Created by João Guilherme on 26/11/25.
//
import SwiftUI
import Vision

@MainActor
final class CardReaderViewModel: ObservableObject {
    @Published var cardName: String = .empty
    @Published var collection1: String = .empty
    @Published var collection2: String = .empty
    @Published var card: Card?
    @Published var isLoading = false
    @Published var detectedText: String = String.empty
    
    private let service = CardService()
    private let reader = LiveTextReader()
    
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
    
    func handleFrame(_ buffer: CVPixelBuffer) {
        reader.detectText(pixelBuffer: buffer) { [weak self] strings in
            guard let self else { return }
            Task { @MainActor in
                self.detectedText = strings.joined(separator: "/")
            }
        }
    }
}


