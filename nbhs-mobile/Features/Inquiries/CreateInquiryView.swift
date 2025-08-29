//
//  CreateInquiryView.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

// MARK: - InputField Wrapper

struct InputField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let isRequired: Bool
    
    init(
        label: String,
        text: Binding<String>,
        placeholder: String,
        keyboardType: UIKeyboardType = .default,
        isRequired: Bool = false
    ) {
        self.label = label
        self._text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.isRequired = isRequired
    }
    
    var body: some View {
        let inputType: NBInputType = {
            switch keyboardType {
            case .emailAddress: return .email
            case .phonePad: return .phone
            default: return .text
            }
        }()
        
        NBInputField(
            label: label,
            placeholder: placeholder,
            text: $text,
            type: inputType,
            isRequired: isRequired
        )
    }
}

struct CreateInquiryView: View {
    @StateObject private var inquiryService = InquiryService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var dateOfBirth = Date()
    @State private var showDatePicker = false
    
    // Guardian information (optional)
    @State private var guardianName = ""
    @State private var guardianEmail = ""
    @State private var guardianPhone = ""
    @State private var needsGuardian = false
    
    @State private var reasonForInquiry = ""
    @State private var preferredContactMethod: ContactMethod = .email
    @State private var urgency: InquiryUrgency = .medium
    @State private var source: InquirySource = .phone
    @State private var notes = ""
    
