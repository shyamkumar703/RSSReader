//
//  Request.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation

struct NoBody: Codable {}

protocol Request {
    associatedtype ResponseType: Codable
    associatedtype BodyType: Codable
    var method: Method { get }
    var path: String { get }
    var dateDecodingStrategy: Foundation.JSONDecoder.DateDecodingStrategy { get }
    var body: BodyType { get }
}

extension Request {
    var body: NoBody { NoBody() }
    
    var dateDecodingStrategy: Foundation.JSONDecoder.DateDecodingStrategy {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return .formatted(formatter)
    }
}

enum Method: String {
    case GET
    case PUT
    case POST
    case PATCH
    case DELETE
}
