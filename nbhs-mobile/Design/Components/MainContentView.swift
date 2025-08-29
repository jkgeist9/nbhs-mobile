//
//  MainContentView.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

struct MainContentView<Content: View>: View {
    let title: String
    let searchPlaceholder: String?
    let headerAction: (() -> AnyView)?
    let content: () -> Content
    
    @State private var searchText = ""
    
    init(
        title: String,
        searchPlaceholder: String? = nil,
        @ViewBuilder headerAction: @escaping () -> AnyView = { AnyView(EmptyView()) },
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.searchPlaceholder = searchPlaceholder
        self.headerAction = headerAction
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(title)
                    .font(Typography.heading2)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                // Search bar if provided
                if let placeholder = searchPlaceholder {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.textSecondary)
                        
                        TextField(placeholder, text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .frame(width: 300)
                }
                
                // Header action button
                headerAction?()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.2)),
                alignment: .bottom
            )
            
            // Content
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

// MARK: - Preview

#if DEBUG
struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView(
            title: "Patient Inquiries",
            searchPlaceholder: "Search inquiries...",
            headerAction: {
                AnyView(
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "plus")
                            Text("New Inquiry")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.teal500)
                        .cornerRadius(8)
                    }
                )
            }
        ) {
            VStack {
                Text("Content goes here")
                Spacer()
            }
            .padding()
        }
    }
}
#endif