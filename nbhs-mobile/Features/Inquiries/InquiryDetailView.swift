//
//  InquiryDetailView.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

struct InquiryDetailView: View {
    let inquiry: Inquiry
    @Environment(\.dismiss) private var dismiss
    @StateObject private var inquiryService = InquiryService.shared
    
    @State private var selectedTab = 0
    @State private var showingStatusUpdate = false
    @State private var showingContactAttempt = false
    @State private var showingConvertDialog = false
    @State private var isUpdating = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Inquiry Header
                inquiryHeader
                
                // Tab Navigation
                tabNavigation
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    // Overview Tab
                    overviewTab
                        .tag(0)
                    
                    // Contact Attempts Tab
                    contactAttemptsTab
                        .tag(1)
                    
                    // Notes Tab
                    notesTab
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle(inquiry.fullName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showingStatusUpdate = true
                        }) {
                            Label("Update Status", systemImage: "tag")
                        }
                        
                        Button(action: {
                            showingContactAttempt = true
                        }) {
                            Label("Add Contact Attempt", systemImage: "phone.badge.plus")
                        }
                        
                        if inquiry.status != .converted {
                            Button(action: {
                                showingConvertDialog = true
                            }) {
                                Label("Convert to Patient", systemImage: "person.badge.plus")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.teal500)
                    }
                }
            }
            .sheet(isPresented: $showingStatusUpdate) {
                UpdateInquiryStatusView(inquiry: inquiry)
            }
            .sheet(isPresented: $showingContactAttempt) {
                AddContactAttemptView(inquiry: inquiry)
            }
            .alert("Convert to Patient", isPresented: $showingConvertDialog) {
                Button("Convert", role: .destructive) {
                    Task {
                        await convertInquiry()
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will convert the inquiry to a patient record. This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Inquiry Header
    
    private var inquiryHeader: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Avatar
                Circle()
                    .fill(getUrgencyColor(inquiry.urgency))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(inquiry.initials)
                            .font(Typography.heading2)
                            .foregroundColor(.white)
                            .bold()
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(inquiry.fullName)
                        .headingStyle(.h2)
                    
                    HStack(spacing: 12) {
                        StatusChip(
                            icon: inquiry.status.icon,
                            text: inquiry.status.displayName,
                            color: getStatusColor(inquiry.status)
                        )
                        
                        StatusChip(
                            icon: inquiry.urgency.icon,
                            text: inquiry.urgency.displayName,
                            color: getUrgencyColor(inquiry.urgency)
                        )
                    }
                    
                    if inquiry.isOverdue {
                        StatusChip(
                            icon: "exclamationmark.triangle.fill",
                            text: "Overdue",
                            color: .error
                        )
                    }
                }
                
                Spacer()
            }
            
            // Contact Information
            if inquiry.email != nil || inquiry.phone != nil {
                HStack(spacing: 16) {
                    if let email = inquiry.email {
                        ContactButton(
                            icon: "envelope",
                            text: email,
                            action: {
                                if let url = URL(string: "mailto:\(email)") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                    }
                    
                    if let phone = inquiry.phone {
                        ContactButton(
                            icon: "phone",
                            text: phone,
                            action: {
                                if let url = URL(string: "tel:\(phone)") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(Color.surface)
        .cornerRadius(16)
        .shadow(color: .shadowLight, radius: 4, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    // MARK: - Tab Navigation
    
    private var tabNavigation: some View {
        HStack(spacing: 0) {
            TabButton(title: "Overview", isSelected: selectedTab == 0) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 0
                }
            }
            
            TabButton(title: "Contact", isSelected: selectedTab == 1) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 1
                }
            }
            
            TabButton(title: "Notes", isSelected: selectedTab == 2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 2
                }
            }
        }
        .background(Color.surface)
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    // MARK: - Overview Tab
    
    private var overviewTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Basic Information
                InformationSection(title: "Basic Information") {
                    VStack(spacing: 8) {
                        if let age = inquiry.age {
                            InfoRow(label: "Age", value: "\(age) years old")
                        }
                        
                        InfoRow(label: "Preferred Contact", value: inquiry.preferredContactMethod.displayName)
                        InfoRow(label: "Source", value: inquiry.source.displayName)
                        InfoRow(label: "Created", value: inquiry.createdAt.formatted(date: .long, time: .shortened))
                        
                        if let assignedProviderName = inquiry.assignedProviderName {
                            InfoRow(label: "Assigned Provider", value: assignedProviderName)
                        }
                        
                        if let followUpDate = inquiry.followUpDate {
                            InfoRow(label: "Follow-up Date", value: followUpDate.formatted(date: .long, time: .omitted))
                        }
                    }
                }
                
                // Reason for Inquiry
                InformationSection(title: "Reason for Inquiry") {
                    Text(inquiry.reasonForInquiry)
                        .bodyStyle(.regular)
                        .padding(12)
                        .background(Color.backgroundTertiary)
                        .cornerRadius(8)
                }
                
                // Guardian Information (if applicable)
                if inquiry.guardianName != nil || inquiry.guardianEmail != nil || inquiry.guardianPhone != nil {
                    InformationSection(title: "Guardian Information") {
                        VStack(spacing: 8) {
                            if let guardianName = inquiry.guardianName {
                                InfoRow(label: "Guardian Name", value: guardianName)
                            }
                            
                            if let guardianEmail = inquiry.guardianEmail {
                                InfoRow(label: "Guardian Email", value: guardianEmail)
                            }
                            
                            if let guardianPhone = inquiry.guardianPhone {
                                InfoRow(label: "Guardian Phone", value: guardianPhone)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(16)
        }
    }
    
    // MARK: - Contact Attempts Tab
    
    private var contactAttemptsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Contact Attempts")
                    .headingStyle(.h4)
                
                Spacer()
                
                Button(action: {
                    showingContactAttempt = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.teal500)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            if let contactAttempts = inquiry.contactAttempts, !contactAttempts.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(contactAttempts.contactAttemptsList) { attempt in
                            ContactAttemptRow(attempt: attempt)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "phone")
                        .font(.system(size: 48))
                        .foregroundColor(.textTertiary)
                    
                    Text("No Contact Attempts")
                        .headingStyle(.h4)
                    
                    Text("Contact attempts will appear here")
                        .bodyStyle(.medium, color: .textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(40)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Notes Tab
    
    private var notesTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notes")
                .headingStyle(.h4)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            if let notes = inquiry.notes, !notes.isEmpty {
                ScrollView {
                    Text(notes)
                        .bodyStyle(.regular)
                        .padding(16)
                        .background(Color.backgroundTertiary)
                        .cornerRadius(8)
                        .padding(.horizontal, 16)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "note.text")
                        .font(.system(size: 48))
                        .foregroundColor(.textTertiary)
                    
                    Text("No Notes")
                        .headingStyle(.h4)
                    
                    Text("Notes will appear here when added")
                        .bodyStyle(.medium, color: .textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(40)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Helper Methods
    
    private func convertInquiry() async {
        isUpdating = true
        let request = ConvertInquiryRequest(assignedProviderId: nil, notes: "Converted from iOS app")
        let success = await inquiryService.convertInquiry(inquiry.id, request: request)
        
        if success {
            dismiss()
        }
        isUpdating = false
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

// MARK: - Supporting Views

struct StatusChip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(text)
                .captionStyle(.regular, color: color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

struct InformationSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .headingStyle(.h4)
            
            content
        }
    }
}

struct ContactAttemptRow: View {
    let attempt: ContactAttempt
    
    var body: some View {
        HStack(spacing: 12) {
            // Method Icon
            Circle()
                .fill(getOutcomeColor(attempt.outcome))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: attempt.method.icon)
                        .font(.caption)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(attempt.outcome.displayName)
                        .bodyStyle(.medium)
                    
                    Spacer()
                    
                    Text(attempt.createdAt.formatted(.dateTime.hour().minute()))
                        .captionStyle(.small, color: .textSecondary)
                }
                
                Text("by \(attempt.createdByName)")
                    .captionStyle(.regular, color: .textSecondary)
                
                if let notes = attempt.notes {
                    Text(notes)
                        .captionStyle(.regular, color: .textSecondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(12)
        .background(Color.surface)
        .cornerRadius(8)
    }
    
    private func getOutcomeColor(_ outcome: ContactOutcome) -> Color {
        switch outcome {
        case .successful: return .success
        case .noAnswer, .busySignal: return .warning
        case .leftMessage, .requestedCallback: return .info
        case .invalidNumber, .emailBounced: return .error
        }
    }
}


// MARK: - Previews

#if DEBUG
struct InquiryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePatient = InquiryPatient(
            id: "patient1",
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            phone: "(555) 123-4567",
            patientDetails: InquiryPatientDetails(dateOfBirth: Calendar.current.date(byAdding: .year, value: -25, to: Date()))
        )
        
        let sampleInquiry = Inquiry(
            id: "1",
            publicId: nil,
            createdAt: Date(),
            updatedAt: Date(),
            inquiryFor: "SELF",
            patientId: "patient1",
            guardianId: nil,
            referralSource: "WEBSITE",
            referralDetails: "Looking for behavioral health services for anxiety and depression.",
            urgencyLevel: "MEDIUM",
            preferredContact: "PHONE",
            bestTimeToCall: "morning",
            statusRaw: "NEW",
            priority: "MEDIUM",
            reviewedAt: nil,
            reviewedById: nil,
            reviewNotes: nil,
            reviewDecision: nil,
            assignedToId: nil,
            assignedAt: nil,
            patient: samplePatient,
            guardian: nil,
            contactAttempts: .count(0)
        )
        
        InquiryDetailView(inquiry: sampleInquiry)
    }
}
#endif