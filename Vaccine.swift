//
//  Vaccine.swift
//  vaccineApp
//
//  Created by hannali on 2026-01-15.
//

import Foundation
import SwiftUI

// MARK: - Vaccine
/// Represents a vaccine entry with an optional renewal date.
/// Used across list, detail, and edit flows.
struct Vaccine: Identifiable, Codable {
    
    // MARK: - Stored properties
    let id: UUID
    let name: String
    let date: Date
    var renewalDate: Date?
    
    // MARK: - Display attributes
    
    // Dynamic icon based on name
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
    
    // Dynamic color based on name
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
    
    // MARK: - Renewal logic
    
    /// Expiration check
    var isExpired: Bool {
        guard let renewalDate else { return false }
        return renewalDate < Date()
    }

    /// Number of days until renewal (no renewal → nil)
    var daysUntilRenewal: Int? {
        guard let renewalDate else { return nil }
        return Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: renewalDate
        ).day
    }

    // MARK: - Status presentation
    
    /// Renewal status text
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
    
    /// Months and years until renewal date
    var renewalMonthYearText: String? {
        guard let renewalDate else { return nil }

        return renewalDate.formatted(
            .dateTime
                .month(.wide)
                .year()
                .locale(.autoupdatingCurrent)
        )
    }
    
    /// Renewal status ikon
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

    /// Renewal status color
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
    
    // MARK: - Attention status badge
    
    enum AttentionLevel {
        case none
        case warning   // ≤ 30 days remaining
        case overdue   // renewal overdue
    }

    /// Attention indication
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
