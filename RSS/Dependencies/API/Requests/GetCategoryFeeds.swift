//
//  GetCategoryFeeds.swift
//  RSS
//
//  Created by Shyam Kumar on 1/19/23.
//

import Foundation

struct CategoryFeed: Codable {
    var id: Int
}

struct GetCategoryFeeds: Request {
    typealias ResponseType = [CategoryFeed]
    var method: Method = .GET
    var path: String
    var body: NoBody = NoBody()
    
    init(categoryId: Int) {
        self.path = "categories/\(categoryId)/feeds"
    }
}
