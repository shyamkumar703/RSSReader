//
//  Category.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation

class Category: Codable, Identifiable, Comparable, Hashable {
    var id: Int
    var title: String
    var unreadCount: Int?
    
    static var example = Category(id: Int.min, title: "All")
    
    init(id: Int, title: String, unreadCount: Int? = 0) {
        self.id = id
        self.title = title
        self.unreadCount = unreadCount
    }
    
    static func < (lhs: Category, rhs: Category) -> Bool {
        (lhs.unreadCount ?? 0) > (rhs.unreadCount ?? 0)
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
