//
//  StarItemRequest.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation

struct StarItemRequestBody: Codable {
    var entryIds: [Int]
    var starred: Bool
    
    enum CodingKeys: String, CodingKey {
        case entryIds = "entry_ids"
        case starred
    }
}

struct StarItemRequest: Request {
    typealias ResponseType = IgnoreResponse
    var method: Method = .PUT
    var path: String = "entries"
    var body: StarItemRequestBody
    
    init(entryIds: [Int], starred: Bool) {
        self.body = StarItemRequestBody(entryIds: entryIds, starred: starred)
    }
}
