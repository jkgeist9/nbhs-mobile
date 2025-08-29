//
//  DetailViewComponents.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

struct ContactButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.teal500)
                
                Text(text)
                    .captionStyle(.regular, color: .textLink)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.teal500.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.bodyMedium)
                .foregroundColor(isSelected ? .white : .textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.teal500 : Color.clear)
                .cornerRadius(6)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .bodyStyle(.medium, color: .textSecondary)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .bodyStyle(.regular)
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}