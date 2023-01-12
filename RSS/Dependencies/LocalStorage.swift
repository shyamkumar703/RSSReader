//
//  LocalStorage.swift
//  RSS
//
//  Created by Shyam Kumar on 1/12/23.
//

import Foundation

enum Key: String {
    case feedDictionary
    case categories
    
    var savePath: URL {
        FileManager.documentsDirectory.appendingPathComponent(rawValue)
    }
}

protocol LocalStorage {
    func save<T: Codable>(_ obj: T, for key: Key)
    func read<T: Codable>(from key: Key, type: T.Type) -> T?
}

class LocalStorageManager: LocalStorage {
    func save<T: Codable>(_ obj: T, for key: Key) {
        do {
            let data = try JSONEncoder().encode(obj)
            try data.write(to: key.savePath)
        } catch {
            print("Unable to save!!!")
        }
    }
    
    func read<T: Codable>(from key: Key, type: T.Type) -> T? {
        do {
            let data = try Data(contentsOf: key.savePath)
            let object = try JSONDecoder().decode(type, from: data)
            return object
        } catch {
            return nil
        }
    }
}
