//
//  ContentView.swift
//  vaccineApp
//
//  Created by hannali on 2026-01-03.
//

import SwiftUI

// MARK: ContentView
/// Main list screen showing saved vaccines.
/// Handles filtering, sorting, and navigation to detail/edit flows.
struct ContentView: View {
    
    // MARK: - Storage
    private let storage = VaccineStorage()

    // MARK: - State
    @State private var vaccines: [Vaccine] = []
    @State private var filter: VaccineFilter = .all
    
    // MARK: - Filter
    private enum VaccineFilter: String, CaseIterable, Identifiable {
        case all = "Alla"
        case overdue = "Utgångna"
        case expiring = "Snart utgångna"
        case noRenewal = "Ingen förnyelse"

        var id: String { rawValue }
        
        // MARK: - Filter icons
        var iconName: String {
            switch self {
            case .all:
                return "list.bullet"
            case .overdue:
                return "xmark.circle.fill"
            case .expiring:
                return "clock.fill"
            case .noRenewal:
                return "checkmark.circle"
            }
        }
    }
    
    // MARK: - Data updates
        
    // Edit vaccine logic
    private func upsertVaccine(_ vaccine: Vaccine) {
        if let index = vaccines.firstIndex(where: { $0.id == vaccine.id }) {
            vaccines[index] = vaccine
        } else {
            vaccines.append(vaccine)
        }

        // Notifications (remove and reschedule)
        NotificationManager.shared.removeReminder(for: vaccine)
        if vaccine.renewalDate != nil {
            NotificationManager.shared.scheduleReminder(for: vaccine)
        }
        
        storage.save(vaccines)
    }

    // Delete vaccine logic
    private func deleteVaccine(_ vaccine: Vaccine) {
        NotificationManager.shared.removeReminder(for: vaccine)
        vaccines.removeAll { $0.id == vaccine.id }
        storage.save(vaccines)
    }

    private func deleteVaccine(at offsets: IndexSet) {
        let toDelete = offsets.map { visibleVaccines[$0] }
        toDelete.forEach { deleteVaccine($0) }
    }
    
    // MARK: - Body
    var body: some View {
             
        NavigationStack {
            List {
                if visibleVaccines.isEmpty {
                    Text("Inga vaccinationer ännu")
                        .foregroundColor(.secondary)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(visibleVaccines) { vaccine in
                        NavigationLink {
                            DetailVaccineView(
                                vaccine: vaccine,
                                
                                // Edit vaccine
                                onUpdate: { updatedVaccine in
                                    upsertVaccine(updatedVaccine)
                                },
                                
                                // Delete vaccine
                                onDelete: { deletedVaccine in
                                    deleteVaccine(deletedVaccine)
                                }
                            )
                        } label: {
                            // Vaccine row
                            HStack(spacing: 16) {
                                Image(systemName: vaccine.iconName)
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(vaccine.color)
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    // Name
                                    Text(vaccine.name)
                                        .font(.headline)
                                    
                                    // Date
                                    Text(vaccine.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    // Status
                                    HStack(spacing: 6) {
                                        Image(systemName: vaccine.statusIcon)
                                            .foregroundColor(vaccine.statusColor)
                                        
                                        Text(vaccine.statusText)
                                        
                                    }
                                    .font(.caption)
                                    .foregroundColor(vaccine.statusColor)
                                    
                                    // Renewal info (days remaining / expired)
                                    if let days = vaccine.daysUntilRenewal,
                                       let monthYear = vaccine.renewalMonthYearText {
                                        
                                        if days > 30 {
                                            Text("Går ut \(monthYear)")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        } else if days >= 0 {
                                            Text("\(days) dagar kvar")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        } else {
                                            Text("Gick ut \(monthYear)")
                                                .font(.caption2)
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.secondarySystemBackground)
                            .cornerRadius(16)
                            .overlay(alignment: .topTrailing) {
                                // Attention badge
                                if vaccine.attentionLevel != .none {
                                    
                                    let badgeColor: Color = vaccine.attentionLevel == .overdue ? .red : .orange
                                    
                                    Circle()
                                        .fill(badgeColor.opacity(0.85))
                                        .frame(width: 10, height: 10)
                                        .background(
                                            Circle()
                                                .fill(.ultraThinMaterial)
                                        )
                                        .padding(8)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteVaccine)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            
            .listStyle(.plain)
            
            // Load saved vaccines when the view appears
            .onAppear { vaccines = storage.load() }
            
            .navigationTitle("Vaccinationer")
            
            // MARK: - Toolbar
            .toolbar {
                // Add new vaccine
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddVaccineView { newVaccine in upsertVaccine(newVaccine) }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                    
                // Filter menue
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Filter", selection: $filter) {
                            ForEach(VaccineFilter.allCases) { f in
                                Label(f.rawValue, systemImage: f.iconName).tag(f)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                
                // Swipe-to-delete mode
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
        }
    }
    
    // MARK: - Sorting & filtering
    
    // Priority used for sorting
    /// 0 = expired, 1 = expiring soon (≤ 30 days), 2 = everything else
    private func priorityRank(for vaccine: Vaccine) -> Int {
        if vaccine.isExpired { return 0 }
        if let days = vaccine.daysUntilRenewal, days > 0 && days <= 30 { return 1 }
        return 2
    }

    // Filtrering
    private var visibleVaccines: [Vaccine] {
        let filtered: [Vaccine] = vaccines.filter { v in
            switch filter {
            case .all:
                return true
                
            case .overdue:
                return v.isExpired
                
            case .expiring:
                guard let days = v.daysUntilRenewal else { return false }
                return days > 0 && days <= 30
                
            case .noRenewal:
                return v.renewalDate == nil
            }
        }

        // Sortering (based on priority, then most recent vaccination date)
        return filtered.sorted { lhs, rhs in
            let a = priorityRank(for: lhs)
            let b = priorityRank(for: rhs)
            
            // 1. Priority
            if a != b { return a < b }
            
            // 2. Nearest renewal date first (nil last)
            switch (lhs.renewalDate, rhs.renewalDate) {
                case let (da?, db?) where da != db:
                    return da < db
                case (nil, _?):
                    return false
                case (_?, nil):
                    return true
                default:
                    break
                }
            
            // 3. Most recent vaccination date first
            if lhs.date != rhs.date { return lhs.date > rhs.date }
            
            // 4. Fallback: Name
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }
}

// MARK: - Preview
#Preview {
        ContentView()
    }

