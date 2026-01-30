//
//  ContentView.swift
//  vaccineApp
//
//  Created by hannali on 2026-01-03.
//

import SwiftUI

struct ContentView: View {
    
    private let storage = VaccineStorage()

    @State private var vaccines: [Vaccine] = []
    
    // Filter
    private enum VaccineFilter: String, CaseIterable, Identifiable {
        case all = "Alla"
        case overdue = "Utgångna"
        case expiring = "Snart utgångna"
        case noRenewal = "Ingen förnyelse"

        var id: String { rawValue }
        
        // Ikoner
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

    @State private var filter: VaccineFilter = .all
    
    var body: some View {
             
        NavigationStack {
            List {
                if vaccines.isEmpty {
                    Text("Inga vaccinationer ännu")
                        .foregroundColor(.secondary)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(visibleVaccines) { vaccine in
                        NavigationLink {
                            AddVaccineView(existingVaccine: vaccine) { updatedVaccine in
                                if let index = vaccines.firstIndex(where: { $0.id == updatedVaccine.id }) {
                                    vaccines[index] = updatedVaccine
                                    NotificationManager.shared.removeReminder(for: updatedVaccine)
                                    NotificationManager.shared.scheduleReminder(for: updatedVaccine)
                                    storage.save(vaccines)
                                }
                            }
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: vaccine.iconName)
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(vaccine.color)
                                    .cornerRadius(10)

                                VStack(alignment: .leading, spacing: 4) {
                                    // Namn
                                    Text(vaccine.name)
                                        .font(.headline)

                                    // Datum
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
                                    
                                    // Förnyelse - dagar kvar / försenad dagar
                                    if let days = vaccine.daysUntilRenewal,
                                       let monthYear = vaccine.renewalMonthYearText {

                                        if days > 30 {
                                            Text("Går ut \(monthYear)")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }; if days <= 30 && days >= 0 {
                                           Text("\(days) dagar kvar")
                                               .font(.caption2)
                                               .foregroundColor(.secondary)
                                        } else if days < 0 {
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
                            .overlay(alignment: .topTrailing) { // Badge baserad på förnyelse
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
            
            .onAppear { vaccines = storage.load() }
            
            .navigationTitle("Vaccinationer")
            
            .toolbar {
                // Nytt vaccin
                NavigationLink {
                    AddVaccineView { newVaccine in
                        vaccines.append(newVaccine)
                        storage.save(vaccines)
                    }
                } label: {
                    Image(systemName: "plus")
                    
                    // Filtrering
                    Menu {
                        Picker("Filter", selection: $filter) {
                            ForEach(VaccineFilter.allCases) { f in
                                Label {
                                    Text(f.rawValue)
                                } icon: {
                                    Image(systemName: f.iconName)
                                }
                                .tag(f)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                EditButton()
            }
        }
    }
    
    // Deletea vaccin
    private func deleteVaccine(at offsets: IndexSet) {
        let toDelete = offsets.map { visibleVaccines[$0] }

        for vaccine in toDelete {
                NotificationManager.shared.removeReminder(for: vaccine)
            }

            vaccines.removeAll { v in
                toDelete.contains(where: { $0.id == v.id })
            }
        
        storage.save(vaccines)
    }
    
    // Prioritering
    private func priorityRank(for vaccine: Vaccine) -> Int {
        if vaccine.isExpired { return 0 }                                           // Primärt - vaccin som gått ut
        if let days = vaccine.daysUntilRenewal, days > 0 && days <= 30 { return 1 } // Sekundärt - utgång inom 30 dagar
        return 2                                                                    // Tetriärt - ingen förnyelse eller utgång om mer än 30 dagar
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

        // Sortering
        return filtered.sorted { lhs, rhs in
            let a = priorityRank(for: lhs)
            let b = priorityRank(for: rhs)
            
            // 1. Prioritet
            if a != b { return a < b }
            
            // 2. Närmast renewalDate först (utan renewalDate sist)
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
            
            // 3. Närmast vaccinationsdatum (date) först
            if lhs.date != rhs.date { return lhs.date > rhs.date }
            
            // 4. Fallback: Bokstavsordning
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }
}

extension Color {
    static var secondarySystemBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.secondarySystemBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.secondary
        #endif
    }
}

#Preview {
        ContentView()
    }

