//
//  NavigationBar.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

struct NBNavigationBar: View {
    let title: String
    let showLogo: Bool
    let trailingContent: (() -> AnyView)?
    
    init(
        title: String, 
        showLogo: Bool = true,
        @ViewBuilder trailingContent: @escaping () -> AnyView = { AnyView(EmptyView()) }
    ) {
        self.title = title
        self.showLogo = showLogo
        self.trailingContent = trailingContent
    }
    
    var body: some View {
        HStack {
            // Logo and Title
            HStack(spacing: 12) {
                if showLogo {
                    Image("NBHSLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 24)
                        .clipped()
                }
                
                Text(title)
                    .font(Typography.heading3)
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
            
            // Trailing content
            trailingContent?()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.navigationBackground)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.navigationBorder),
            alignment: .bottom
        )
    }
}

// MARK: - Convenience modifiers for navigation theming

extension View {
    func nbNavigationTitle(_ title: String, showLogo: Bool = true) -> some View {
        self.navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        if showLogo {
                            Image("NBHSLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 28, height: 20)
                                .clipped()
                        }
                        
                        Text(title)
                            .font(Typography.heading4)
                            .foregroundColor(.textPrimary)
                    }
                }
            }
    }
}

// MARK: - Preview

#if DEBUG
struct NBNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NBNavigationBar(
                title: "Dashboard"
            ) {
                AnyView(
                    Button(action: {}) {
                        Image(systemName: "person.circle")
                            .foregroundColor(.teal500)
                    }
                )
            }
            
            Spacer()
        }
    }
}
#endif