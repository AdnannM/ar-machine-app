//
//  ContactsViewModel.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 05.05.25.
//

import Observation

// MARK: - View Models
@MainActor
final class ContactsViewModel {
    var contacts: [Contact] = []
    var selectedMachine: Machine?
    var isShowingMachineOnly = true
    var searchText = ""
    
    // Sample data
    let allContacts = [
        Contact(name: "Anders Johansson", company: "Supplier company", role: "Technician"),
        Contact(name: "Anders Johansson", company: "Supplier company", role: "Support"),
        Contact(name: "Anders Svensson", company: "Supplier company", role: "Customer Support"),
        Contact(name: "Fredrik Magnusson", company: "Supplier company", role: "Support"),
        Contact(name: "Hanna Matsson", company: "Supplier company", role: "Customer Support"),
        Contact(name: "Karin Lindberg", company: "Supplier company", role: "Spare parts"),
        Contact(name: "Karin Lindberg", company: "Supplier company", role: "Technician"),
        Contact(name: "Kent Lindt", company: "Supplier company", role: "Technician"),
        Contact(name: "Mohammed Akhari", company: "Supplier company", role: "Support")
    ]
    
    let machineContacts = [
        Contact(name: "Anders Johansson", company: "Supplier company", role: "Technician"),
        Contact(name: "Anders Svensson", company: "Supplier company", role: "Spare parts"),
        Contact(name: "George Beck", company: "Supplier company", role: "Support"),
        Contact(name: "Hannes Carlsson", company: "Supplier company", role: "Customer support"),
        Contact(name: "Johan Svensson", company: "Supplier company", role: "Technician"),
        Contact(name: "Louise Karlsson", company: "Supplier company", role: "Spare parts")
    ]
    
    let machine = Machine(name: "EX Master 7000",
                         company: "Print Solutions AB",
                         serialNumber: "FAC-123-ABC-456-XYZ-7890")
    
    init() {
        selectedMachine = machine
        contacts = machineContacts
        isShowingMachineOnly = true
    }

    
    func toggleMachineView() {
        isShowingMachineOnly.toggle()
        if isShowingMachineOnly {
            selectedMachine = machine
            contacts = machineContacts
        } else {
            selectedMachine = nil
            contacts = allContacts
        }
    }
    
    func filteredContacts() -> [Contact] {
        if searchText.isEmpty {
            return contacts
        } else {
            return contacts.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.company.localizedCaseInsensitiveContains(searchText) ||
                $0.role.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
