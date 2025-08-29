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
    
    private let apiClient = APIClient.shared
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private var hasMore = true
    
    private init() {
        setupSearchBinding()
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
            // Build query parameters
            var queryParams: [String: String] = [
                "page": String(currentPage + 1),
                "limit": "20"
            ]
            
            if !searchText.isEmpty {
                queryParams["search"] = searchText
            }
            
            
            let queryString = queryParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            let endpoint = APIConfig.Endpoints.patients + "?" + queryString
            
            print("🌐 Making API request to: \(APIConfig.baseURL + endpoint)")
            
            // Make direct API call to handle the actual response format
            guard let url = URL(string: APIConfig.baseURL + endpoint) else {
                throw APIError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // Add auth headers
            if let token = KeychainManager.shared.getToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknownError
            }
            
            print("📊 HTTP Status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let patientResponse = try decoder.decode(PatientListResponse.self, from: data)
                
                print("📋 Successfully loaded \(patientResponse.patients.count) patients")
                for patient in patientResponse.patients {
                    print("  - \(patient.fullName) (Status: \(patient.status))")
                }
                
                if refresh {
                    self.patients = patientResponse.patients
                } else {
                    self.patients.append(contentsOf: patientResponse.patients)
                }
                
                // Check pagination
                self.hasMore = patientResponse.pagination.page < patientResponse.pagination.totalPages
                self.currentPage += 1
                
                // Update filtered patients  
                self.filteredPatients = self.patients
                
            } else if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            } else {
                throw APIError.serverError(httpResponse.statusCode, "Failed to load patients")
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
    
    
    
    
    // MARK: - Private Methods
    
    private func setupSearchBinding() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self = self else { return }
                if searchText.isEmpty {
                    self.filteredPatients = self.patients
                } else {
                    self.filteredPatients = self.patients.filter { 
                        $0.fullName.localizedCaseInsensitiveContains(searchText) ||
                        $0.email?.localizedCaseInsensitiveContains(searchText) == true ||
                        $0.phone?.localizedCaseInsensitiveContains(searchText) == true
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    
    func clearFilters() {
        searchText = ""
    }
    
    func getPatientById(_ id: String) -> Patient? {
        return patients.first { $0.id == id }
    }
    
    func refreshData() async {
        await loadPatients(refresh: true)
    }
}