//
//  CardService.swift
//  PokéScan
//
//  Created by João Guilherme on 26/11/25.
//

final class CardService {
    
    private let client = NetworkClient()
    
    func readPokemonCard(name: String, collection1: String, collection2: String) async throws -> Card {
        try await client.request(ReadCardEndpoint(name: name, collection1: collection1, collection2: collection2), as: Card.self)
    }
}
