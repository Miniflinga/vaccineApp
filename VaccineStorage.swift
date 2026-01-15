//
//  VaccineStorage.swift
//  vaccineApp
//
//  Created by hannali on 2026-01-15.
//

import Foundation

class VaccineStorage {

    private let key = "savedVaccines"

    func save(_ vaccines: [Vaccine]) {
        if let data = try? JSONEncoder().encode(vaccines) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func load() -> [Vaccine] {
        if let data = UserDefaults.standard.data(forKey: key),
           let vaccines = try? JSONDecoder().decode([Vaccine].self, from: data) {
            return vaccines
        }
        return []
    }
}
