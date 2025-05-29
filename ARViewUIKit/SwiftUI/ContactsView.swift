//
//  ContactsView.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 29.04.25.
//

import SwiftUI

// MARK: - Main View
struct ContactsView: View {
    @State private var viewModel = ContactsViewModel()
    @State private var selectedTab = Tab.contacts

    enum Tab {
        case favorites
        case contacts
        case latest
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            contactsTab
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
                .tag(Tab.favorites)

            contactListTab
                .tabItem {
                    Label("Contacts", systemImage: "person.crop.circle")
                }
                .tag(Tab.contacts)

            Text("Latest")
                .tabItem {
                    Label("Latest", systemImage: "clock")
                }
                .tag(Tab.latest)
        }
    }

    private var contactsTab: some View {
        Text("Favorites")
    }

    private var contactListTab: some View {
        ContactsContentView(viewModel: viewModel)
    }
}

#Preview {
    ContactsView()
}
