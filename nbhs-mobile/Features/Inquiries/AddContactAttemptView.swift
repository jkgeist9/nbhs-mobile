//
//  AddContactAttemptView.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

struct AddContactAttemptView: View {
    let inquiry: Inquiry
    @StateObject private var inquiryService = InquiryService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedMethod: ContactMethod = .phone
    @State private var selectedOutcome: ContactOutcome = .successful
    @State private var notes = ""
    @State private var needsFollowUp = false
    @State private var followUpDate = Date().addingTimeInterval(86400) // Tomorrow
    
    @State private var isAdding = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            formContent
                .navigationTitle("Add Contact Attempt")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        cancelButton
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        addButton
                    }
                }
                .alert("Error", isPresented: $showingError) {
                    Button("OK") { }
                } message: {
                    Text(errorMessage)
                }
        }
    }
    
    // MARK: - Computed Properties
    
    private var formContent: some View {
        Form {
            contactMethodSection
            contactOutcomeSection
            notesSection
            followUpSection
        }
    }
    
    private var contactMethodSection: some View {
        Section("Contact Method") {
            ForEach(ContactMethod.allCases, id: \.self) { method in
                let isSelected = selectedMethod == method
                ContactMethodSelectionRow(
                    method: method,
                    isSelected: isSelected
                ) {
                    selectedMethod = method
                }
            }
        }
    }
    
    private var contactOutcomeSection: some View {
        Section("Outcome") {
            ForEach(ContactOutcome.allCases, id: \.self) { outcome in
                let isSelected = selectedOutcome == outcome
                OutcomeRow(
                    outcome: outcome,
                    isSelected: isSelected
                ) {
                    selectedOutcome = outcome
                }
            }
        }
    }
    
    private var notesSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: $notes)
                    .frame(minHeight: 80)
                    .font(Typography.body)
            }
            .padding(.vertical, 4)
        } header: {
            Text("Notes")
        } footer: {
            Text("Add any relevant details about the contact attempt")
                .captionStyle(.regular, color: .textTertiary)
        }
    }
    
    private var followUpSection: some View {
        Section {
            Toggle("Schedule follow-up", isOn: $needsFollowUp)
            
            if needsFollowUp {
                DatePicker(
                    "Follow-up Date",
                    selection: $followUpDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
        } header: {
            Text("Follow-up")
        } footer: {
            followUpFooter
        }
    }
    
    @ViewBuilder
    private var followUpFooter: some View {
        if needsFollowUp {
            Text("A reminder will be set for the selected date and time")
                .captionStyle(.regular, color: .textTertiary)
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    
    private var addButton: some View {
        Button("Add") {
            Task {
                await addContactAttempt()
            }
        }
        .fontWeight(.semibold)
        .disabled(isAdding)
    }
    
    private func addContactAttempt() async {
        isAdding = true
        
        let notesValue = notes.isEmpty ? nil : notes
        let followUpValue = needsFollowUp ? followUpDate : nil
        
        let request = CreateContactAttemptRequest(
            method: selectedMethod,
            outcome: selectedOutcome,
            notes: notesValue,
            scheduledFollowUp: followUpValue
        )
        
        let success = await inquiryService.addContactAttempt(inquiry.id, request: request)
        
        if success {
            dismiss()
        } else if let error = inquiryService.error {
            errorMessage = error
            showingError = true
        }
        
        isAdding = false
    }
}

struct ContactMethodSelectionRow: View {
    let method: ContactMethod
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: method.icon)
                    .font(.system(size: 16))
                    .foregroundColor(.teal500)
                    .frame(width: 24)
                
                Text(method.displayName)
                    .bodyStyle(.medium)
                    .foregroundColor(.textPrimary)
                
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

struct OutcomeRow: View {
    let outcome: ContactOutcome
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: outcome.icon)
                    .font(.system(size: 16))
                    .foregroundColor(getOutcomeColor(outcome))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(outcome.displayName)
                        .bodyStyle(.medium)
                        .foregroundColor(.textPrimary)
                    
                    Text(getOutcomeDescription(outcome))
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
    
    private func getOutcomeColor(_ outcome: ContactOutcome) -> Color {
        switch outcome {
        case .successful: return .success
        case .noAnswer, .busySignal: return .warning
        case .leftMessage, .requestedCallback: return .info
        case .invalidNumber, .emailBounced: return .error
        }
    }
    
    private func getOutcomeDescription(_ outcome: ContactOutcome) -> String {
        switch outcome {
        case .successful: return "Made contact and spoke with client"
        case .noAnswer: return "Phone rang but no one answered"
        case .leftMessage: return "Left voicemail or message"
        case .busySignal: return "Line was busy"
        case .invalidNumber: return "Number is not valid or disconnected"
        case .emailBounced: return "Email was returned as undeliverable"
        case .requestedCallback: return "Client requested to be called back"
        }
    }
}

#if DEBUG
struct AddContactAttemptView_Previews: PreviewProvider {
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
        
        AddContactAttemptView(inquiry: sampleInquiry)
    }
}
#endif