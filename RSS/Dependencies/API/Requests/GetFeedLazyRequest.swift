//
//  GetFeedLazyRequest.swift
//  RSS
//
//  Created by Shyam Kumar on 1/19/23.
//

import Foundation

struct GetFeedLazyRequest: Request {
    typealias ResponseType = FeedResponse
    var method: Method = .GET
    var path: String = "entries?direction=desc&order=published_at"
    
    init(categoryId: Int? = nil, before date: Date, status: Set<FeedEntry.Status> = Set([.read, .unread])) {
        if let categoryId = categoryId {
            path += "&category_id=\(categoryId)"
        }
        
        path += "&before=\(Int(date.timeIntervalSince1970))"
        
        for status in status {
            path += "&status=\(status.rawValue)"
        }
    }
}
