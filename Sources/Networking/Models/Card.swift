//
//  Card.swift
//  PokéScan
//
//  Created by João Guilherme on 26/11/25.
//

public struct Card: Decodable {
    var name: String?
    var collection_1: String?
    var collection_2: String?
    var img_url: String?
    var rarity: String?
    var card_type: String?
}
