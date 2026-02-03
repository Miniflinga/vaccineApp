//
//  AddVaccineView.swift
//  vaccineApp
//
//  Created by hannali on 2026-01-04.
//

import SwiftUI
import UIKit
import AudioToolbox

// MARK: - AddVaccineView
/// Screen for creating or editing a vaccine.
/// Reuses VaccineFormView as the shared form UI.
struct AddVaccineView: View {
    
    // MARK: - External input (from ContentView)
    /// If  nil → "Nytt vaccin", else "Redigera vaccin"
    var existingVaccine: Vaccine?
    var onSave: (Vaccine) -> Void
    
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Form state
    @State private var vaccineName: String
    @State private var vaccinationDate: Date
    
    @State private var shouldRenew: Bool
    @State private var renewalYears: Int
    @State private var renewalMonths: Int
    @State private var showRenewalPicker = false
    
    // MARK: - Validation & feedback state
    @State private var didAttemptSave = false
    @State private var shakeDate = false
    
    // MARK: - Init
    init(existingVaccine: Vaccine? = nil,
         onSave: @escaping (Vaccine) -> Void) {
        
        self.existingVaccine = existingVaccine
        self.onSave = onSave

        // Intit form state from vaccin
        _vaccineName = State(initialValue: existingVaccine?.name ?? "")
        _vaccinationDate = State(initialValue: existingVaccine?.date ?? Date())
        
        _shouldRenew = State(initialValue: existingVaccine?.renewalDate != nil)
        
        // Renewal - Saves user edit input
        if let renewalDate = existingVaccine?.renewalDate, let baseDate = existingVaccine?.date {
            let components = Calendar.current.dateComponents([.year, .month], from: baseDate, to: renewalDate)
            _renewalYears = State(initialValue: components.year ?? 0)
            _renewalMonths = State(initialValue: components.month ?? 0)
        } else {
            _renewalYears = State(initialValue: 0)
            _renewalMonths = State(initialValue: 0)
        }
    }

    // MARK: - Validation (derived)
    private var isDateValid: Bool { vaccinationDate <= Date() }
    private var isNameValid: Bool { !vaccineName.trimmingCharacters(in: .whitespaces).isEmpty }
    private var isRenewalValid: Bool { !shouldRenew || (renewalYears > 0 || renewalMonths > 0) }
    private var isFormValid: Bool { isNameValid && isDateValid && isRenewalValid }
    
    // MARK: - Dates (derived)
    private var renewalDate: Date? {
        guard shouldRenew else { return nil }

        return Calendar.current.date(
            byAdding: DateComponents(
                year: renewalYears,
                month: renewalMonths
            ),
            to: vaccinationDate
        )
    }
    
    // MARK: - Summary text (derived)
    private var renewalSummaryText: String {
        // No renewal or no chosen interval
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
    
    // MARK: - Feedback (haptics & sound)
    private func errorFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        AudioServicesPlaySystemSound(1107) // System "error"
    }
    
    private func successFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        AudioServicesPlaySystemSound(1057) // System "success"
    }
    
    // MARK: - Actions
        private func saveAction() {
            didAttemptSave = true

            /// Form validation
            guard isFormValid else {
                errorFeedback()

                /// Validation shake (date)
                if !isDateValid {
                    shakeDate = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        shakeDate = false
                    }
                }
                return
            }

            let vaccine = Vaccine(
                id: existingVaccine?.id ?? UUID(),
                name: vaccineName,
                date: vaccinationDate,
                renewalDate: renewalDate
            )

            onSave(vaccine)
            successFeedback()
            dismiss()
        }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.platformBackground
                .ignoresSafeArea()
            
            // MARK: - Vaccine form
            Form {
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
                    isReadOnly: false
                )

                // MARK: - Save action
                Section {
                    Button("Spara") {
                        saveAction()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(existingVaccine == nil ? "Nytt vaccin" : "Redigera vaccin")
            
            // MARK: - Renewal picker sheet
            .sheet(isPresented: $showRenewalPicker) {
                NavigationStack {
                    Form {
                        Section {
                            
                            // Wheel-pickers
                            HStack(spacing: 12) {
                                
                                // Years
                                VStack(spacing: 4) {
                                    Text("År")
                                        .foregroundColor(.secondary)
                                    
                                    Picker("År", selection: $renewalYears) {
                                        ForEach(0...50, id: \.self) { year in
                                            Text("\(year)").tag(year)
                                        }
                                    }
                                }
                                
                                // Months
                                VStack(spacing: 4) {
                                    Text("Månader")
                                        .foregroundColor(.secondary)
                                    
                                    Picker("Månader", selection: $renewalMonths) {
                                        ForEach(0...11, id: \.self) { month in
                                            Text("\(month)").tag(month)
                                        }
                                    }
                                }
                            }
                                .pickerStyle(.wheel)
                                .frame(height: 170)
                                .clipped()
                                .listRowSeparator(.hidden)
                            
                            // Summary
                            if isRenewalValid {
                                VStack(alignment: .leading, spacing: 2) {
                                    
                                    // Row 1: Interval
                                    Text("Förnyas om \(renewalSummaryText)")
                                        .foregroundColor(.secondary)
                                    
                                    // Row 2: Months & years
                                    if let date = renewalDate {
                                        Text(
                                            date.formatted(
                                                .dateTime
                                                    .month(.wide)
                                                    .year()
                                            )
                                        )
                                    .foregroundColor(.secondary.opacity(0.8))
                                    }
                                }
                                .font(.footnote)
                            }
                        }
                    }
                    .navigationTitle("Förnyelseintervall")
                }
                .presentationDetents([.medium])
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AddVaccineView(
        existingVaccine: Vaccine(
            id: UUID(),
            name: String(),
            date: Date()
        )
    ) { _ in }
}
