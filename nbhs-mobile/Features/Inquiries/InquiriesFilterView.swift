//
//  InquiriesFilterView.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

struct InquiriesFilterView: View {
    @StateObject private var inquiryService = InquiryService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedFilter: InquiryFilterOption
    @State private var selectedStatus: InquiryStatus?
    @State private var selectedUrgency: InquiryUrgency?
    @State private var selectedSortOption: InquirySortOption
    @State private var selectedSortOrder: SortOrder
    
    init() {
        let service = InquiryService.shared
        _selectedFilter = State(initialValue: service.selectedFilter)
        _selectedStatus = State(initialValue: service.selectedStatus)
        _selectedUrgency = State(initialValue: service.selectedUrgency)
        _selectedSortOption = State(initialValue: service.sortOption)
        _selectedSortOrder = State(initialValue: service.sortOrder)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Filter Options
                Section("Filter By") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(InquiryFilterOption.allCases, id: \.self) { filter in
                            FilterOptionRow(
                                title: filter.displayName,
                                subtitle: getFilterDescription(filter),
                                icon: getFilterIcon(filter),
                                color: .textPrimary,
                                isSelected: selectedFilter == filter
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Status Filter
                Section("Status") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(InquiryStatus.allCases, id: \.self) { status in
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
                
                // Urgency Filter
                Section("Urgency") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(InquiryUrgency.allCases, id: \.self) { urgency in
                            FilterOptionRow(
                                title: urgency.displayName,
                                subtitle: getUrgencyDescription(urgency),
                                icon: urgency.icon,
                                color: getUrgencyColor(urgency),
                                isSelected: selectedUrgency == urgency
                            ) {
                                if selectedUrgency == urgency {
                                    selectedUrgency = nil
                                } else {
                                    selectedUrgency = urgency
                                }
                            }
                        }
                        
                        if selectedUrgency != nil {
                            Button("Clear Urgency Filter") {
                                selectedUrgency = nil
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
                        ForEach(InquirySortOption.allCases, id: \.self) { option in
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
                            title: "Newest First",
                            subtitle: "Descending",
                            icon: "arrow.down",
                            isSelected: selectedSortOrder == .descending
                        ) {
                            selectedSortOrder = .descending
                        }
                        
                        SortOrderButton(
                            title: "Oldest First", 
                            subtitle: "Ascending",
                            icon: "arrow.up",
                            isSelected: selectedSortOrder == .ascending
                        ) {
                            selectedSortOrder = .ascending
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Reset Section
                Section {
                    Button("Reset All Filters") {
                        selectedFilter = .all
                        selectedStatus = nil
                        selectedUrgency = nil
                        selectedSortOption = .createdAt
                        selectedSortOrder = .descending
                    }
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textLink)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Filter Inquiries")
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
        inquiryService.selectedFilter = selectedFilter
        inquiryService.selectedStatus = selectedStatus
        inquiryService.selectedUrgency = selectedUrgency
        inquiryService.sortOption = selectedSortOption
        inquiryService.sortOrder = selectedSortOrder
        
        Task {
            await inquiryService.loadInquiries(refresh: true)
        }
        
        dismiss()
    }
    
    private func getFilterDescription(_ filter: InquiryFilterOption) -> String {
        switch filter {
        case .all: return "Show all inquiries"
        case .new: return "Recently received inquiries"
        case .assigned: return "Inquiries assigned to you"
        case .overdue: return "Past follow-up date"
        case .high_priority: return "High and urgent inquiries"
        }
    }
    
    private func getFilterIcon(_ filter: InquiryFilterOption) -> String {
        switch filter {
        case .all: return "list.bullet"
        case .new: return "envelope.badge"
        case .assigned: return "person"
        case .overdue: return "exclamationmark.triangle"
        case .high_priority: return "exclamationmark.circle"
        }
    }
    
    private func getStatusDescription(_ status: InquiryStatus) -> String {
        switch status {
        case .new: return "Just received"
        case .inProgress: return "Being worked on"
        case .awaitingResponse: return "Waiting for client response"
        case .scheduled: return "Appointment scheduled"
        case .completed: return "Process complete"
        case .converted: return "Became a patient"
        case .closed: return "No longer pursuing"
        }
    }
    
    private func getStatusColor(_ status: InquiryStatus) -> Color {
        switch status {
        case .new: return .info
        case .inProgress: return .warning
        case .awaitingResponse: return .textSecondary
        case .scheduled: return .success
        case .completed: return .success
        case .converted: return .teal500
        case .closed: return .error
        }
    }
    
    private func getUrgencyDescription(_ urgency: InquiryUrgency) -> String {
        switch urgency {
        case .low: return "Can wait"
        case .medium: return "Normal priority"
        case .high: return "Needs attention soon"
        case .urgent: return "Immediate attention required"
        }
    }
    
    private func getUrgencyColor(_ urgency: InquiryUrgency) -> Color {
        switch urgency {
        case .low: return .success
        case .medium: return .warning
        case .high: return .error
        case .urgent: return .error
        }
    }
    
    private func getSortDescription(_ option: InquirySortOption) -> String {
        switch option {
        case .createdAt: return "When inquiry was received"
        case .updatedAt: return "Last activity"
        case .urgency: return "Priority level"
        case .status: return "Current status"
        case .followUpDate: return "Scheduled follow-up"
        }
    }
    
    private func getSortIcon(_ option: InquirySortOption) -> String {
        switch option {
        case .createdAt: return "clock"
        case .updatedAt: return "clock.badge"
        case .urgency: return "exclamationmark.circle"
        case .status: return "tag"
        case .followUpDate: return "calendar"
        }
    }
}

// MARK: - Previews

#if DEBUG
struct InquiriesFilterView_Previews: PreviewProvider {
    static var previews: some View {
        InquiriesFilterView()
    }
}
#endif