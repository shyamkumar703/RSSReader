//
//  GetCategoriesRequest.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation

struct GetCategoriesRequest: Request {
    typealias ResponseType = Array<Category>
    var method: Method = .GET
    var path: String = "categories"
}