    @State private var isCreating = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            formContent
                .navigationTitle("New Inquiry")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        cancelButton
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        createButton
                    }
                }
                .sheet(isPresented: $showDatePicker) {
                    datePickerSheet
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
            patientInformationSection
            guardianInformationSection
            inquiryDetailsSection
            additionalNotesSection
        }
    }
    
    private var patientInformationSection: some View {
        Section("Patient Information") {
            nameFields
            emailField
            phoneField
            dateOfBirthField
        }
    }
    
    private var nameFields: some View {
        HStack {
            InputField(
                label: "First Name",
                text: $firstName,
                placeholder: "Enter first name",
                isRequired: true
            )
            
            InputField(
                label: "Last Name",
                text: $lastName,
                placeholder: "Enter last name",
                isRequired: true
            )
        }
    }
    
    private var emailField: some View {
        InputField(
            label: "Email",
            text: $email,
            placeholder: "Enter email address",
            keyboardType: .emailAddress
        )
    }
    
    private var phoneField: some View {
        InputField(
            label: "Phone",
            text: $phone,
            placeholder: "Enter phone number",
            keyboardType: .phonePad
        )
    }
    
    private var dateOfBirthField: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.textSecondary)
                Text("Date of Birth")
                    .captionStyle(.regular, color: .textSecondary)
            }
            
            Button(action: {
                showDatePicker = true
            }) {
                Text(dateOfBirth.formatted(date: .long, time: .omitted))
                    .bodyStyle(.regular)
                    .foregroundColor(.textPrimary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var guardianInformationSection: some View {
        Section {
            Toggle("Patient needs guardian", isOn: $needsGuardian)
            
            if needsGuardian {
                guardianFields
            }
        } header: {
            Text("Guardian Information")
        } footer: {
            guardianFooter
        }
    }
    
    private var guardianFields: some View {
        Group {
            InputField(
                label: "Guardian Name",
                text: $guardianName,
                placeholder: "Enter guardian name"
            )
            
            InputField(
                label: "Guardian Email",
                text: $guardianEmail,
                placeholder: "Enter guardian email",
                keyboardType: .emailAddress
            )
            
            InputField(
                label: "Guardian Phone",
                text: $guardianPhone,
                placeholder: "Enter guardian phone",
                keyboardType: .phonePad
            )
        }
    }
    
    @ViewBuilder
    private var guardianFooter: some View {
        if needsGuardian {
            Text("Required for patients under 18 or those needing assistance")
                .captionStyle(.regular, color: .textTertiary)
        }
    }
    
    private var inquiryDetailsSection: some View {
        Section("Inquiry Details") {
            reasonForInquiryField
            contactMethodSelection
            urgencySelection
            sourceSelection
        }
    }
    
    private var reasonForInquiryField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "text.bubble")
                    .foregroundColor(.textSecondary)
                Text("Reason for Inquiry *")
                    .captionStyle(.regular, color: .textSecondary)
            }
            
            TextEditor(text: $reasonForInquiry)
                .frame(minHeight: 80)
                .font(Typography.body)
        }
        .padding(.vertical, 4)
    }
    
    private var contactMethodSelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preferred Contact Method")
                .captionStyle(.regular, color: .textSecondary)
            
            ForEach(ContactMethod.allCases, id: \.self) { method in
                let isSelected = preferredContactMethod == method
                ContactMethodRow(
                    method: method,
                    isSelected: isSelected
                ) {
                    preferredContactMethod = method
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var urgencySelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Urgency Level")
                .captionStyle(.regular, color: .textSecondary)
            
            ForEach(InquiryUrgency.allCases, id: \.self) { urgencyLevel in
                let isSelected = urgency == urgencyLevel
                UrgencyRow(
                    urgency: urgencyLevel,
                    isSelected: isSelected
                ) {
                    urgency = urgencyLevel
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var sourceSelection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How did you hear about us?")
                .captionStyle(.regular, color: .textSecondary)
            
            Picker("Source", selection: $source) {
                ForEach(InquirySource.allCases, id: \.self) { source in
                    Text(source.displayName).tag(source)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
    
    private var additionalNotesSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: $notes)
                    .frame(minHeight: 60)
                    .font(Typography.body)
            }
            .padding(.vertical, 4)
        } header: {
            Text("Additional Notes")
        } footer: {
            Text("Any additional information that might be helpful")
                .captionStyle(.regular, color: .textTertiary)
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    
    private var createButton: some View {
        Button("Create") {
            Task {
                await createInquiry()
            }
        }
        .fontWeight(.semibold)
        .disabled(!isFormValid || isCreating)
    }
    
    private var datePickerSheet: some View {
        DatePicker(
            "Date of Birth",
            selection: $dateOfBirth,
            displayedComponents: .date
        )
        .datePickerStyle(WheelDatePickerStyle())
        .padding()
        .presentationDetents([.medium])
    }
    
    // MARK: - Helper Methods
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !reasonForInquiry.isEmpty &&
        (!needsGuardian || !guardianName.isEmpty)
    }
    
    private func createInquiry() async {
        isCreating = true
        
        let request = CreateInquiryRequest(
            firstName: firstName,
            lastName: lastName,
            email: email.isEmpty ? nil : email,
            phone: phone.isEmpty ? nil : phone,
            dateOfBirth: dateOfBirth,
            guardianName: needsGuardian && !guardianName.isEmpty ? guardianName : nil,
            guardianEmail: needsGuardian && !guardianEmail.isEmpty ? guardianEmail : nil,
            guardianPhone: needsGuardian && !guardianPhone.isEmpty ? guardianPhone : nil,
            reasonForInquiry: reasonForInquiry,
            preferredContactMethod: preferredContactMethod,
            urgency: urgency,
            source: source,
            notes: notes.isEmpty ? nil : notes
        )
        
        let inquiry = await inquiryService.createInquiry(request)
        
        if inquiry != nil {
            dismiss()
        } else if let error = inquiryService.error {
            errorMessage = error
            showingError = true
        }
        
        isCreating = false
    }
}

// MARK: - Supporting Views

struct ContactMethodRow: View {
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
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(method.displayName)
                        .bodyStyle(.medium)
                        .foregroundColor(.textPrimary)
                    
                    Text(getContactMethodDescription(method))
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
    
    private func getContactMethodDescription(_ method: ContactMethod) -> String {
        switch method {
        case .email: return "Communicate via email"
        case .phone: return "Prefer phone calls"
        case .text: return "Text message preferred"
        case .any: return "Any method is fine"
        }
    }
}

struct UrgencyRow: View {
    let urgency: InquiryUrgency
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: urgency.icon)
                    .font(.system(size: 16))
                    .foregroundColor(getUrgencyColor(urgency))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(urgency.displayName)
                        .bodyStyle(.medium)
                        .foregroundColor(.textPrimary)
                    
                    Text(getUrgencyDescription(urgency))
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
    
    private func getUrgencyColor(_ urgency: InquiryUrgency) -> Color {
        switch urgency {
        case .low: return .success
        case .medium: return .warning
        case .high: return .error
        case .urgent: return .error
        }
    }
    
    private func getUrgencyDescription(_ urgency: InquiryUrgency) -> String {
        switch urgency {
        case .low: return "Can wait, not time sensitive"
        case .medium: return "Normal priority, within a week"
        case .high: return "Important, needs attention soon"
        case .urgent: return "Critical, immediate attention needed"
        }
    }
}

// MARK: - Previews

#if DEBUG
struct CreateInquiryView_Previews: PreviewProvider {
    static var previews: some View {
        CreateInquiryView()
    }
}
#endif