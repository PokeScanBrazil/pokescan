//
//  ReadCardEndpoint.swift
//  PokéScan
//
//  Created by João Guilherme on 26/11/25.
//
import Foundation

struct CardRequestBody: Encodable {
    let name: String
    let collection_1: String
    let collection_2: String
}

struct ReadCardEndpoint: Endpoint {
    let name: String
    let collection1: String
    let collection2: String
    
    var path: String { PokeScanPaths.card.rawValue }
    var body: Encodable? {
        CardRequestBody(
                    name: name,
                    collection_1: collection1,
                    collection_2: collection2
        )
    }
    
    var method: HTTPMethod { .POST }
}
