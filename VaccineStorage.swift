//
//  VaccineStorage.swift
//  vaccineApp
//
//  Created by hannali on 2026-01-15.
//

import Foundation

// MARK: - VaccineStorage
/// Handles saving and loading vaccines using UserDefaults.
class VaccineStorage {

    // Key used to store vaccines in UserDefaults
    private let key = "savedVaccines"

    // MARK: - Save
    /// Saves the given vaccines to UserDefaults.
    func save(_ vaccines: [Vaccine]) {
        if let data = try? JSONEncoder().encode(vaccines) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // MARK: - Load
    /// Loads vaccines from UserDefaults.
    /// Returns an empty array if nothing is saved.
    func load() -> [Vaccine] {
        if let data = UserDefaults.standard.data(forKey: key),
           let vaccines = try? JSONDecoder().decode([Vaccine].self, from: data) {
            return vaccines
        }
        return []
    }
}
