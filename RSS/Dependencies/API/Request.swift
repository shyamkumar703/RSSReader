//
//  Request.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation

protocol Request {
    associatedtype ResponseType: Codable
    var method: Method { get }
    var path: String { get }
    var dateDecodingStrategy: Foundation.JSONDecoder.DateDecodingStrategy { get }
}

extension Request {
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
