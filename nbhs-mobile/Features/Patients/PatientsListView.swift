//
//  PatientsListView.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

struct PatientsListView: View {
    @StateObject private var patientService = PatientService.shared
    @State private var showingFilters = false
    @State private var showingSearch = false
    @State private var selectedPatient: Patient?
    @State private var showingPatientDetail = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                if showingSearch {
                    searchBar
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Filter Chips
                if hasActiveFilters {
                    filterChips
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Patient List
                patientList
            }
            .nbNavigationTitle("Patients")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            showingSearch.toggle()
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.teal500)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFilters = true
                    }) {
                        Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundColor(.teal500)
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                PatientsFilterView()
            }
            .sheet(item: $selectedPatient) { patient in
                PatientDetailView(patient: patient)
            }
            .task {
                await patientService.loadPatients()
            }
            .refreshable {
                await patientService.refreshData()
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.textTertiary)
                
                TextField("Search patients...", text: $patientService.searchText)
                    .font(Typography.body)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !patientService.searchText.isEmpty {
                    Button(action: {
                        patientService.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.surface)
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            Divider()
        }
        .background(Color.backgroundSecondary)
    }
    
    // MARK: - Filter Chips
    
    private var filterChips: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Filter chips would go here when filters are re-implemented
                    
                    Button("Clear All") {
                        patientService.clearFilters()
                        Task {
                            await patientService.loadPatients(refresh: true)
                        }
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
    
    // MARK: - Patient List
    
    private var patientList: some View {
        List {
            // Summary Stats
            if patientService.filteredPatients.count > 0 {
                Section {
                    PatientsSummaryCard(
                        totalPatients: patientService.filteredPatients.count,
                        activePatients: patientService.filteredPatients.filter { $0.status == "ACTIVE" }.count,
                        patientsWithAppointments: patientService.filteredPatients.filter { ($0.appointmentsCount ?? 0) > 0 }.count
                    )
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            
            // Patient List
            Section {
                ForEach(patientService.filteredPatients) { patient in
                    PatientRowView(patient: patient)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPatient = patient
                        }
                        .onAppear {
                            // Load more patients when reaching the end
                            if patient.id == patientService.filteredPatients.last?.id {
                                Task {
                                    await patientService.loadPatients()
                                }
                            }
                        }
                }
            } header: {
                if patientService.filteredPatients.count > 0 {
                    HStack {
                        Text("Patients (\(patientService.filteredPatients.count))")
                            .bodyStyle(.medium, color: .textSecondary)
                        
                        Spacer()
                    }
                }
            }
            
            // Loading indicator
            if patientService.isLoading {
                Section {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        
                        Text("Loading patients...")
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
            if patientService.filteredPatients.isEmpty && !patientService.isLoading {
                PatientEmptyState()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var hasActiveFilters: Bool {
        // For now, no active filters since we simplified the model
        false
    }
}

// MARK: - Supporting Views

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(title)
                    .font(Typography.bodySmall)
                    .foregroundColor(isSelected ? .white : .textPrimary)
                
                if isSelected {
                    Image(systemName: "xmark")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.teal500 : Color.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : Color.border, lineWidth: 1)
            )
        }
    }
}

struct PatientsSummaryCard: View {
    let totalPatients: Int
    let activePatients: Int
    let patientsWithAppointments: Int
    
    var body: some View {
        HStack(spacing: 20) {
            SummaryItem(
                title: "Total",
                value: "\(totalPatients)",
                color: .textPrimary
            )
            
            SummaryItem(
                title: "Active",
                value: "\(activePatients)",
                color: .success
            )
            
            SummaryItem(
                title: "With Appts",
                value: "\(patientsWithAppointments)",
                color: .teal500
            )
        }
        .padding(16)
        .background(Color.surface)
        .cornerRadius(12)
        .shadow(color: .shadowLight, radius: 4, x: 0, y: 2)
    }
}

struct SummaryItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .headingStyle(.h3)
                .foregroundColor(color)
            
            Text(title)
                .captionStyle(.regular, color: .textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PatientRowView: View {
    let patient: Patient
    
    var body: some View {
        HStack(spacing: 12) {
            // Patient Avatar
            Circle()
                .fill(Color.teal500)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(patient.initials)
                        .font(Typography.label)
                        .foregroundColor(.white)
                        .bold()
                )
            
            // Patient Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(patient.fullName)
                        .bodyStyle(.medium)
                    
                    Spacer()
                    
                    // Status Badge
                    Text(patient.status)
                        .captionStyle(.small, color: .textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.textSecondary.opacity(0.1))
                        .cornerRadius(4)
                }
                
                HStack(spacing: 12) {
                    Text("Age \(patient.age)")
                        .captionStyle(.regular, color: .textSecondary)
                    
                    if (patient.appointmentsCount ?? 0) > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                                .foregroundColor(.success)
                            
                            Text("\(patient.appointmentsCount ?? 0) appts")
                                .captionStyle(.small, color: .success)
                        }
                    }
                }
                
                if (patient.evaluationsCount ?? 0) > 0 {
                    Text("\(patient.evaluationsCount ?? 0) evaluations")
                        .captionStyle(.small, color: .textTertiary)
                } else {
                    Text("No evaluations")
                        .captionStyle(.small, color: .textTertiary)
                }
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.textTertiary)
        }
        .padding(.vertical, 4)
    }
    
}

struct PatientEmptyState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2")
                .font(.system(size: 48))
                .foregroundColor(.textTertiary)
            
            VStack(spacing: 8) {
                Text("No Patients Found")
                    .headingStyle(.h3)
                
                Text("Try adjusting your search or filters")
                    .bodyStyle(.medium, color: .textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
    }
}

// MARK: - Previews

#if DEBUG
struct PatientsListView_Previews: PreviewProvider {
    static var previews: some View {
        PatientsListView()
    }
}
#endif