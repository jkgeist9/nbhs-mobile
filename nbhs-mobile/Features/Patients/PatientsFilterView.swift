//
//  PatientsFilterView.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

struct PatientsFilterView: View {
    @StateObject private var patientService = PatientService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedSortOrder: SortOrder = .ascending
    
    init() {
        _selectedSortOrder = State(initialValue: .ascending)
    }
    
    var body: some View {
        NavigationView {
            Form {                
                // Sort Order
                Section("Sort Order") {
                    HStack(spacing: 20) {
                        SortOrderButton(
                            title: "A-Z",
                            subtitle: "Ascending",
                            icon: "arrow.up",
                            isSelected: selectedSortOrder == .ascending
                        ) {
                            selectedSortOrder = .ascending
                        }
                        
                        SortOrderButton(
                            title: "Z-A", 
                            subtitle: "Descending",
                            icon: "arrow.down",
                            isSelected: selectedSortOrder == .descending
                        ) {
                            selectedSortOrder = .descending
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Reset Section
                Section {
                    Button("Reset All Filters") {
                        selectedSortOrder = .ascending
                    }
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textLink)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Filter Patients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        applyFilters()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func applyFilters() {
        // For now, just dismiss - sorting will be handled by the simplified Patient model
        Task {
            await patientService.loadPatients(refresh: true)
        }
        
        dismiss()
    }
}

// MARK: - Supporting Views

struct FilterOptionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .bodyStyle(.medium)
                        .foregroundColor(.textPrimary)
                    
                    Text(subtitle)
                        .captionStyle(.regular, color: .textSecondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .teal500 : .textTertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SortOrderButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .teal500 : .textTertiary)
                
                VStack(spacing: 2) {
                    Text(title)
                        .bodyStyle(.medium)
                        .foregroundColor(isSelected ? .teal500 : .textPrimary)
                    
                    Text(subtitle)
                        .captionStyle(.small, color: .textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(isSelected ? Color.teal500.opacity(0.1) : Color.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.teal500 : Color.border, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Previews

#if DEBUG
struct PatientsFilterView_Previews: PreviewProvider {
    static var previews: some View {
        PatientsFilterView()
    }
}
#endif