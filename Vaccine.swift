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
    
    // Dynamisk ikon per vaccin
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
    
    // Dynamisk statusikon beroende på utgångsstatus
    var statusIcon: String {
        if isExpired {
            return "exclamationmark.triangle.fill"
        } else if daysUntilRenewal <= 30 {
            return "clock.fill"
        } else {
            return "checkmark.circle.fill"
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
    
    // Dynamisk statusfärg beroende på utgångsstatus
    var statusColor: Color {
        if isExpired {
            return .red
        } else if daysUntilRenewal <= 30 {
            return .orange
        } else {
            return .green
        }
    }
    
    // Förnyelse datum till ett år från dagens datum
    var renewalDate: Date {
        Calendar.current.date(byAdding: .year, value: 1, to: date) ?? date
    }
    
    // Avgör om utgången
    var isExpired: Bool {
        renewalDate < Date()
    }

    // Avgör dagar till utgången
    var daysUntilRenewal: Int {
        Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: renewalDate
        ).day ?? 0
    }

    // Meddelande för utgångsstatus
    var statusText: String {
        if isExpired {
            return "Förnyelse försenad"
        } else if daysUntilRenewal <= 30 {
            return "Förnyas snart"
        } else {
            return "Giltig"
        }
    }

}
