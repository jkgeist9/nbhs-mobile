//
//  DashboardService.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import Foundation
import Combine

class DashboardService: ObservableObject {
    static let shared = DashboardService()
    
    @Published var dashboardData: DashboardData?
    @Published var isLoading = false
    @Published var error: String?
    
    private let apiClient = APIClient.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Public Methods
    
    @MainActor
    func loadDashboardData() async {
        isLoading = true
        error = nil
        
        do {
            let response: APIResponse<DashboardData> = try await apiClient.get(
                endpoint: APIConfig.Endpoints.dashboard
            )
            
            if let data = response.data {
                self.dashboardData = data
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
    func refreshData() async {
        await loadDashboardData()
    }
    
    // MARK: - Task Management
    
    @MainActor
    func markTaskComplete(_ taskId: String) async -> Bool {
        do {
            let request = ["taskId": taskId, "isCompleted": true] as [String: Any]
            let response: APIResponse<TaskItem> = try await apiClient.post(
                endpoint: "/tasks/\(taskId)/complete",
                body: request
            )
            
            if response.success {
                // Update local data
                updateLocalTask(taskId, isCompleted: true)
                return true
            }
            return false
            
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }
    
    @MainActor
    func markAlertRead(_ alertId: String) async -> Bool {
        do {
            let response: APIResponse<AlertItem> = try await apiClient.post(
                endpoint: "/alerts/\(alertId)/read",
                body: ["isRead": true]
            )
            
            if response.success {
                // Update local data
                updateLocalAlert(alertId, isRead: true)
                return true
            }
            return false
            
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Statistics
    
    @MainActor
    func getStatisticsForPeriod(_ period: StatisticsPeriod) async -> DashboardStatistics? {
        do {
            let response: APIResponse<DashboardStatistics> = try await apiClient.get(
                endpoint: "/dashboard/statistics?period=\(period.rawValue)"
            )
            return response.data
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func updateLocalTask(_ taskId: String, isCompleted: Bool) {
        guard var data = dashboardData else { return }
        
        if let index = data.pendingTasks.firstIndex(where: { $0.id == taskId }) {
            var updatedTask = data.pendingTasks[index]
            updatedTask = TaskItem(
                id: updatedTask.id,
                title: updatedTask.title,
                description: updatedTask.description,
                priority: updatedTask.priority,
                dueDate: updatedTask.dueDate,
                patientId: updatedTask.patientId,
                patientName: updatedTask.patientName,
                isCompleted: isCompleted,
                category: updatedTask.category
            )
            data.pendingTasks[index] = updatedTask
            self.dashboardData = data
        }
    }
    
    private func updateLocalAlert(_ alertId: String, isRead: Bool) {
        guard var data = dashboardData else { return }
        
        if let index = data.alerts.firstIndex(where: { $0.id == alertId }) {
            var updatedAlert = data.alerts[index]
            updatedAlert = AlertItem(
                id: updatedAlert.id,
                type: updatedAlert.type,
                title: updatedAlert.title,
                message: updatedAlert.message,
                severity: updatedAlert.severity,
                timestamp: updatedAlert.timestamp,
                isRead: isRead,
                actionRequired: updatedAlert.actionRequired,
                patientId: updatedAlert.patientId,
                patientName: updatedAlert.patientName
            )
            data.alerts[index] = updatedAlert
            self.dashboardData = data
        }
    }
}

// MARK: - Supporting Types

enum StatisticsPeriod: String, CaseIterable {
    case today = "today"
    case week = "week"
    case month = "month"
    case quarter = "quarter"
    case year = "year"
    
    var displayName: String {
        switch self {
        case .today: return "Today"
        case .week: return "This Week"
        case .month: return "This Month"
        case .quarter: return "This Quarter"
        case .year: return "This Year"
        }
    }
}