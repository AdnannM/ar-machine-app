//
//  ContactsContentView.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 05.05.25.
//

import SwiftUI

/*
    TODO: - Add proper font and size and applay card style for cards
*/

struct ContactsContentView: View {
    @State var viewModel = ContactsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            machineFilterSection
            searchField
            contactsHeader
            contactsList
        }
    }
    
    // MARK: - Machine Filter Section
    private var machineFilterSection: some View {
        Group {
            if viewModel.isShowingMachineOnly {
                machineInfoView
                showAllContactsButton
            } else {
                machineRelatedContactsButton
            }
        }
    }
    
    private var machineInfoView: some View {
        Group {
            if let machine = viewModel.selectedMachine {
                VStack(alignment: .center, spacing: 4) {
                    Text("Contacts related to the machine:")
                        .font(.subheadline)
                        .padding(.top, 8)
                    
                    Text(machine.name)
                        .font(.headline)
                    
                    Group {
                        Text(machine.company)
                        Text(machine.serialNumber)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            } else {
                EmptyView()
            }
        }
    }
    
    private var showAllContactsButton: some View {
        Button(action: { viewModel.toggleMachineView() }) {
            Text("Show All Contacts")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(OutlinedButtonStyle())
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }
    
    private var machineRelatedContactsButton: some View {
        Button(action: { viewModel.toggleMachineView() }) {
            Text("Machine Related Contacts Only")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(OutlinedButtonStyle())
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    // MARK: - Search Field
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search for contacts", text: $viewModel.searchText)
                .font(.body)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Contacts Header
    private var contactsHeader: some View {
        HStack {
            Text("Contacts")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            roleFilterMenu
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
    }
    
    private var roleFilterMenu: some View {
        Menu {
            Button("All Roles", action: {})
            Button("Technician", action: {})
            Button("Support", action: {})
            Button("Customer Support", action: {})
            Button("Spare Parts", action: {})
        } label: {
            HStack {
                Text("All Roles")
                Image(systemName: "chevron.down")
            }
        }
    }
    
    // MARK: - Contacts List
    private var contactsList: some View {
        List {
            ForEach(viewModel.filteredContacts()) { contact in
                if viewModel.isShowingMachineOnly {
                    MachineContactRow(contact: contact)
                } else {
                    ContactRow(contact: contact)
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
}

// MARK: - Helper Button Style
struct OutlinedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 1)
                    .background(Color.clear)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
