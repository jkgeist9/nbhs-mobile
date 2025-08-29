//
//  EvaluationService.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import Foundation
import Combine

class EvaluationService: ObservableObject {
    static let shared = EvaluationService()
    
    @Published var evaluations: [Evaluation] = []
    @Published var filteredEvaluations: [Evaluation] = []
    @Published var selectedEvaluation: Evaluation?
    @Published var isLoading = false
    @Published var error: String?
    
    // Filter and Search State
    @Published var searchText = ""
    @Published var selectedFilter: EvaluationFilterOption = .all
    @Published var selectedStatus: EvaluationStatus?
    @Published var selectedType: EvaluationType?
    @Published var sortOption: EvaluationSortOption = .scheduledDate
    @Published var sortOrder: SortOrder = .descending
    @Published var showingFilters = false
    
    private let apiClient = APIClient.shared
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private let pageSize = 20
    
    private init() {
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Update filtered evaluations when search or filters change
        Publishers.CombineLatest4(
            $evaluations,
            $searchText,
            $selectedFilter,
            $selectedStatus
        )
        .map { evaluations, searchText, filter, status in
            self.filterEvaluations(evaluations, searchText: searchText, filter: filter, status: status)
        }
        .assign(to: &$filteredEvaluations)
    }
    
    // MARK: - Public Methods
    
