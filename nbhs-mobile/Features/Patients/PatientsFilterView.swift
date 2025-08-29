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
    
    @State private var selectedStatus: PatientStatus?
    @State private var selectedSortOption: PatientSortOption
    @State private var selectedSortOrder: SortOrder
    
    init() {
        let service = PatientService.shared
        _selectedStatus = State(initialValue: service.selectedStatus)
        _selectedSortOption = State(initialValue: service.sortOption)
        _selectedSortOrder = State(initialValue: service.sortOrder)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Status Filter
                Section("Status") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(PatientStatus.allCases, id: \.self) { status in
                            FilterOptionRow(
                                title: status.displayName,
                                subtitle: getStatusDescription(status),
                                icon: status.icon,
                                color: getStatusColor(status),
                                isSelected: selectedStatus == status
                            ) {
                                if selectedStatus == status {
                                    selectedStatus = nil
                                } else {
                                    selectedStatus = status
                                }
                            }
                        }
                        
                        if selectedStatus != nil {
                            Button("Clear Status Filter") {
                                selectedStatus = nil
                            }
                            .font(Typography.bodyMedium)
                            .foregroundColor(.textLink)
                            .padding(.top, 8)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Sort Options
                Section("Sort By") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(PatientSortOption.allCases, id: \.self) { option in
                            FilterOptionRow(
                                title: option.displayName,
                                subtitle: getSortDescription(option),
                                icon: getSortIcon(option),
                                color: .textPrimary,
                                isSelected: selectedSortOption == option
                            ) {
                                selectedSortOption = option
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
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
                        selectedStatus = nil
                        selectedSortOption = .name
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
        patientService.selectedStatus = selectedStatus
        patientService.sortOption = selectedSortOption
        patientService.sortOrder = selectedSortOrder
        
        Task {
            await patientService.loadPatients(refresh: true)
        }
        
        dismiss()
    }
    
    private func getStatusDescription(_ status: PatientStatus) -> String {
        switch status {
        case .active: return "Currently receiving care"
        case .inactive: return "Not currently active"
        case .discharged: return "Treatment completed"
        case .pending: return "Awaiting intake"
        case .archived: return "Historical records"
        }
    }
    
    private func getStatusColor(_ status: PatientStatus) -> Color {
        switch status {
        case .active: return .success
        case .inactive: return .warning
        case .discharged: return .textSecondary
        case .pending: return .info
        case .archived: return .textTertiary
        }
    }
    
    private func getSortDescription(_ option: PatientSortOption) -> String {
        switch option {
        case .name: return "Alphabetical by full name"
        case .lastAppointment: return "Most recent appointment first"
        case .nextAppointment: return "Upcoming appointments first"
        case .createdAt: return "Recently added patients first"
        case .status: return "Group by patient status"
        }
    }
    
    private func getSortIcon(_ option: PatientSortOption) -> String {
        switch option {
        case .name: return "textformat"
        case .lastAppointment: return "calendar.badge.clock"
        case .nextAppointment: return "calendar.badge.plus"
        case .createdAt: return "clock"
        case .status: return "tag"
        }
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