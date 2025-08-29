//
//  InquiryService.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import Foundation
import Combine

class InquiryService: ObservableObject {
    static let shared = InquiryService()
    
    @Published var inquiries: [Inquiry] = []
    @Published var filteredInquiries: [Inquiry] = []
    @Published var selectedInquiry: Inquiry?
    @Published var isLoading = false
    @Published var error: String?
    
    // Filter and Search State
    @Published var searchText = ""
    @Published var selectedFilter: InquiryFilterOption = .all
    @Published var selectedStatus: InquiryStatus?
    @Published var selectedUrgency: InquiryUrgency?
    @Published var sortOption: InquirySortOption = .createdAt
    @Published var sortOrder: SortOrder = .descending
    @Published var showingFilters = false
    
    private let apiClient = APIClient.shared
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    private let pageSize = 20
    
    private init() {
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Update filtered inquiries when search or filters change
        Publishers.CombineLatest4(
            $inquiries,
            $searchText,
            $selectedFilter,
            $selectedStatus
        )
        .map { inquiries, searchText, filter, status in
            self.filterInquiries(inquiries, searchText: searchText, filter: filter, status: status)
        }
        .assign(to: &$filteredInquiries)
    }
    
    // MARK: - Public Methods
    
    @MainActor
    func loadInquiries(refresh: Bool = false) async {
        if refresh {
            currentPage = 1
            inquiries.removeAll()
        }
        
        isLoading = true
        error = nil
        
        do {
            let queryParams = buildQueryParams()
            let endpoint = APIConfig.Endpoints.inquiries + "?" + queryParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            
            print("🌐 Making API request to: \(APIConfig.baseURL + endpoint)")
            print("🔐 Auth token present: \(apiClient.isAuthenticated)")
            
            // Create the request manually to handle the direct API response format
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
                // Try to decode directly as InquiryListResponse
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let inquiryResponse = try decoder.decode(InquiryListResponse.self, from: data)
                
                print("📋 Successfully loaded \(inquiryResponse.inquiries.count) inquiries")
                for inquiry in inquiryResponse.inquiries {
                    print("  - \(inquiry.fullName) (Status: \(inquiry.status.displayName))")
                }
                
                if refresh {
                    self.inquiries = inquiryResponse.inquiries
                } else {
                    self.inquiries.append(contentsOf: inquiryResponse.inquiries)
                }
                currentPage += 1
                
            } else if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            } else {
                throw APIError.serverError(httpResponse.statusCode, "Failed to load inquiries")
            }
            
        } catch {
            print("🚨 Error loading inquiries: \(error)")
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
                print("🚨 API Error: \(apiError.localizedDescription)")
            } else {
                self.error = error.localizedDescription
                print("🚨 Generic Error: \(error.localizedDescription)")
            }
        }
        
        isLoading = false
        print("✅ Finished loading inquiries. Total count: \(inquiries.count)")
    }
    
    @MainActor
    func loadInquiry(_ inquiryId: String) async -> Inquiry? {
        do {
            let response: APIResponse<Inquiry> = try await apiClient.get(
                endpoint: APIConfig.Endpoints.inquiry(inquiryId)
            )
            
            if let inquiry = response.data {
                // Update local inquiry if it exists
                if let index = inquiries.firstIndex(where: { $0.id == inquiryId }) {
                    inquiries[index] = inquiry
                }
                return inquiry
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
    func createInquiry(_ request: CreateInquiryRequest) async -> Inquiry? {
        do {
            let response: APIResponse<Inquiry> = try await apiClient.post(
                endpoint: APIConfig.Endpoints.inquiries,
                body: request
            )
            
            if let inquiry = response.data {
                // Add to local data
                inquiries.insert(inquiry, at: 0)
                return inquiry
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
    func updateInquiry(_ inquiryId: String, request: UpdateInquiryRequest) async -> Bool {
        do {
            let response: APIResponse<Inquiry> = try await apiClient.put(
                endpoint: APIConfig.Endpoints.inquiry(inquiryId),
                body: request
            )
            
            if let updatedInquiry = response.data {
                // Update local data
                if let index = inquiries.firstIndex(where: { $0.id == inquiryId }) {
                    inquiries[index] = updatedInquiry
                }
                return true
            }
            
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
            } else {
                self.error = error.localizedDescription
            }
        }
        
        return false
    }
    
    @MainActor
    func updateInquiryStatus(_ inquiryId: String, status: InquiryStatus) async -> Bool {
        do {
            struct StatusUpdateRequest: Codable {
                let status: String
            }
            
            let request = StatusUpdateRequest(status: status.rawValue)
            let response: APIResponse<Inquiry> = try await apiClient.post(
                endpoint: APIConfig.Endpoints.inquiryStatus(inquiryId),
                body: request
            )
            
            if let updatedInquiry = response.data {
                // Update local data
                if let index = inquiries.firstIndex(where: { $0.id == inquiryId }) {
                    inquiries[index] = updatedInquiry
                }
                return true
            }
            
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
            } else {
                self.error = error.localizedDescription
            }
        }
        
        return false
    }
    
    @MainActor
    func convertInquiry(_ inquiryId: String, request: ConvertInquiryRequest) async -> Bool {
        do {
            struct ConvertResponse: Codable {
                let success: Bool
                let message: String?
            }
            
            let response: APIResponse<ConvertResponse> = try await apiClient.post(
                endpoint: APIConfig.Endpoints.inquiryConvert(inquiryId),
                body: request
            )
            
            if response.success {
                // Reload the inquiry from the server to get updated status
                if let updatedInquiry = await loadInquiry(inquiryId) {
                    if let index = inquiries.firstIndex(where: { $0.id == inquiryId }) {
                        inquiries[index] = updatedInquiry
                    }
                }
                return true
            }
            
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
            } else {
                self.error = error.localizedDescription
            }
        }
        
        return false
    }
    
    @MainActor
    func addContactAttempt(_ inquiryId: String, request: CreateContactAttemptRequest) async -> Bool {
        do {
            let response: APIResponse<ContactAttempt> = try await apiClient.post(
                endpoint: APIConfig.Endpoints.inquiryContactAttempts(inquiryId),
                body: request
            )
            
            if response.data != nil {
                // Reload the inquiry from the server to get updated contact attempts
                if let updatedInquiry = await loadInquiry(inquiryId) {
                    if let index = inquiries.firstIndex(where: { $0.id == inquiryId }) {
                        inquiries[index] = updatedInquiry
                    }
                }
                return true
            }
            
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
            } else {
                self.error = error.localizedDescription
            }
        }
        
        return false
    }
    
    @MainActor
    func getInquiryStatistics() async -> InquiryStatsResponse? {
        do {
            let response: APIResponse<InquiryStatsResponse> = try await apiClient.get(
                endpoint: "/inquiries/statistics"
            )
            return response.data
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    func clearFilters() {
        searchText = ""
        selectedFilter = .all
        selectedStatus = nil
        selectedUrgency = nil
        sortOption = .createdAt
        sortOrder = .descending
    }
    
    func refreshData() async {
        await loadInquiries(refresh: true)
    }
    
    // MARK: - Private Methods
    
    private func buildQueryParams() -> [String: String] {
        var params: [String: String] = [
            "page": String(currentPage),
            "limit": String(pageSize),
            "sort": sortOption.rawValue,
            "order": sortOrder.rawValue
        ]
        
        if !searchText.isEmpty {
            params["search"] = searchText
        }
        
        if let status = selectedStatus {
            params["status"] = status.rawValue
        }
        
        if let urgency = selectedUrgency {
            params["urgency"] = urgency.rawValue
        }
        
        switch selectedFilter {
        case .all:
            break
        case .new:
            params["status"] = InquiryStatus.new.rawValue
        case .assigned:
            params["assigned_to_me"] = "true"
        case .overdue:
            params["overdue"] = "true"
        case .high_priority:
            params["urgency"] = "high,urgent"
        }
        
        return params
    }
    
    private func filterInquiries(_ inquiries: [Inquiry], searchText: String, filter: InquiryFilterOption, status: InquiryStatus?) -> [Inquiry] {
        var filtered = inquiries
        
        // Apply search text filter
        if !searchText.isEmpty {
            filtered = filtered.filter { inquiry in
                inquiry.fullName.localizedCaseInsensitiveContains(searchText) ||
                inquiry.email?.localizedCaseInsensitiveContains(searchText) == true ||
                inquiry.phone?.localizedCaseInsensitiveContains(searchText) == true ||
                inquiry.reasonForInquiry.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply filter option
        switch filter {
        case .all:
            break
        case .new:
            filtered = filtered.filter { $0.status == .new }
        case .assigned:
            filtered = filtered.filter { $0.assignedProviderId != nil }
        case .overdue:
            filtered = filtered.filter { $0.isOverdue }
        case .high_priority:
            filtered = filtered.filter { $0.urgency == .high || $0.urgency == .urgent }
        }
        
        // Apply status filter
        if let status = status {
            filtered = filtered.filter { $0.status == status }
        }
        
        // Apply sorting
        filtered.sort { inquiry1, inquiry2 in
            let ascending = sortOrder == .ascending
            
            switch sortOption {
            case .createdAt:
                return ascending ? inquiry1.createdAt < inquiry2.createdAt : inquiry1.createdAt > inquiry2.createdAt
            case .updatedAt:
                return ascending ? inquiry1.updatedAt < inquiry2.updatedAt : inquiry1.updatedAt > inquiry2.updatedAt
            case .urgency:
                return ascending ? inquiry1.urgency.rawValue < inquiry2.urgency.rawValue : inquiry1.urgency.rawValue > inquiry2.urgency.rawValue
            case .status:
                return ascending ? inquiry1.status.rawValue < inquiry2.status.rawValue : inquiry1.status.rawValue > inquiry2.status.rawValue
            case .followUpDate:
                let date1 = inquiry1.followUpDate ?? Date.distantPast
                let date2 = inquiry2.followUpDate ?? Date.distantPast
                return ascending ? date1 < date2 : date1 > date2
            }
        }
        
        return filtered
    }
}