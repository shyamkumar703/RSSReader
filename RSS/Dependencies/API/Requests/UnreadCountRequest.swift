//
//  UnreadCountRequest.swift
//  RSS
//
//  Created by Shyam Kumar on 1/19/23.
//

import Foundation

struct UnreadCountResponse: Codable {
    var unreads: [String: Int]
}

struct UnreadCountRequest: Request {
    typealias ResponseType = UnreadCountResponse
    var method: Method = .GET
    var path: String
    var body: NoBody = NoBody()
    
    init() {
        self.path = "feeds/counters"
    }
}
