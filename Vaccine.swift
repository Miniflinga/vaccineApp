//
//  Vaccine.swift
//  vaccineApp
//
//  Created by hannali on 2026-01-15.
//

import Foundation

struct Vaccine: Identifiable, Codable {
    let id = UUID
    let name: String
    let date: Date
}
