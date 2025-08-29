//
//  TopHeader.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

struct TopHeader: View {
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        HStack(spacing: 16) {
            // Logo and Company Name
            HStack(spacing: 12) {
                Image("NBHSLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 24)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("NeuroBehavioral")
                        .font(Font.merriweather(16, weight: .regular))
                        .foregroundColor(.textPrimary)
                    
                    Text("HEALTH SERVICES")
                        .font(Font.montserrat(10, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .tracking(1)
                }
            }
            
            Spacer()
            
            // User Info and Sign Out
            if let user = authService.user {
                HStack(spacing: 16) {
                    // User Info
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.teal500)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(user.initials)
                                    .font(Typography.captionSmall)
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                            )
                        
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(user.fullName)
                                .font(Typography.bodyMedium)
                                .fontWeight(.medium)
                                .foregroundColor(.textPrimary)
                            
                            Text("PROVIDER")
                                .font(Typography.captionSmall)
                                .fontWeight(.medium)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    // Sign Out Button
                    Button(action: {
                        Task {
                            await authService.logout()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.right.square")
                                .font(.system(size: 14))
                                .foregroundColor(.textSecondary)
                            
                            Text("Sign Out")
                                .font(Typography.bodyMedium)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.backgroundSecondary)
                        .cornerRadius(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .padding(.top, 1) // Additional padding for safe area
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(Color.border)
                .frame(height: 1),
            alignment: .bottom
        )
        .background(.regularMaterial, ignoresSafeAreaEdges: [])
    }
}

// MARK: - Preview

#if DEBUG
struct TopHeader_Previews: PreviewProvider {
    static var previews: some View {
        TopHeader()
            .environmentObject(AuthService.shared)
    }
}
#endif