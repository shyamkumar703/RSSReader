//
//  GetFeedRequest.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation

struct GetFeedRequest: Request {
    typealias ResponseType = FeedResponse
    var method: Method = .GET
    var path: String = "entries?direction=desc&order=published_at"
    
    init(categoryId: Int? = nil) {
        if let categoryId = categoryId {
            path += "&category_id=\(categoryId)"
        }
    }
}
