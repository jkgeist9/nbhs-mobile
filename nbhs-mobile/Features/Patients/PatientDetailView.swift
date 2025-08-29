//
//  PatientDetailView.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

struct PatientDetailView: View {
    let patient: Patient
    @Environment(\.dismiss) private var dismiss
    @StateObject private var patientService = PatientService.shared
    
    @State private var appointments: [Appointment] = []
    @State private var isLoadingAppointments = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Patient Header
                    patientHeader
                    
                    // Tab Navigation
                    tabNavigation
                    
                    // Tab Content
                    TabView(selection: $selectedTab) {
                        // Overview Tab
                        overviewTab
                            .tag(0)
                        
                        // Appointments Tab
                        appointmentsTab
                            .tag(1)
                        
                        // Medical Tab
                        medicalTab
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: 600) // Fixed height for TabView
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .navigationTitle(patient.fullName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadAppointments()
            }
        }
    }
    
    // MARK: - Patient Header
    
    private var patientHeader: some View {
        VStack(spacing: 16) {
            // Avatar and Basic Info
            HStack(spacing: 16) {
                Circle()
                    .fill(Color.teal500)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(patient.initials)
                            .font(Typography.heading2)
                            .foregroundColor(.white)
                            .bold()
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(patient.fullName)
                        .headingStyle(.h2)
                    
                    HStack(spacing: 12) {
                        InfoChip(
                            icon: "calendar",
                            text: "Age \(patient.age)",
                            color: .textSecondary
                        )
                        
                        InfoChip(
                            icon: patient.status.icon,
                            text: patient.status.displayName,
                            color: getStatusColor(patient.status)
                        )
                    }
                    
                    if let assignedProviderName = patient.assignedProviderName {
                        InfoChip(
                            icon: "stethoscope",
                            text: assignedProviderName,
                            color: .textSecondary
                        )
                    }
                }
                
                Spacer()
            }
            
            // Contact Information
            if patient.email != nil || patient.phone != nil {
                HStack(spacing: 16) {
                    if let email = patient.email {
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
                    
                    if let phone = patient.phone {
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
    }
    
    // MARK: - Tab Navigation
    
    private var tabNavigation: some View {
        HStack(spacing: 0) {
            TabButton(title: "Overview", isSelected: selectedTab == 0) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 0
                }
            }
            
            TabButton(title: "Appointments", isSelected: selectedTab == 1) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 1
                }
            }
            
            TabButton(title: "Medical", isSelected: selectedTab == 2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 2
                }
            }
        }
        .background(Color.surface)
        .cornerRadius(8)
    }
    
    // MARK: - Overview Tab
    
    private var overviewTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Quick Stats
            quickStats
            
            // Recent Activity
            if !appointments.isEmpty {
                recentActivity
            }
            
            // Personal Information
            personalInformation
            
            Spacer()
        }
    }
    
    private var quickStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Stats")
                .headingStyle(.h4)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "Total Visits",
                    value: "\(appointments.filter { $0.status == .completed }.count)",
                    icon: "calendar.badge.checkmark",
                    color: .success
                )
                
                StatCard(
                    title: "Upcoming",
                    value: "\(appointments.filter { $0.isUpcoming }.count)",
                    icon: "calendar.badge.plus",
                    color: .teal500
                )
                
                StatCard(
                    title: "Last Visit",
                    value: patient.daysSinceLastAppointment != nil ? "\(patient.daysSinceLastAppointment!) days ago" : "None",
                    icon: "clock",
                    color: .textSecondary
                )
                
                StatCard(
                    title: "Patient Since",
                    value: patient.createdAt.formatted(.dateTime.year()),
                    icon: "person.badge.plus",
                    color: .info
                )
            }
        }
    }
    
    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Appointments")
                .headingStyle(.h4)
            
            VStack(spacing: 8) {
                ForEach(appointments.prefix(3)) { appointment in
                    AppointmentCard(appointment: appointment)
                }
            }
            
            if appointments.count > 3 {
                Button("View All Appointments") {
                    selectedTab = 1
                }
                .font(Typography.bodyMedium)
                .foregroundColor(.textLink)
            }
        }
    }
    
    private var personalInformation: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personal Information")
                .headingStyle(.h4)
            
            VStack(spacing: 8) {
                InfoRow(label: "Date of Birth", value: patient.dateOfBirth.formatted(date: .long, time: .omitted))
                
                if let address = patient.address {
                    InfoRow(label: "Address", value: address.fullAddress)
                }
                
                if let emergency = patient.emergencyContact {
                    InfoRow(label: "Emergency Contact", value: "\(emergency.name) (\(emergency.relationship))")
                    InfoRow(label: "Emergency Phone", value: emergency.phone)
                }
                
                if let insurance = patient.insurance {
                    InfoRow(label: "Insurance", value: insurance.provider)
                    InfoRow(label: "Policy Number", value: insurance.policyNumber)
                }
            }
        }
    }
    
    // MARK: - Appointments Tab
    
    private var appointmentsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Appointments")
                    .headingStyle(.h4)
                
                Spacer()
                
                Text("\(appointments.count) total")
                    .captionStyle(.regular, color: .textSecondary)
            }
            
            if isLoadingAppointments {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading appointments...")
                        .bodyStyle(.medium, color: .textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 40)
            } else if appointments.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar")
                        .font(.system(size: 48))
                        .foregroundColor(.textTertiary)
                    
                    Text("No Appointments")
                        .headingStyle(.h4)
                    
                    Text("This patient has no appointment history")
                        .bodyStyle(.medium, color: .textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 40)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(appointments) { appointment in
                            AppointmentCard(appointment: appointment)
                        }
                    }
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Medical Tab
    
    private var medicalTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Medical Information")
                .headingStyle(.h4)
            
            if let medicalRecord = patient.medicalRecord {
                VStack(alignment: .leading, spacing: 16) {
                    // Primary Diagnosis
                    if let primaryDiagnosis = medicalRecord.primaryDiagnosis {
                        MedicalSection(title: "Primary Diagnosis", content: primaryDiagnosis)
                    }
                    
                    // Secondary Diagnoses
                    if !medicalRecord.secondaryDiagnoses.isEmpty {
                        MedicalSection(
                            title: "Secondary Diagnoses",
                            content: medicalRecord.secondaryDiagnoses.joined(separator: "\n")
                        )
                    }
                    
                    // Current Medications
                    if !medicalRecord.medications.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Medications")
                                .bodyStyle(.medium, color: .textSecondary)
                            
                            ForEach(medicalRecord.medications.filter { $0.isActive }) { medication in
                                MedicationRow(medication: medication)
                            }
                        }
                    }
                    
                    // Allergies
                    if !medicalRecord.allergies.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Allergies")
                                .bodyStyle(.medium, color: .textSecondary)
                            
                            ForEach(medicalRecord.allergies) { allergy in
                                AllergyRow(allergy: allergy)
                            }
                        }
                    }
                    
                    // Notes
                    if let notes = medicalRecord.notes {
                        MedicalSection(title: "Clinical Notes", content: notes)
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 48))
                        .foregroundColor(.textTertiary)
                    
                    Text("No Medical Records")
                        .headingStyle(.h4)
                    
                    Text("Medical information will appear here once available")
                        .bodyStyle(.medium, color: .textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 40)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadAppointments() async {
        isLoadingAppointments = true
        appointments = await patientService.getPatientAppointments(patient.id)
        isLoadingAppointments = false
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
}

