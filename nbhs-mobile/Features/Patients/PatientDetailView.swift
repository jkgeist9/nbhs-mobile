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
                            icon: "person.circle",
                            text: patient.status,
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
                    subtitle: "Completed appointments",
                    icon: "calendar.badge.checkmark",
                    color: .success
                )
                
                StatCard(
                    title: "Upcoming",
                    value: "\(appointments.filter { $0.isUpcoming }.count)",
                    subtitle: "Future appointments",
                    icon: "calendar.badge.plus",
                    color: .teal500
                )
                
                StatCard(
                    title: "Evaluations",
                    value: "\(patient.evaluationsCount ?? 0)",
                    subtitle: "Total evaluations",
                    icon: "doc.text",
                    color: .textSecondary
                )
                
                StatCard(
                    title: "Appointments",
                    value: "\(patient.appointmentsCount ?? 0)",
                    subtitle: "Total appointments",
                    icon: "calendar",
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
                if let dateOfBirth = patient.dateOfBirth {
                    InfoRow(label: "Date of Birth", value: dateOfBirth.formatted(date: .long, time: .omitted))
                }
                
                if let publicId = patient.publicId {
                    InfoRow(label: "Patient ID", value: publicId)
                }
                
                InfoRow(label: "Status", value: patient.status)
                
                if let workflowStatus = patient.patientWorkflowStatus {
                    InfoRow(label: "Workflow Status", value: workflowStatus)
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
            
            VStack(spacing: 16) {
                Image(systemName: "doc.text")
                    .font(.system(size: 48))
                    .foregroundColor(.textTertiary)
                
                Text("Medical Records")
                    .headingStyle(.h4)
                
                Text("Medical information will be available in a future update")
                    .bodyStyle(.medium, color: .textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 40)
            
            Spacer()
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadAppointments() async {
        isLoadingAppointments = true
        // For now, appointments will be empty since we simplified the API
        appointments = []
        isLoadingAppointments = false
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


// MARK: - Previews

#if DEBUG
struct PatientDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PatientDetailView(patient: Patient(
            id: "1",
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            phone: "(555) 123-4567",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -35, to: Date()) ?? Date(),
            status: "ACTIVE",
            patientWorkflowStatus: "INTAKE_COMPLETE",
            evaluationsCount: 2,
            appointmentsCount: 5,
            patientDetails: PatientAPIDetails(
                id: "det-1",
                publicId: "PAT-202508-0001"
            )
        ))
    }
}
#endif