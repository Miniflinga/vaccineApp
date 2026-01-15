//
//  AddVaccineView.swift
//  vaccineApp
//
//  Created by hannali on 2026-01-04.
//

import SwiftUI

struct AddVaccineView: View {
    
    var existingVaccine: Vaccine?
    var onSave: (Vaccine) -> Void
    
    init(existingVaccine: Vaccine? = nil,   // LIGGER DENNA RÄTT?
         onSave: @escaping (Vaccine) -> Void) { // LIGGER DENNA RÄTT?

        self.existingVaccine = existingVaccine  // LIGGER DENNA RÄTT?
        self.onSave = onSave    // LIGGER DENNA RÄTT?

        _vaccineName = State(initialValue: existingVaccine?.name ?? "") // LIGGER DENNA RÄTT?
        _vaccinationDate = State(initialValue: existingVaccine?.date ?? Date()) // LIGGER DENNA RÄTT?
    }   // LIGGER DENNA RÄTT?

    @State private var vaccineName: String
    @State private var vaccinationDate: Date
    
    // Tar bort mellanslag och kollar att namnet inte är tomt
    private var isFormValid: Bool {
        !vaccineName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.platformBackground
                .ignoresSafeArea()
            
        Form {
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
                                                
                        if !isFormValid {
                            Text("Vaccinets namn kan inte vara tomt")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    Section(header: Text("Datum")) {
                        DatePicker(
                            "Vaccinationsdatum",
                            selection: $vaccinationDate,
                            displayedComponents: .date
                        )
                    }

                    Section {
                        Button("Spara") {
                            let vaccine = Vaccine(
                                    id: existingVaccine?.id ?? UUID(),
                                    name: vaccineName,
                                    date: vaccinationDate
                            )
                            onSave(vaccine)
                            dismiss()
                        }
                        .disabled(!isFormValid) // Disable:ar om formatet ej är giltigt
                    }
                }
                .navigationTitle("Nytt vaccin")
            }
        }
    }

#Preview {
    AddVaccineView(
        existingVaccine: Vaccine(
            id: UUID(),
            name: String(), // Eller "Exempelnamn på vaccin")
            date: Date()
        )
    ) { _ in }
}

