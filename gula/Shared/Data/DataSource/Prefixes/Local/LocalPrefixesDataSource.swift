//
//  PrefixesDataSource.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 28/8/25.
//

import Foundation

class LocalPrefixesDataSource: LocalPrefixesDataSourceProtocol {
    func getPrefixes() -> [PrefixDTO] {
        guard let data = readJSONFromFile(fileName: "country-prefixes"),
              let prefixes = try? JSONDecoder().decode([PrefixDTO].self, from: data) else {
            return []
        }

        return prefixes
    }

    private func readJSONFromFile(fileName: String) -> Data? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            print("file not found \(fileName).json")
            return nil
        }

        do {
           return try Data(contentsOf: URL(fileURLWithPath: path))
        } catch {
            print("Error to read JSON: \(error)")
            return nil
        }
    }
}
