//
//  MarkAsReadRequest.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation

struct IgnoreResponse: Codable {}

struct MarkItemRequestBody: Codable {
    var entryIds: [Int]
    var status: FeedEntry.Status
    
    enum CodingKeys: String, CodingKey {
        case entryIds = "entry_ids"
        case status
    }
}

struct MarkItemRequest: Request {
    typealias ResponseType = IgnoreResponse
    var method: Method = .PUT
    var path: String = "entries"
    var body: MarkItemRequestBody
    
    init(entryIds: [Int], status: FeedEntry.Status) {
        self.body = MarkItemRequestBody(entryIds: entryIds, status: status)
    }
}
