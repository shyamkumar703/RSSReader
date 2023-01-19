//
//  MarkCategoryAsRead.swift
//  RSS
//
//  Created by Shyam Kumar on 1/19/23.
//

import Foundation

struct MarkCategoryAsReadRequest: Request {
    typealias ResponseType = IgnoreResponse
    var method: Method = .PUT
    var path: String
    var body: NoBody = NoBody()
    
    init(categoryId: Int) {
        self.path = "categories/\(categoryId)/mark-all-as-read"
    }
}
