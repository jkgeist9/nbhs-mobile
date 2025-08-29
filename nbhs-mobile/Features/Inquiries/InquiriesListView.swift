//
//  InquiriesListView.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

struct InquiriesListView: View {
    @StateObject private var inquiryService = InquiryService.shared
    @State private var showingFilters = false
    @State private var showingCreateInquiry = false
    @State private var selectedInquiry: Inquiry?
    @State private var showingInquiryDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Chips
            if hasActiveFilters {
                filterChips
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Inquiry List
            inquiryList
        }
        .sheet(isPresented: $showingFilters) {
            InquiriesFilterView()
        }
        .sheet(isPresented: $showingCreateInquiry) {
            CreateInquiryView()
        }
        .sheet(item: $selectedInquiry) { inquiry in
            InquiryDetailView(inquiry: inquiry)
        }
        .task {
            await inquiryService.loadInquiries()
        }
        .refreshable {
            await inquiryService.refreshData()
        }
    }
    
    // MARK: - Search Bar removed - now handled by MainContentView
    
    // MARK: - Filter Chips
    
    private var filterChips: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if inquiryService.selectedFilter != .all {
                        FilterChip(
                            title: inquiryService.selectedFilter.displayName,
                            isSelected: true
                        ) {
                            inquiryService.selectedFilter = .all
                        }
                    }
                    
                    if let status = inquiryService.selectedStatus {
                        FilterChip(
                            title: status.displayName,
                            isSelected: true
                        ) {
                            inquiryService.selectedStatus = nil
                        }
                    }
                    
                    if let urgency = inquiryService.selectedUrgency {
                        FilterChip(
                            title: urgency.displayName,
                            isSelected: true
                        ) {
                            inquiryService.selectedUrgency = nil
                        }
                    }
                    
                    Button("Clear All") {
                        inquiryService.clearFilters()
                    }
                    .font(Typography.bodySmall)
                    .foregroundColor(.textLink)
                    .padding(.leading, 8)
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 8)
            
            Divider()
        }
        .background(Color.backgroundSecondary)
    }
    
    // MARK: - Inquiry List
    
    private var inquiryList: some View {
        List {
            // Summary Stats
            if !inquiryService.filteredInquiries.isEmpty {
                Section {
                    InquiriesSummaryCard(inquiries: inquiryService.filteredInquiries)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            
            // Inquiry List
            Section {
                ForEach(inquiryService.filteredInquiries) { inquiry in
                    InquiryRowView(inquiry: inquiry)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedInquiry = inquiry
                        }
                        .onAppear {
                            // Load more inquiries when reaching the end
                            if inquiry.id == inquiryService.filteredInquiries.last?.id {
                                Task {
                                    await inquiryService.loadInquiries()
                                }
                            }
                        }
                }
            } header: {
                if !inquiryService.filteredInquiries.isEmpty {
                    HStack {
                        Text("Inquiries (\(inquiryService.filteredInquiries.count))")
                            .bodyStyle(.medium, color: .textSecondary)
                        
                        Spacer()
                    }
                }
            }
            
            // Loading indicator
            if inquiryService.isLoading {
                Section {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        
                        Text("Loading inquiries...")
                            .bodyStyle(.medium, color: .textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(PlainListStyle())
        .overlay {
            if inquiryService.filteredInquiries.isEmpty && !inquiryService.isLoading {
                InquiryEmptyState()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var hasActiveFilters: Bool {
        inquiryService.selectedFilter != .all ||
        inquiryService.selectedStatus != nil ||
        inquiryService.selectedUrgency != nil ||
        !inquiryService.searchText.isEmpty
    }
}

// MARK: - Supporting Views

struct InquiriesSummaryCard: View {
    let inquiries: [Inquiry]
    
    private var stats: (new: Int, inProgress: Int, overdue: Int, urgent: Int) {
        let new = inquiries.filter { $0.status == .new }.count
        let inProgress = inquiries.filter { $0.status == .inProgress }.count
        let overdue = inquiries.filter { $0.isOverdue }.count
        let urgent = inquiries.filter { $0.urgency == .urgent }.count
        
        return (new: new, inProgress: inProgress, overdue: overdue, urgent: urgent)
    }
    
    var body: some View {
        HStack(spacing: 20) {
            SummaryItem(
                title: "New",
                value: "\(stats.new)",
                color: .info
            )
            
            SummaryItem(
                title: "In Progress",
                value: "\(stats.inProgress)",
                color: .warning
            )
            
            SummaryItem(
                title: "Overdue",
                value: "\(stats.overdue)",
                color: .error
            )
            
            SummaryItem(
                title: "Urgent",
                value: "\(stats.urgent)",
                color: .error
            )
        }
        .padding(16)
        .background(Color.surface)
        .cornerRadius(12)
        .shadow(color: .shadowLight, radius: 4, x: 0, y: 2)
    }
}

struct InquiryRowView: View {
    let inquiry: Inquiry
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(getUrgencyColor(inquiry.urgency))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(inquiry.initials)
                        .font(Typography.label)
                        .foregroundColor(.white)
                        .bold()
                )
            
            // Inquiry Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(inquiry.fullName)
                        .bodyStyle(.medium)
                    
                    Spacer()
                    
                    // Status Badge
                    Text(inquiry.status.displayName)
                        .captionStyle(.small, color: getStatusColor(inquiry.status))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(getStatusColor(inquiry.status).opacity(0.1))
                        .cornerRadius(4)
                }
                
                // Reason for inquiry (truncated)
                Text(inquiry.reasonForInquiry)
                    .bodyStyle(.regular, color: .textSecondary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    // Urgency indicator
                    HStack(spacing: 4) {
                        Image(systemName: inquiry.urgency.icon)
                            .font(.system(size: 10))
                            .foregroundColor(getUrgencyColor(inquiry.urgency))
                        
                        Text(inquiry.urgency.displayName)
                            .captionStyle(.small, color: getUrgencyColor(inquiry.urgency))
                    }
                    
                    // Time indicator
                    Text("\(inquiry.daysSinceCreated) days ago")
                        .captionStyle(.small, color: .textTertiary)
                    
                    // Overdue indicator
                    if inquiry.isOverdue {
                        HStack(spacing: 2) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.error)
                            
                            Text("Overdue")
                                .captionStyle(.small, color: .error)
                        }
                    }
                }
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.textTertiary)
        }
        .padding(.vertical, 4)
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
    
    private func getUrgencyColor(_ urgency: InquiryUrgency) -> Color {
        switch urgency {
        case .low: return .success
        case .medium: return .warning
        case .high: return .error
        case .urgent: return .error
        }
    }
}

struct InquiryEmptyState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "envelope")
                .font(.system(size: 48))
                .foregroundColor(.textTertiary)
            
            VStack(spacing: 8) {
                Text("No Inquiries Found")
                    .headingStyle(.h3)
                
                Text("Inquiries will appear here once they are submitted")
                    .bodyStyle(.medium, color: .textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
    }
}

// MARK: - Previews

#if DEBUG
struct InquiriesListView_Previews: PreviewProvider {
    static var previews: some View {
        InquiriesListView()
    }
}
#endif