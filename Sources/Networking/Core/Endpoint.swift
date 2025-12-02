//
//  Endpoint.swift
//  PokéScan
//
//  Created by João Guilherme on 26/11/25.
//
import Foundation

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var query: [URLQueryItem]? { get }
    var body: Encodable? { get } 
    
    func makeRequest() throws -> URLRequest
}

extension Endpoint {
    var baseURL: String { "http://localhost:3000" }
    var query: [URLQueryItem]? { nil }
    var body: Encodable? { nil }
    
    func makeRequest() throws -> URLRequest {
        guard var components = URLComponents(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = query
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }
        
        request.httpMethod = method.rawValue
        return request
    }
}
