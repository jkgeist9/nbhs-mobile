//
//  UpdateInquiryStatusView.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

struct UpdateInquiryStatusView: View {
    let inquiry: Inquiry
    @StateObject private var inquiryService = InquiryService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedStatus: InquiryStatus
    @State private var isUpdating = false
    
    init(inquiry: Inquiry) {
        self.inquiry = inquiry
        _selectedStatus = State(initialValue: inquiry.status)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Current Status") {
                    HStack {
                        Image(systemName: inquiry.status.icon)
                            .foregroundColor(getStatusColor(inquiry.status))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(inquiry.status.displayName)
                                .bodyStyle(.medium)
                            
                            Text("Current status")
                                .captionStyle(.regular, color: .textSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                
                Section("New Status") {
                    ForEach(InquiryStatus.allCases, id: \.self) { status in
                        StatusRow(
                            status: status,
                            isSelected: selectedStatus == status,
                            isCurrentStatus: status == inquiry.status
                        ) {
                            selectedStatus = status
                        }
                    }
                }
            }
            .navigationTitle("Update Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Update") {
                        Task {
                            await updateStatus()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedStatus == inquiry.status || isUpdating)
                }
            }
        }
    }
    
    private func updateStatus() async {
        isUpdating = true
        
        let success = await inquiryService.updateInquiryStatus(inquiry.id, status: selectedStatus)
        
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
}

struct StatusRow: View {
    let status: InquiryStatus
    let isSelected: Bool
    let isCurrentStatus: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: status.icon)
                    .font(.system(size: 16))
                    .foregroundColor(getStatusColor(status))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(status.displayName)
                            .bodyStyle(.medium)
                            .foregroundColor(.textPrimary)
                        
                        if isCurrentStatus {
                            Text("(Current)")
                                .captionStyle(.small, color: .textSecondary)
                        }
                    }
                    
                    Text(getStatusDescription(status))
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
        .disabled(isCurrentStatus)
        .opacity(isCurrentStatus ? 0.6 : 1.0)
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
    
    private func getStatusDescription(_ status: InquiryStatus) -> String {
        switch status {
        case .new: return "Just received, needs initial review"
        case .inProgress: return "Currently being processed"
        case .awaitingResponse: return "Waiting for client to respond"
        case .scheduled: return "Appointment has been scheduled"
        case .completed: return "Process completed successfully"
        case .converted: return "Converted to patient record"
        case .closed: return "Inquiry closed, no further action"
        }
    }
}

#if DEBUG
struct UpdateInquiryStatusView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePatient = InquiryPatient(
            id: "patient1",
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            phone: "(555) 123-4567",
            patientDetails: InquiryPatientDetails(dateOfBirth: Date())
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
            referralDetails: "Looking for behavioral health services",
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
        
        UpdateInquiryStatusView(inquiry: sampleInquiry)
    }
}
#endif