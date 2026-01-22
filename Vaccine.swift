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
    var renewalDate: Date?
    
    // Dynamisk ikon per vaccinnamn
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
    
    // Dynamisk färg per vaccinnamn
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
    
    // Avgör om utgången
    var isExpired: Bool {
        guard let renewalDate else { return false }
        return renewalDate < Date()
    }

    // Avgör dagar till utgången (nil → ingen förnyelse)
    var daysUntilRenewal: Int? {
        guard let renewalDate else { return nil }
        return Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: renewalDate
        ).day
    }

    // Meddelande för utgångsstatus
    var statusText: String {
        guard let days = daysUntilRenewal else {
            return "Giltig"
        }
        
        if days < 0 {
            return "Förnyelse försenad"
        } else if days <= 30 {
            return "Förnyas snart"
        } else {
            return "Giltig"
        }
    }
    
    // Dynamisk statusikon beroende på utgångsstatus
    var statusIcon: String {
        guard let days = daysUntilRenewal else {
            return "checkmark.circle.fill"
        }

        if days < 0 {
            return "exclamationmark.triangle.fill"
        } else if days <= 30 {
            return "clock.fill"
        } else {
            return "checkmark.circle.fill"
        }
    }

    // Dynamisk statusfärg beroende på utgångsstatus
    var statusColor: Color {
        guard let days = daysUntilRenewal else {
            return .green
        }
        
        if days < 0 {
            return .red
        } else if days <= 30 {
            return .orange
        } else {
            return .green
        }
    }
    
    // Dynamisk badge beroende på förnyelsedatum
    enum AttentionLevel {
        case none
        case warning   // snart (≤ 30 dagar)
        case overdue   // försenad
    }

    var attentionLevel: AttentionLevel {
        guard let days = daysUntilRenewal else { return .none }

        if days < 0 {
            return .overdue
        } else if days <= 30 {
            return .warning
        } else {
            return .none
        }
    }

}
