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
    @Published var detectedName: String = String.empty
    @Published var detectedCollection: String = String.empty
    
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
    
    func bindCamera(_ camera: CameraManager) {
        camera.onCardNameDetected = { [ weak self ] text in
            self?.detectedName = text
        }
        
        camera.onCollectionDetected = { [ weak self ] text in
            self?.detectedCollection = text
        }
    }
}


