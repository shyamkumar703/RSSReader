//
//  Request.swift
//  
//
//  Created by Shyam Kumar on 6/11/23.
//

import Combine
import Foundation
import RSSClient

struct NoBody: Codable {}
struct IgnoreResponse: Codable {}

struct Request<ResponseType: Codable, BodyType: Codable> {
    var method: Method
    var path: String
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    var body: BodyType
    var jsonDecoder: JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = dateDecodingStrategy
        return jsonDecoder
    }
    
    enum Method: String {
        case GET
        case PUT
        case POST
        case PATCH
        case DELETE
    }
    
    private static var defaultDateDecodingStrategy: Foundation.JSONDecoder.DateDecodingStrategy {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return .formatted(formatter)
    }
    
    init(
        method: Method,
        path: String,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = Self.defaultDateDecodingStrategy,
        body: BodyType
    ) {
        self.method = method
        self.path = path
        self.dateDecodingStrategy = dateDecodingStrategy
        self.body = body
    }
    
    @discardableResult func call() -> AnyPublisher<ResponseType, Error> {
        guard let url = URL(string: "https://rss.h3klabs.com/v1/\(path)") else {
            return Fail(error: RSSError.invalidURL).eraseToAnyPublisher()
        }
        
        guard let authHeader = Self.generateBasicAuthHeader() else {
            return Fail(error: RSSError.generateAuthFailed).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Basic \(authHeader)", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = method.rawValue
        
        if BodyType.self != NoBody.self,
           let bodyData = body.data {
            urlRequest.httpBody = bodyData
        }
        
        return URLSession.DataTaskPublisher(request: urlRequest, session: .shared)
            .map { data, _ in data }
            .decode(type: ResponseType.self, decoder: jsonDecoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public static func generateBasicAuthHeader() -> String? {
        let username = "admin"
        let password = "admins3cr3t"
        return "\(username):\(password)".data(using: .utf8)?.base64EncodedString()
    }
}

extension Request {
    public static var getCategories: Request<[RSSCategory], NoBody> {
        .init(
            method: .GET,
            path: "categories",
            body: NoBody()
        )
    }

    public static func getFeed(_ id: Int? = nil, offset: Int? = nil) -> Request<FeedResponse, NoBody> {
        var path = "entries?direction=desc&order=published_at"
        if let id {
            path += "&category_id=\(id)"
        }
        
        if let offset {
            path += "&offset=\(offset)"
        }

        return .init(method: .GET, path:  path, body: NoBody())
    }
    
    struct MarkItemRequestBody: Codable {
        var entryIds: [Int]
        var status: FeedEntry.Status

        enum CodingKeys: String, CodingKey {
            case entryIds = "entry_ids"
            case status
        }
    }

    public static func mark(entryIds: [Int], status: FeedEntry.Status) -> Request<IgnoreResponse, MarkItemRequestBody> {
        .init(
            method: .PUT,
            path: "entries",
            body: MarkItemRequestBody(entryIds: entryIds, status: status)
        )
    }
    
    public static func star(_ entryId: Int) -> Request<IgnoreResponse, NoBody> {
        .init(method: .PUT, path: "entries/\(entryId)/bookmark", body: NoBody())
    }
    
    public static func markCategoryAsRead(categoryId: Int) -> Request<IgnoreResponse, NoBody> {
        .init(method: .PUT, path: "categories/\(categoryId)/mark-all-as-read", body: NoBody())
    }
}

// MARK: - Helpers
extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
    
    var data: Data? {
        guard let dictionary = dictionary else { return nil }
        return try? JSONSerialization.data(withJSONObject: dictionary as Any)
    }
}
