//
//  AllDependencies.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation

protocol AllDependencies: HasAPI {}

protocol HasAPI {
    var api: API { get set }
}

protocol HasSession {
    var session: Session { get set }
}

class Dependencies: AllDependencies, ObservableObject {
    var api: API = APIManager()
}