    @MainActor
    func loadEvaluations(refresh: Bool = false) async {
        if refresh {
            currentPage = 0
            evaluations.removeAll()
        }
        
        isLoading = true
        error = nil
        
        do {
            let queryParams = buildQueryParams()
            let endpoint = APIConfig.Endpoints.evaluations + "?" + queryParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            
            let response: APIResponse<EvaluationListResponse> = try await apiClient.get(
                endpoint: endpoint
            )
            
            if let data = response.data {
                if refresh {
                    self.evaluations = data.evaluations
                } else {
                    self.evaluations.append(contentsOf: data.evaluations)
                }
                currentPage += 1
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
    func loadEvaluation(_ evaluationId: String) async -> Evaluation? {
        do {
            let response: APIResponse<Evaluation> = try await apiClient.get(
                endpoint: APIConfig.Endpoints.evaluation(evaluationId)
            )
            
            if let evaluation = response.data {
                // Update local evaluation if it exists
                if let index = evaluations.firstIndex(where: { $0.id == evaluationId }) {
                    evaluations[index] = evaluation
                }
                return evaluation
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
    func createEvaluation(_ request: CreateEvaluationRequest) async -> Evaluation? {
        do {
            let response: APIResponse<Evaluation> = try await apiClient.post(
                endpoint: APIConfig.Endpoints.evaluations,
                body: request
            )
            
            if let evaluation = response.data {
                // Add to local data
                evaluations.insert(evaluation, at: 0)
                return evaluation
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
    func updateEvaluation(_ evaluationId: String, request: UpdateEvaluationRequest) async -> Bool {
        do {
            let response: APIResponse<Evaluation> = try await apiClient.put(
                endpoint: APIConfig.Endpoints.evaluation(evaluationId),
                body: request
            )
            
            if let updatedEvaluation = response.data {
                // Update local data
                if let index = evaluations.firstIndex(where: { $0.id == evaluationId }) {
                    evaluations[index] = updatedEvaluation
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
    func addDiagnosis(_ evaluationId: String, request: AddDiagnosisRequest) async -> Bool {
        do {
            let response: APIResponse<Diagnosis> = try await apiClient.post(
                endpoint: "/evaluations/\(evaluationId)/diagnoses",
                body: request
            )
            
            if let diagnosis = response.data {
                // Update local evaluation with new diagnosis
                if let index = evaluations.firstIndex(where: { $0.id == evaluationId }) {
                    let updatedEvaluation = evaluations[index]
                    var diagnoses = updatedEvaluation.diagnoses
                    diagnoses.append(diagnosis)
                    
                    // Create new evaluation instance (struct immutability)
                    evaluations[index] = Evaluation(
                        id: updatedEvaluation.id,
                        patientId: updatedEvaluation.patientId,
                        patientName: updatedEvaluation.patientName,
                        patientAge: updatedEvaluation.patientAge,
                        providerId: updatedEvaluation.providerId,
                        providerName: updatedEvaluation.providerName,
                        type: updatedEvaluation.type,
                        status: updatedEvaluation.status,
                        scheduledDate: updatedEvaluation.scheduledDate,
                        completedDate: updatedEvaluation.completedDate,
                        referralSource: updatedEvaluation.referralSource,
                        chiefComplaint: updatedEvaluation.chiefComplaint,
                        presentingProblem: updatedEvaluation.presentingProblem,
                        evaluationSummary: updatedEvaluation.evaluationSummary,
                        recommendations: updatedEvaluation.recommendations,
                        diagnoses: diagnoses,
                        testingResults: updatedEvaluation.testingResults,
                        attachments: updatedEvaluation.attachments,
                        followUpRequired: updatedEvaluation.followUpRequired,
                        followUpDate: updatedEvaluation.followUpDate,
                        notes: updatedEvaluation.notes,
                        createdAt: updatedEvaluation.createdAt,
                        updatedAt: Date()
                    )
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
    func addTestResult(_ evaluationId: String, request: AddTestResultRequest) async -> Bool {
        do {
            let response: APIResponse<TestResult> = try await apiClient.post(
                endpoint: "/evaluations/\(evaluationId)/test-results",
                body: request
            )
            
            if let testResult = response.data {
                // Update local evaluation with new test result
                if let index = evaluations.firstIndex(where: { $0.id == evaluationId }) {
                    let updatedEvaluation = evaluations[index]
                    var testingResults = updatedEvaluation.testingResults
                    testingResults.append(testResult)
                    
                    // Create new evaluation instance (struct immutability)
                    evaluations[index] = Evaluation(
                        id: updatedEvaluation.id,
                        patientId: updatedEvaluation.patientId,
                        patientName: updatedEvaluation.patientName,
                        patientAge: updatedEvaluation.patientAge,
                        providerId: updatedEvaluation.providerId,
                        providerName: updatedEvaluation.providerName,
                        type: updatedEvaluation.type,
                        status: updatedEvaluation.status,
                        scheduledDate: updatedEvaluation.scheduledDate,
                        completedDate: updatedEvaluation.completedDate,
                        referralSource: updatedEvaluation.referralSource,
                        chiefComplaint: updatedEvaluation.chiefComplaint,
                        presentingProblem: updatedEvaluation.presentingProblem,
                        evaluationSummary: updatedEvaluation.evaluationSummary,
                        recommendations: updatedEvaluation.recommendations,
                        diagnoses: updatedEvaluation.diagnoses,
                        testingResults: testingResults,
                        attachments: updatedEvaluation.attachments,
                        followUpRequired: updatedEvaluation.followUpRequired,
                        followUpDate: updatedEvaluation.followUpDate,
                        notes: updatedEvaluation.notes,
                        createdAt: updatedEvaluation.createdAt,
                        updatedAt: Date()
                    )
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
    func uploadAttachment(_ evaluationId: String, fileData: Data, filename: String, description: String?) async -> Bool {
        do {
            // This would typically be a multipart form data upload
            // For now, we'll simulate with a JSON payload
            struct UploadRequest: Codable {
                let filename: String
                let description: String
                let fileSize: Int
            }
            
            let request = UploadRequest(
                filename: filename,
                description: description ?? "",
                fileSize: fileData.count
            )
            
            let response: APIResponse<EvaluationAttachment> = try await apiClient.post(
                endpoint: "/evaluations/\(evaluationId)/attachments",
                body: request
            )
            
            if response.success {
                // Reload evaluation to get updated attachments
                _ = await loadEvaluation(evaluationId)
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
    func getEvaluationStatistics() async -> EvaluationStatsResponse? {
        do {
            let response: APIResponse<EvaluationStatsResponse> = try await apiClient.get(
                endpoint: "/evaluations/statistics"
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
        selectedType = nil
        sortOption = .scheduledDate
        sortOrder = .descending
    }
    
    func refreshData() async {
        await loadEvaluations(refresh: true)
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
        
        if let type = selectedType {
            params["type"] = type.rawValue
        }
        
        switch selectedFilter {
        case .all:
            break
        case .scheduled:
            params["status"] = EvaluationStatus.scheduled.rawValue
        case .inProgress:
            params["status"] = EvaluationStatus.inProgress.rawValue
        case .myEvaluations:
            params["assigned_to_me"] = "true"
        case .overdue:
            params["overdue"] = "true"
        case .completed:
            params["status"] = EvaluationStatus.completed.rawValue
        }
        
        return params
    }
    
    private func filterEvaluations(_ evaluations: [Evaluation], searchText: String, filter: EvaluationFilterOption, status: EvaluationStatus?) -> [Evaluation] {
        var filtered = evaluations
        
        // Apply search text filter
        if !searchText.isEmpty {
            filtered = filtered.filter { evaluation in
                evaluation.patientName.localizedCaseInsensitiveContains(searchText) ||
                evaluation.type.displayName.localizedCaseInsensitiveContains(searchText) ||
                evaluation.chiefComplaint.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply filter option
        switch filter {
        case .all:
            break
        case .scheduled:
            filtered = filtered.filter { $0.status == .scheduled }
        case .inProgress:
            filtered = filtered.filter { $0.status == .inProgress }
        case .myEvaluations:
            // Would filter by current provider - for now just return all
            break
        case .overdue:
            filtered = filtered.filter { $0.isOverdue }
        case .completed:
            filtered = filtered.filter { $0.status == .completed }
        }
        
        // Apply status filter
        if let status = status {
            filtered = filtered.filter { $0.status == status }
        }
        
        // Apply sorting
        filtered.sort { evaluation1, evaluation2 in
            let ascending = sortOrder == .ascending
            
            switch sortOption {
            case .scheduledDate:
                let date1 = evaluation1.scheduledDate ?? Date.distantPast
                let date2 = evaluation2.scheduledDate ?? Date.distantPast
                return ascending ? date1 < date2 : date1 > date2
            case .createdAt:
                return ascending ? evaluation1.createdAt < evaluation2.createdAt : evaluation1.createdAt > evaluation2.createdAt
            case .patientName:
                return ascending ? evaluation1.patientName < evaluation2.patientName : evaluation1.patientName > evaluation2.patientName
            case .status:
                return ascending ? evaluation1.status.rawValue < evaluation2.status.rawValue : evaluation1.status.rawValue > evaluation2.status.rawValue
            case .type:
                return ascending ? evaluation1.type.rawValue < evaluation2.type.rawValue : evaluation1.type.rawValue > evaluation2.type.rawValue
            }
        }
        
        return filtered
    }
}