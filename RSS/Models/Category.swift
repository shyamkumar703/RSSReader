//
//  Category.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation

struct Category: Codable, Identifiable, Comparable {
    var id: Int
    var title: String
    
    static func < (lhs: Category, rhs: Category) -> Bool {
        lhs.id < rhs.id
    }
}
