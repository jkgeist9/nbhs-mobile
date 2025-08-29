//
//  SidebarNavigation.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

struct SidebarNavigation: View {
    @Binding var selectedTab: Int
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Logo
            HStack(spacing: 12) {
                Image("NBHSLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 30)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("NeuroBehavioral")
                        .font(Typography.heading4)
                        .foregroundColor(.textPrimary)
                    
                    Text("PROVIDER PORTAL")
                        .font(Typography.caption)
                        .foregroundColor(.teal500)
                        .fontWeight(.semibold)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
            
            Divider()
            
            // Navigation Items
            ScrollView {
                VStack(spacing: 2) {
                    NavigationItem(
                        title: "Dashboard",
                        icon: "squares.below.rectangle",
                        isSelected: selectedTab == 0
                    ) {
                        selectedTab = 0
                    }
                    
                    NavigationItem(
                        title: "Inquiries",
                        icon: "tray",
                        isSelected: selectedTab == 1
                    ) {
                        selectedTab = 1
                    }
                    
                    NavigationItem(
                        title: "Patients",
                        icon: "person.2",
                        isSelected: selectedTab == 2
                    ) {
                        selectedTab = 2
                    }
                    
                    NavigationItem(
                        title: "Calendar",
                        icon: "calendar",
                        isSelected: selectedTab == 3
                    ) {
                        selectedTab = 3
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    NavigationItem(
                        title: "Evaluations",
                        icon: "doc.text",
                        isSelected: false
                    ) {
                        // Handle evaluations tap
                    }
                    
                    NavigationItem(
                        title: "Documents",
                        icon: "folder",
                        isSelected: false
                    ) {
                        // Handle documents tap
                    }
                    
                    NavigationItem(
                        title: "Tasks",
                        icon: "checkmark.square",
                        isSelected: false
                    ) {
                        // Handle tasks tap
                    }
                    
                    NavigationItem(
                        title: "Messages",
                        icon: "message",
                        isSelected: false
                    ) {
                        // Handle messages tap
                    }
                    
                    NavigationItem(
                        title: "Billing",
                        icon: "creditcard",
                        isSelected: false
                    ) {
                        // Handle billing tap
                    }
                    
                    NavigationItem(
                        title: "Call Center",
                        icon: "phone",
                        isSelected: false
                    ) {
                        // Handle call center tap
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
            }
            
            Spacer()
            
            // User Info and Logout
            VStack(spacing: 12) {
                Divider()
                
                if let user = authService.user {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.fullName)
                            .bodyStyle(.medium)
                        
                        Text(user.email)
                            .captionStyle(.regular, color: .textSecondary)
                        
                        Text("PROVIDER")
                            .captionStyle(.medium, color: .teal500)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                }
                
                Button(action: {
                    Task {
                        await authService.logout()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.right.square")
                        Text("Sign Out")
                    }
                    .foregroundColor(.error)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(width: 240)
        .background(Color(red: 0.026, green: 0.549, blue: 0.635)) // Teal background matching website
        .foregroundColor(.white)
    }
}

struct NavigationItem: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .frame(width: 20)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                
                Text(title)
                    .bodyStyle(.medium)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.white.opacity(0.2) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#if DEBUG
struct SidebarNavigation_Previews: PreviewProvider {
    static var previews: some View {
        SidebarNavigation(selectedTab: .constant(0))
            .environmentObject(AuthService.shared)
    }
}
#endif