//
//  AllDependencies.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation

protocol AllDependencies: HasAPI, HasLocalStorage {}

protocol HasAPI {
    var api: API { get set }
}

protocol HasSession {
    var session: Session { get set }
}

protocol HasLocalStorage {
    var localStorage: LocalStorage { get set }
}

class Dependencies: AllDependencies, ObservableObject {
    var localStorage: LocalStorage = LocalStorageManager()
    var api: API = APIManager()
}
