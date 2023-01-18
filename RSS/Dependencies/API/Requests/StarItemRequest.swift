//
//  StarItemRequest.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation

struct StarItemRequest: Request {
    typealias ResponseType = IgnoreResponse
    var method: Method = .PUT
    var path: String
    var body: NoBody = NoBody()
    
    init(entryId: Int) {
        self.path = "entries/\(entryId)/bookmark"
    }
}
