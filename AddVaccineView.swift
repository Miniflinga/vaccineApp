//
//  AddVaccineView.swift
//  vaccineApp
//
//  Created by hannali on 2026-01-04.
//

import SwiftUI

struct AddVaccineView: View {
    
    var onSave: (Vaccine) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var vaccineName: String = ""
    @State private var vaccinationDate: Date = Date()
    
    var body: some View {
        ZStack {
            Color.platformBackground
                .ignoresSafeArea()
            
        Form {
                    Section(header: Text("Vaccin")) {
                        TextField("Namn på vaccin", text: $vaccineName)
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
                                    name: vaccineName,
                                    date: vaccinationDate
                            )
                            onSave(vaccine)
                            dismiss()
                        }
                    }
                }
                .navigationTitle("Nytt vaccin")
            }
        }
    }

#Preview {
    AddVaccineView{ _ in }
}
