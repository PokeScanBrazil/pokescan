//
//  NetworkClient.swift
//  PokéScan
//
//  Created by João Guilherme on 26/11/25.
//
import Foundation

final class NetworkClient {
    
    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        do {
            let request = try endpoint.makeRequest()
            
            logRequest(request)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            logResponse(data: data, response: response)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(NSError(domain: "No response", code: 0))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.badStatus(httpResponse.statusCode)
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch let decodeErr {
                print("❌ [Decoding Error]: \(decodeErr.localizedDescription)")
                throw NetworkError.decoding(decodeErr)
            }
        }
        catch let err as NetworkError {
            print("❌ [NetworkError]: \(err)")
            throw err
        }
        catch {
            print("❌ [Unknown Error]: \(error.localizedDescription)")
            throw NetworkError.unknown(error)
        }
    }
}

extension NetworkClient {
    
    private func logRequest(_ request: URLRequest) {
        print("\n🔵 ——— REQUEST ———")
        print("➡️ URL: \(request.url?.absoluteString ?? "nil")")
        print("➡️ Method: \(request.httpMethod ?? "nil")")
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("➡️ Headers:")
            headers.forEach { print("   \( $0.key ): \( $0.value )") }
        } else {
            print("➡️ Headers: none")
        }
        
        if let body = request.httpBody {
            print("➡️ Body:")
            if let json = try? JSONSerialization.jsonObject(with: body, options: []),
               let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let string = String(data: pretty, encoding: .utf8) {
                print(string)
            } else {
                print("   <unable to print body>")
            }
        } else {
            print("➡️ Body: none")
        }
        
        print("🔵 ————————————\n")
    }
    
    private func logResponse(data: Data, response: URLResponse) {
        print("\n🟢 ——— RESPONSE ———")

        if let http = response as? HTTPURLResponse {
            print("⬅️ Status Code: \(http.statusCode)")
            print("⬅️ URL: \(http.url?.absoluteString ?? "nil")")
        }

        print("⬅️ Raw Data Size: \(data.count) bytes")

        if let json = try? JSONSerialization.jsonObject(with: data, options: []),
           let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let string = String(data: pretty, encoding: .utf8) {
            print("⬅️ Body:")
            print(string)
        } else if let string = String(data: data, encoding: .utf8) {
            print("⬅️ Body (raw):")
            print(string)
        } else {
            print("⬅️ Body: <unable to decode>")
        }
        
        print("🟢 —————————————\n")
    }
}
