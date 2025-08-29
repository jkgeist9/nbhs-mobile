//
//  PatientService.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import Foundation
import Combine

class PatientService: ObservableObject {
    static let shared = PatientService()
    
    @Published var patients: [Patient] = []
    @Published var filteredPatients: [Patient] = []
    @Published var selectedPatient: Patient?
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText = ""
    @Published var selectedStatus: PatientStatus?
    @Published var sortOption: PatientSortOption = .name
    @Published var sortOrder: SortOrder = .ascending
    
    private let apiClient = APIClient.shared
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private var hasMore = true
    
    private init() {
        setupSearchBinding()
        setupFilterBinding()
    }
    
    // MARK: - Public Methods
    
    @MainActor
    func loadPatients(refresh: Bool = false) async {
        if refresh {
            currentPage = 0
            hasMore = true
            patients.removeAll()
        }
        
        guard hasMore && !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            let criteria = PatientSearchCriteria(
                searchTerm: searchText.isEmpty ? nil : searchText,
                status: selectedStatus,
                providerId: nil, // Will be set by backend based on auth
                sortBy: sortOption,
                sortOrder: sortOrder,
                limit: 20,
                offset: currentPage * 20
            )
            
            let response: APIResponse<PatientListResponse> = try await apiClient.post(
                endpoint: APIConfig.Endpoints.patients,
                body: criteria
            )
            
            if let data = response.data {
                if refresh {
                    self.patients = data.patients
                } else {
                    self.patients.append(contentsOf: data.patients)
                }
                self.hasMore = data.hasMore
                self.currentPage += 1
                
                // Update filtered patients
                updateFilteredPatients()
            } else {
                throw APIError.noData
            }
            
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
            } else {
                self.error = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadPatientDetails(_ patientId: String) async -> Patient? {
        do {
            let response: APIResponse<Patient> = try await apiClient.get(
                endpoint: APIConfig.Endpoints.patient(patientId)
            )
            
            if let patient = response.data {
                // Update the patient in our local array
                if let index = patients.firstIndex(where: { $0.id == patientId }) {
                    patients[index] = patient
                }
                updateFilteredPatients()
                return patient
            }
            
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
            } else {
                self.error = error.localizedDescription
            }
        }
        
        return nil
    }
    
    @MainActor
    func searchPatients(_ searchTerm: String) async {
        self.searchText = searchTerm
        await loadPatients(refresh: true)
    }
    
    @MainActor
    func filterByStatus(_ status: PatientStatus?) async {
        self.selectedStatus = status
        await loadPatients(refresh: true)
    }
    
    @MainActor
    func sortPatients(by option: PatientSortOption, order: SortOrder) async {
        self.sortOption = option
        self.sortOrder = order
        await loadPatients(refresh: true)
    }
    
    @MainActor
    func getPatientStatistics() async -> PatientStatistics? {
        do {
            let response: APIResponse<PatientStatistics> = try await apiClient.get(
                endpoint: "/patients/statistics"
            )
            return response.data
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }
    
    @MainActor
    func getPatientAppointments(_ patientId: String) async -> [Appointment] {
        do {
            let response: APIResponse<[Appointment]> = try await apiClient.get(
                endpoint: APIConfig.Endpoints.patientAppointments(patientId)
            )
            return response.data ?? []
        } catch {
            self.error = error.localizedDescription
            return []
        }
    }
    
    @MainActor
    func updatePatientStatus(_ patientId: String, status: PatientStatus) async -> Bool {
        do {
            let request = ["status": status.rawValue]
            let response: APIResponse<Patient> = try await apiClient.post(
                endpoint: "/patients/\(patientId)/status",
                body: request
            )
            
            if let updatedPatient = response.data {
                // Update local data
                if let index = patients.firstIndex(where: { $0.id == patientId }) {
                    patients[index] = updatedPatient
                }
                updateFilteredPatients()
                return true
            }
            return false
            
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Private Methods
    
    private func setupSearchBinding() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.updateFilteredPatients()
            }
            .store(in: &cancellables)
    }
    
    private func setupFilterBinding() {
        Publishers.CombineLatest($selectedStatus, $sortOption)
            .sink { [weak self] _, _ in
                self?.updateFilteredPatients()
            }
            .store(in: &cancellables)
    }
    
    private func updateFilteredPatients() {
        var filtered = patients
        
        // Apply text search
        if !searchText.isEmpty {
            filtered = filtered.filter { patient in
                patient.fullName.localizedCaseInsensitiveContains(searchText) ||
                patient.email?.localizedCaseInsensitiveContains(searchText) == true ||
                patient.phone?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // Apply status filter
        if let selectedStatus = selectedStatus {
            filtered = filtered.filter { $0.status == selectedStatus }
        }
        
        // Apply sorting
        filtered.sort { patient1, patient2 in
            let ascending = sortOrder == .ascending
            
            switch sortOption {
            case .name:
                return ascending ? 
                    patient1.fullName < patient2.fullName :
                    patient1.fullName > patient2.fullName
                    
            case .lastAppointment:
                let date1 = patient1.lastAppointment ?? Date.distantPast
                let date2 = patient2.lastAppointment ?? Date.distantPast
                return ascending ? date1 < date2 : date1 > date2
                
            case .nextAppointment:
                let date1 = patient1.nextAppointment ?? Date.distantFuture
                let date2 = patient2.nextAppointment ?? Date.distantFuture
                return ascending ? date1 < date2 : date1 > date2
                
            case .createdAt:
                return ascending ? 
                    patient1.createdAt < patient2.createdAt :
                    patient1.createdAt > patient2.createdAt
                    
            case .status:
                return ascending ?
                    patient1.status.rawValue < patient2.status.rawValue :
                    patient1.status.rawValue > patient2.status.rawValue
            }
        }
        
        self.filteredPatients = filtered
    }
    
    // MARK: - Helper Methods
    
    func clearFilters() {
        searchText = ""
        selectedStatus = nil
        sortOption = .name
        sortOrder = .ascending
    }
    
    func getPatientById(_ id: String) -> Patient? {
        return patients.first { $0.id == id }
    }
    
    func refreshData() async {
        await loadPatients(refresh: true)
    }
}