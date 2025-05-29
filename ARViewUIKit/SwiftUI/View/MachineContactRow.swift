//
//  MachineContactRow.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 05.05.25.
//

import SwiftUI

/*
    TODO: - Add proper font and size and applay card style for cards
*/

struct MachineContactRow: View {
    let contact: Contact
    
    // Customizable spacing properties
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let contentSpacing: CGFloat
    
    // Initialize with default values for backward compatibility
    init(contact: Contact,
         horizontalPadding: CGFloat = 10,
         verticalPadding: CGFloat = 10,
         contentSpacing: CGFloat = 12) {
        self.contact = contact
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.contentSpacing = contentSpacing
    }
    
    var body: some View {
        ZStack {
            // Card
            HStack(spacing: contentSpacing) {
                // Profile image
                profileImageView
                
                // Contact information
                contactInfoView
                
                Spacer()
                
                // Role and favorite indicator
                roleAndFavoriteView
            }
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    // MARK: - Subviews
    
    private var profileImageView: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 40)
            
            Text(String(contact.name.prefix(1)))
                .font(.headline)
                .foregroundColor(.gray)
        }
    }
    
    private var contactInfoView: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Show Priority label if needed
            if contact.isPriority {
                Text("Priority")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 2)
            }
            
            Text(contact.name)
                .font(.system(size: 14))
        }
    }
    
    private var roleAndFavoriteView: some View {
        HStack(spacing: 8) {
            Text(contact.displayRole)
                .font(.caption)
                .fontWeight(.medium)
            
            if contact.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
            }
        }
    }
}
