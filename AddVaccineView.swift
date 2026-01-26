//
//  AddVaccineView.swift
//  vaccineApp
//
//  Created by hannali on 2026-01-04.
//

import SwiftUI
import UIKit
import AudioToolbox

struct AddVaccineView: View {
    
    // Environment
    @Environment(\.dismiss) private var dismiss
    
    // Input
    @State private var vaccineName: String
    @State private var vaccinationDate: Date
    
    // Förnyelse
    @State private var shouldRenew: Bool
    @State private var renewalYears: Int
    @State private var renewalMonths: Int
    @State private var showRenewalPicker = false
    
    // Validering
    @State private var didAttemptSave = false
    @State private var shakeDate = false
    
    // Justering
    var existingVaccine: Vaccine?
    var onSave: (Vaccine) -> Void
    
    
    // Init
    init(existingVaccine: Vaccine? = nil,
         onSave: @escaping (Vaccine) -> Void) {
        
        self.existingVaccine = existingVaccine
        self.onSave = onSave

        _vaccineName = State(initialValue: existingVaccine?.name ?? "")
        _vaccinationDate = State(initialValue: existingVaccine?.date ?? Date())
        
        _shouldRenew = State(initialValue: existingVaccine?.renewalDate != nil)
        
        // Förnyelse - Sparar användarens val vid redigering
        if let renewalDate = existingVaccine?.renewalDate {
            let components = Calendar.current.dateComponents(
                [.year, .month],
                from: existingVaccine!.date,
                to: renewalDate
            )
            _renewalYears = State(initialValue: components.year ?? 0)
            _renewalMonths = State(initialValue: components.month ?? 0)
        } else {
            _renewalYears = State(initialValue: 0)
            _renewalMonths = State(initialValue: 0)
        }
    }

    // Validering
    private var isDateValid: Bool { vaccinationDate <= Date() } // Datum
    private var isNameValid: Bool { !vaccineName.trimmingCharacters(in: .whitespaces).isEmpty } // Namn
    private var isRenewalValid: Bool { !shouldRenew || (renewalYears > 0 || renewalMonths > 0) }    // Förnyelsedatum
    private var isFormValid: Bool { isNameValid && isDateValid && isRenewalValid }    // Formulär
    
    // Förnyelsedatum
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
    
    // Haptik och ljud
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
    
    // Förnyelse - summeringstext
    private var renewalSummaryText: String {
        // Ingen förnyelse eller inget valt intervall
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
        ZStack {
            Color.platformBackground
                .ignoresSafeArea()
            
        Form {
                    // Vaccinnamn
                    Section(header: Text("Vaccin")) {
                        // Gör första bokstaven i ordet till versal samt enablear autocorrect
                        if #available(iOS 16.0, *) {    // För iOS 16 +
                            TextField("Namn på vaccin", text: $vaccineName)
                                .textInputAutocapitalization(.words)
                                .disableAutocorrection(false)
                        } else {    // För äldre iOS-versioner
                            TextField("Namn på vaccin", text: $vaccineName)
                                .autocapitalization(.words)
                                .disableAutocorrection(false)
                        }
                        
                        // Valideringsfel
                        if didAttemptSave && !isNameValid {
                            Text("Vaccinets namn kan inte vara tomt")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // Datum
                    Section(header: Text("Datum")) {
                        DatePicker(
                            "Vaccinationsdatum",
                            selection: $vaccinationDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        
                        // Date picker stil
                        .datePickerStyle(.compact)
                        
                        // Shake-animering
                        .offset(x: shakeDate ? -8 : 0)
                        .animation(
                            .default.repeatCount(3, autoreverses: true),
                            value: shakeDate
                        )
                        
                        // Valideringsfel
                        if didAttemptSave && !isDateValid {
                            Text("Datumet kan inte vara i framtiden")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
            
                    // Förnyelse
                    Section(header: Text("Förnyelse")) {
                        Toggle("Ska vaccinet förnyas?", isOn: $shouldRenew)
                            .onChange(of: shouldRenew) {
                                if shouldRenew {
                                    DispatchQueue.main.async {
                                                showRenewalPicker = true
                                            }
                                } else {
                                    showRenewalPicker = false
                                    renewalYears = 0
                                    renewalMonths = 0
                                }
                            }
                        if shouldRenew {
                            Button {
                                showRenewalPicker = true
                            } label: {
                                HStack {
                                    Text("Intervall")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text(renewalSummaryText.isEmpty ? "Välj intervall" : renewalSummaryText)
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                        
                        // Valideringsfel
                        if didAttemptSave && !isRenewalValid {
                            Text("Intervallet kan inte vara tomt")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // Spara-knapp
                    Section {
                        Button("Spara") {
                        
                            didAttemptSave = true
                            
                            // Genererar error-haptik och ljud baserad på formulärvaliditet
                            guard isFormValid else {
                                
                                errorFeedback()
                                
                                // Errorhaptik baserad på datumvaliditet
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
                            NotificationManager.shared.scheduleReminder(for: vaccine)
                            
                            successFeedback()
                            
                            dismiss()
                        }
                    }
                }
                .navigationTitle(existingVaccine == nil ? "Nytt vaccin" : "Redigera vaccin")
            
                // Förnyelse-pop-up
                .sheet(isPresented: $showRenewalPicker) {
                    NavigationStack {
                        Form {
                            Section {
                                
                                // Wheel-pickers
                                HStack(spacing: 12) {
                                    
                                    // År
                                    VStack(spacing: 4) {
                                        Text("År")
                                            .foregroundColor(.secondary)
                                        
                                        Picker("År", selection: $renewalYears) {
                                            ForEach(0...50, id: \.self) { year in
                                                Text("\(year)").tag(year)
                                            }
                                        }
                                    }
                                    
                                    // Månader
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
                                
                                // Summeringstext
                                if isRenewalValid {
                                    VStack(alignment: .leading, spacing: 2) {
                                        
                                        // Rad 1: Intervall
                                        Text("Förnyas om \(renewalSummaryText)")
                                            .foregroundColor(.secondary)
                                        
                                        // Rad 2: Månad och år
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

#Preview {
    AddVaccineView(
        existingVaccine: Vaccine(
            id: UUID(),
            name: String(),
            date: Date()
        )
    ) { _ in }
}

