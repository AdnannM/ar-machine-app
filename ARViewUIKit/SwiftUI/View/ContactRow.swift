//
//  ContactRow.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 05.05.25.
//

import SwiftUI

/*
    TODO: - Add proper font and size and applay card style for cards
*/

struct ContactRow: View {
    let contact: Contact
    
    var body: some View {
        HStack {
            // Profile image
            ZStack {
                profileImageView
            }
            
            // Contact info
            contactInfoView
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
    
    private var profileImageView: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 40)
            
            Text(String(contact.name.prefix(1)))
                .font(.headline)
                .foregroundColor(.blue)
        }
    }
    
    private var contactInfoView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(contact.name)
                .font(.headline)
            
            Text("\(contact.company) | \(contact.role)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
