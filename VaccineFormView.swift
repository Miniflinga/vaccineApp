//
//  VaccineFormView.swift
//  vaccineApp
//
//  Created by hannali on 2026-01-30.
//

import SwiftUI

// MARK: - VaccineFormView
/// Shared form UI for vaccine details.
/// Editable in Add, read-only in Detail.
struct VaccineFormView: View {
    
    // MARK: - Inputs (bindings)
    @Binding var vaccineName: String
    @Binding var vaccinationDate: Date

    @Binding var shouldRenew: Bool
    @Binding var renewalYears: Int
    @Binding var renewalMonths: Int
    @Binding var showRenewalPicker: Bool

    // MARK: - Validation UI (inputs)
    let didAttemptSave: Bool
    let isNameValid: Bool
    let isDateValid: Bool
    let isRenewalValid: Bool
    let renewalSummaryText: String

    // MARK: - Mode
    let isReadOnly: Bool

    // MARK: - Body
    var body: some View {
        vaccineSection
        dateSection
        renewalSection
    }
    
    // MARK: - Sections
    
    // Name section
    private var vaccineSection: some View {
        Section(header: Text("Vaccin")) {
            TextField("Namn på vaccin", text: $vaccineName)
                .disableAutocorrection(false)
                .disabled(isReadOnly)
            
            // Validation
            if didAttemptSave && !isNameValid {
                Text("Vaccinets namn kan inte vara tomt")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    // Date section
    private var dateSection: some View {
        Section(header: Text("Datum")) {
            if isReadOnly {
                HStack {
                    Text("Vaccinationsdatum")
                    Spacer()
                    Text(vaccinationDate.formatted(date: .long, time: .omitted))
                        .foregroundColor(.secondary)
                }
            } else {
                DatePicker(
                    "Vaccinationsdatum",
                    selection: $vaccinationDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
            }
            
            // Validation
            if didAttemptSave && !isDateValid {
                Text("Datumet kan inte vara i framtiden")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    // Renewal section
    private var renewalSection: some View {
        Section(header: Text("Förnyelse")) {
            Toggle("Ska vaccinet förnyas?", isOn: $shouldRenew)
                .disabled(isReadOnly)
                .onChange(of: shouldRenew) { _, newValue in
                    guard !isReadOnly else { return }
                    
                    if newValue {
                        showRenewalPicker = true
                    } else {
                        showRenewalPicker = false
                        renewalYears = 0
                        renewalMonths = 0
                    }
                }
            
            if shouldRenew {
                Button {
                    if !isReadOnly { showRenewalPicker = true }
                } label: {
                    HStack {
                        Text("Intervall")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(renewalSummaryText.isEmpty ? "Välj intervall" : renewalSummaryText)
                            .foregroundColor(isReadOnly ? .secondary : .accentColor)
                    }
                }
                .disabled(isReadOnly)
            }
            
            // Validation
            if didAttemptSave && !isRenewalValid {
                Text("Intervallet kan inte vara tomt")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

// MARK: - Preview
// Preview edit mode (AddVaccineView)
#Preview("VaccineFormView (Edit)") {
    NavigationStack {
        Form {
            VaccineFormPreviewWrapper(isReadOnly: false)
        }
        .navigationTitle("Nytt vaccin")
    }
}

// Preview read-only mode (DetailVaccineView)
#Preview("VaccineFormView (Read-only)") {
    NavigationStack {
        Form {
            VaccineFormPreviewWrapper(isReadOnly: true)
        }
        .navigationTitle("Detaljer")
    }
}

// MARK: - Preview wrapper
private struct VaccineFormPreviewWrapper: View {
    let isReadOnly: Bool

    // Form state
    @State private var vaccineName: String = "VaccineName"
    @State private var vaccinationDate: Date = Calendar.current.date(byAdding: .month, value: -2, to: Date())!

    @State private var shouldRenew: Bool = true
    @State private var renewalYears: Int = 1
    @State private var renewalMonths: Int = 6
    @State private var showRenewalPicker: Bool = false

    @State private var didAttemptSave: Bool = true

    private var isNameValid: Bool { !vaccineName.trimmingCharacters(in: .whitespaces).isEmpty }
    private var isDateValid: Bool { vaccinationDate <= Date() }
    private var isRenewalValid: Bool { !shouldRenew || (renewalYears > 0 || renewalMonths > 0) }

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

    var body: some View {
        VaccineFormView(
            vaccineName: $vaccineName,
            vaccinationDate: $vaccinationDate,
            shouldRenew: $shouldRenew,
            renewalYears: $renewalYears,
            renewalMonths: $renewalMonths,
            showRenewalPicker: $showRenewalPicker,
            didAttemptSave: didAttemptSave,
            isNameValid: isNameValid,
            isDateValid: isDateValid,
            isRenewalValid: isRenewalValid,
            renewalSummaryText: renewalSummaryText,
            isReadOnly: isReadOnly
        )
    }
}

