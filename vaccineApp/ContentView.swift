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
    
    var body: some View {
             
        NavigationStack {
            List {
                if vaccines.isEmpty {
                    Text("Inga vaccinationer ännu")
                        .foregroundColor(.secondary)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(vaccines) { vaccine in
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
            
            .onAppear {
                vaccines = storage.load()
            }
            
            .navigationTitle("Vaccinationer")
            
            .toolbar {
                NavigationLink {
                    AddVaccineView { newVaccine in
                        vaccines.append(newVaccine)
                        storage.save(vaccines)
                    }
                } label: {
                    Image(systemName: "plus")
                }
                EditButton()
            }
        }
    }
    private func deleteVaccine(at offsets: IndexSet) {
        for index in offsets {
            let vaccine = vaccines[index]
            NotificationManager.shared.removeReminder(for: vaccine)
        }
        vaccines.remove(atOffsets: offsets)
        storage.save(vaccines)
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

