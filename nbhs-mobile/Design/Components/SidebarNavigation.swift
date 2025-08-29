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
    @State private var isCollapsed = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Collapse/Expand Button
            HStack {
                Spacer()
                
                // Collapse/Expand Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isCollapsed.toggle()
                    }
                }) {
                    Image(systemName: isCollapsed ? "chevron.right" : "chevron.left")
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 16, height: 16)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            // Navigation Items
            ScrollView {
                VStack(spacing: 2) {
                    NavigationItem(
                        title: "Dashboard",
                        icon: "squares.below.rectangle",
                        isSelected: selectedTab == 0,
                        isCollapsed: isCollapsed
                    ) {
                        selectedTab = 0
                    }
                    
                    NavigationItem(
                        title: "Inquiries",
                        icon: "tray",
                        isSelected: selectedTab == 1,
                        isCollapsed: isCollapsed
                    ) {
                        selectedTab = 1
                    }
                    
                    NavigationItem(
                        title: "Patients",
                        icon: "person.2",
                        isSelected: selectedTab == 2,
                        isCollapsed: isCollapsed
                    ) {
                        selectedTab = 2
                    }
                    
                    NavigationItem(
                        title: "Calendar",
                        icon: "calendar",
                        isSelected: selectedTab == 3,
                        isCollapsed: isCollapsed
                    ) {
                        selectedTab = 3
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.vertical, 8)
                    
                    NavigationItem(
                        title: "Evaluations",
                        icon: "doc.text",
                        isSelected: false,
                        isCollapsed: isCollapsed
                    ) {
                        // Handle evaluations tap
                    }
                    
                    NavigationItem(
                        title: "Documents",
                        icon: "folder",
                        isSelected: false,
                        isCollapsed: isCollapsed
                    ) {
                        // Handle documents tap
                    }
                    
                    NavigationItem(
                        title: "Tasks",
                        icon: "checkmark.square",
                        isSelected: false,
                        isCollapsed: isCollapsed
                    ) {
                        // Handle tasks tap
                    }
                    
                    NavigationItem(
                        title: "Messages",
                        icon: "message",
                        isSelected: false,
                        isCollapsed: isCollapsed
                    ) {
                        // Handle messages tap
                    }
                    
                    NavigationItem(
                        title: "Billing",
                        icon: "creditcard",
                        isSelected: false,
                        isCollapsed: isCollapsed
                    ) {
                        // Handle billing tap
                    }
                    
                    NavigationItem(
                        title: "Call Center",
                        icon: "phone",
                        isSelected: false,
                        isCollapsed: isCollapsed
                    ) {
                        // Handle call center tap
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
            }
            
            Spacer()
        }
        .frame(width: isCollapsed ? 80 : 240)
        .background(Color(red: 0.026, green: 0.549, blue: 0.635)) // Teal background matching website
        .foregroundColor(.white)
    }
}

struct NavigationItem: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let isCollapsed: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: isCollapsed ? 0 : 12) {
                Image(systemName: icon)
                    .frame(width: 20)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                
                if !isCollapsed {
                    Text(title)
                        .font(Typography.bodyMedium)
                        .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, isCollapsed ? 8 : 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.white.opacity(0.2) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .help(isCollapsed ? title : "")
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