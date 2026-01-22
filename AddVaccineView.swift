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
                        
                        if shouldRenew {
                            VStack {
                                Stepper("År: \(renewalYears)", value: $renewalYears, in: 0...120)
                                Stepper("Månader: \(renewalMonths)", value: $renewalMonths, in: 0...11)
                            }
                            
                            // Valideringsfel
                            if didAttemptSave && !isRenewalValid {
                                Text("Välj minst 1 månad för förnyelse")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
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
                        //.disabled(!isFormValid) - Disable:ar om formatet ej är giltigt
                    }
                }
                .navigationTitle(existingVaccine == nil ? "Nytt vaccin" : "Redigera vaccin")
            }
        }
    }

#Preview {
    AddVaccineView(
        existingVaccine: Vaccine(
            id: UUID(),
            name: String(), // Eller "Exempelnamn på vaccin"
            date: Date()
        )
    ) { _ in }
}

