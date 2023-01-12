//
//  API.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation

protocol API {
    func call<RequestType: Request>(with request: RequestType) async -> Result<RequestType.ResponseType, RSSError>
}

class APIManager: API {
    private static var baseEndpoint = "https://rss.h3klabs.com/v1/"
    
    func call<RequestType: Request>(
        with request: RequestType
    ) async -> Result<RequestType.ResponseType, RSSError> {
        guard let url = URL(string: Self.baseEndpoint + request.path) else {
            return .failure(.invalidURL)
        }
        guard let authHeader = generateBasicAuthHeader() else {
            return .failure(.generateAuthFailed)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Basic \(authHeader)", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = request.method.rawValue
        
        if RequestType.BodyType.self != NoBody.self,
           let bodyData = request.body.data {
            urlRequest.httpBody = bodyData
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            if RequestType.ResponseType.self == IgnoreResponse.self {
                return .success(IgnoreResponse() as! RequestType.ResponseType)
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = request.dateDecodingStrategy
            let decodedObject = try! decoder.decode(RequestType.ResponseType.self, from: data)
            return .success(decodedObject)
        } catch let error {
            return .failure(.requestFailed(error.localizedDescription))
        }
    }
    
    private func generateBasicAuthHeader() -> String? {
        let username = "admin"
        let password = "admins3cr3t"
        return "\(username):\(password)".data(using: .utf8)?.base64EncodedString()
    }
}

enum RSSError: Error {
    case invalidURL
    case generateAuthFailed
    case requestFailed(String)
    case decodingFailed
}
