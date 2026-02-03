//
//  DetailVaccineView.swift
//  vaccineApp
//
//  Created by hannali on 2026-01-30.
//

import SwiftUI

// MARK: - DetailVaccineView
/// Displays vaccine details in a read-only form.
/// Reuses the same form UI as Add/Edit, but locked.
/// Supports editing via sheet and deletion via a confirmation alert.
struct DetailVaccineView: View {
    
    // MARK: - External input (from ContentView)
    let vaccine: Vaccine
    let onUpdate: (Vaccine) -> Void
    let onDelete: (Vaccine) -> Void
    
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Local state
    /// Local copy to keep the UI up to date after editing.
    @State private var current: Vaccine
        
    // MARK: - Form state
    @State private var vaccineName: String
    @State private var vaccinationDate: Date

    @State private var shouldRenew: Bool
    @State private var renewalYears: Int
    @State private var renewalMonths: Int
    @State private var showRenewalPicker = false
    
    // MARK: - UI state
    @State private var showEdit = false
    @State private var showDeleteConfirm = false

    // MARK: - Init
    init(
        vaccine: Vaccine,
        onUpdate: @escaping (Vaccine) -> Void,
        onDelete: @escaping (Vaccine) -> Void)
    {
        self.vaccine = vaccine
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        
        // Init current
        _current = State(initialValue: vaccine)
        
        // Init form-state from vaccin
        _vaccineName = State(initialValue: vaccine.name)
        _vaccinationDate = State(initialValue: vaccine.date)

        _shouldRenew = State(initialValue: vaccine.renewalDate != nil)

        // Renewal - Saves user edit input
        if let renewalDate = vaccine.renewalDate {
            let comps = Calendar.current.dateComponents([.year, .month], from: vaccine.date, to: renewalDate)
            _renewalYears = State(initialValue: comps.year ?? 0)
            _renewalMonths = State(initialValue: comps.month ?? 0)
        } else {
            _renewalYears = State(initialValue: 0)
            _renewalMonths = State(initialValue: 0)
        }
    }

    // MARK: - Body
    var body: some View {
        Form {
            
            /// Status section
            Section("Status") {
                HStack {
                    Label(current.statusText, systemImage: current.statusIcon)
                        .foregroundColor(current.statusColor)
                    Spacer()
                    Text(renewalSubtitle)
                        .foregroundColor(.secondary)
                        .font(.callout)
                }
                
                if let actionTitle = suggestedActionTitle {
                    Button(actionTitle) {
                        showEdit = true
                    }
                }
            }
            
            /// Vaccine form (read-only)
            VaccineFormView(
                vaccineName: $vaccineName,
                vaccinationDate: $vaccinationDate,
                shouldRenew: $shouldRenew,
                renewalYears: $renewalYears,
                renewalMonths: $renewalMonths,
                showRenewalPicker: $showRenewalPicker,
                didAttemptSave: false,
                isNameValid: true,
                isDateValid: true,
                isRenewalValid: true,
                renewalSummaryText: renewalSummaryText,
                isReadOnly: true
            )
        
            /// Delete action
            Section {
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Text("Radera vaccin")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        
        // MARK: - Delete confirmation
        .alert("Radera vaccin?", isPresented: $showDeleteConfirm) {
            //Delete
            Button("Radera", role: .destructive) {
                onDelete(current)
                dismiss()   // Returns to main view
            }
            // Cancel
            Button("Avbryt", role: .cancel) {}
        } message: {
            Text("Det går inte att ångra.")
        }
        
        .navigationTitle(current.name)
        .navigationBarTitleDisplayMode(.inline)
    
        // MARK: - Toolbar
        .toolbar {
            Button("Redigera") { showEdit = true }
        }
    
        // MARK: - Edit sheet
        .sheet(isPresented: $showEdit) {
            NavigationStack {
                AddVaccineView(existingVaccine: current) { updated in
                    handleSaveFromEdit(updated)
                }
            }
        }
    
        // MARK: - Lifecycle
        .onAppear {
            // Make sure the form shows the current vaccine data
            apply(current)
        }
    }
    
    // MARK: - Edit flow helpers
    private func handleSaveFromEdit(_ updated: Vaccine) {
        // Update the detail view with the edited vaccine
        current = updated
        apply(updated)

        // Send the updated vaccine back to the list
        onUpdate(updated)

        // Close the edit view
        showEdit = false
    }
    
    // MARK: - Derived UI
    
    private var renewalSubtitle: String {
        guard let monthYear = current.renewalMonthYearText else { return "—" }

        if let days = current.daysUntilRenewal {
            if days < 0 { return "Gick ut \(monthYear)" }
            if days <= 30 { return "\(days) dagar kvar" }
            return "Förnyas \(monthYear)"
        }
        return "Förnyas \(monthYear)"
    }

    private var suggestedActionTitle: String? {
        guard current.renewalDate != nil else { return nil }
        if current.isExpired { return "Åtgärda förnyelse" }
        if let days = current.daysUntilRenewal, days >= 0 && days <= 30 { return "Uppdatera förnyelse" }
        return nil
    }

    private var renewalSummaryText: String {
        guard shouldRenew else { return "" }

        switch (renewalYears, renewalMonths) {
        case (0, 0):
            return ""
        case (0, let months):
            return "\(months) månad\(months > 1 ? "er" : "")"
        case (let years, 0):
            return "\(years) år"
        default:
            return "\(renewalYears) år och \(renewalMonths) månader"
        }
    }
    
    // MARK: - Helpers

    /// Syncs form state from the given vaccine.
    private func apply(_ v: Vaccine) {
        vaccineName = v.name
        vaccinationDate = v.date

        shouldRenew = v.renewalDate != nil

        if let renewalDate = v.renewalDate {
            let comps = Calendar.current.dateComponents([.year, .month], from: v.date, to: renewalDate)
            renewalYears = comps.year ?? 0
            renewalMonths = comps.month ?? 0
        } else {
            renewalYears = 0
            renewalMonths = 0
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        DetailVaccineView(
            vaccine: Vaccine(
                id: UUID(),
                name: "VaccineName",
                date: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
                renewalDate: Calendar.current.date(byAdding: .year, value: 2, to: Date())
            ),
            onUpdate: { _ in },
            onDelete: { _ in }
        )
    }
}
