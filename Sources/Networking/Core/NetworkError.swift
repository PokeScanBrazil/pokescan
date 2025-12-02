//
//  NetworkError.swift
//  PokéScan
//
//  Created by João Guilherme on 26/11/25.
//

enum NetworkError: Error {
    case invalidURL
    case badStatus(Int)
    case decoding(Error)
    case unknown(Error)
}