// MARK: - Supporting Views

struct InfoChip: View {
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

struct ContactButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.teal500)
                
                Text(text)
                    .captionStyle(.regular, color: .textLink)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.teal500.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.bodyMedium)
                .foregroundColor(isSelected ? .white : .textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.teal500 : Color.clear)
                .cornerRadius(6)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .bodyStyle(.medium, color: .textSecondary)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .bodyStyle(.regular)
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

struct MedicalSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .bodyStyle(.medium, color: .textSecondary)
            
            Text(content)
                .bodyStyle(.regular)
                .padding(12)
                .background(Color.backgroundTertiary)
                .cornerRadius(8)
        }
    }
}

struct MedicationRow: View {
    let medication: Medication
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .bodyStyle(.medium)
                
                Text("\(medication.dosage) - \(medication.frequency)")
                    .captionStyle(.regular, color: .textSecondary)
            }
            
            Spacer()
            
            Text("Active")
                .captionStyle(.small, color: .success)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.success.opacity(0.1))
                .cornerRadius(4)
        }
        .padding(12)
        .background(Color.surface)
        .cornerRadius(8)
    }
}

struct AllergyRow: View {
    let allergy: Allergy
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(allergy.allergen)
                    .bodyStyle(.medium)
                
                if let reaction = allergy.reaction {
                    Text(reaction)
                        .captionStyle(.regular, color: .textSecondary)
                }
            }
            
            Spacer()
            
            Text(allergy.severity.displayName)
                .captionStyle(.small, color: getSeverityColor(allergy.severity))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(getSeverityColor(allergy.severity).opacity(0.1))
                .cornerRadius(4)
        }
        .padding(12)
        .background(Color.surface)
        .cornerRadius(8)
    }
    
    private func getSeverityColor(_ severity: AllergySeverity) -> Color {
        switch severity {
        case .mild: return .success
        case .moderate: return .warning
        case .severe: return .error
        case .lifeThreatening: return .error
        }
    }
}

// MARK: - Previews

#if DEBUG
struct PatientDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PatientDetailView(patient: Patient(
            id: "1",
            publicId: "P001",
            firstName: "John",
            lastName: "Doe",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -35, to: Date()) ?? Date(),
            email: "john.doe@example.com",
            phone: "(555) 123-4567",
            address: nil,
            emergencyContact: nil,
            insurance: nil,
            medicalRecord: nil,
            status: .active,
            assignedProviderId: "1",
            assignedProviderName: "Dr. Smith",
            createdAt: Date(),
            updatedAt: Date(),
            lastAppointment: nil,
            nextAppointment: nil
        ))
    }
}
#endif