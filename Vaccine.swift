//
//  Vaccine.swift
//  vaccineApp
//
//  Created by hannali on 2026-01-15.
//

import Foundation
import SwiftUI

struct Vaccine: Identifiable, Codable {
    let id: UUID
    let name: String
    let date: Date
    
    // Dynamiska ikoner per vaccin
    var iconName: String {
        switch name.lowercased() {
        case let n where n.contains("covid"):
            return "cross.case.fill"
        case let n where n.contains("tbe"):
            return "leaf.fill"
        case let n where n.contains("influensa"):
            return "bandage.fill"
        default:
            return "syringe.fill"
        }
    }
    
    // Dynamisk färg per vaccin
    var color: Color {
        switch name.lowercased() {
        case let n where n.contains("covid"):
            return .blue
        case let n where n.contains("tbe"):
            return .green
        case let n where n.contains("influensa"):
            return .orange
        default:
            return .teal
        }
    }
}
