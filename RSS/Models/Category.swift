//
//  Category.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation

struct Category: Codable, Identifiable, Comparable, Hashable {
    var id: Int
    var title: String
    
    static var example = Category(id: Int.min, title: "All")
    
    static func < (lhs: Category, rhs: Category) -> Bool {
        lhs.id < rhs.id
    }
}
