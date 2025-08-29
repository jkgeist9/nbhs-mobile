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
            struct TaskCompleteRequest: Codable {
                let taskId: String
                let isCompleted: Bool
            }
            
            let request = TaskCompleteRequest(taskId: taskId, isCompleted: true)
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
            struct AlertReadRequest: Codable {
                let isRead: Bool
            }
            
            let request = AlertReadRequest(isRead: true)
            let response: APIResponse<AlertItem> = try await apiClient.post(
                endpoint: "/alerts/\(alertId)/read",
                body: request
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
        guard let data = dashboardData else { return }
        
        if let index = data.pendingTasks.firstIndex(where: { $0.id == taskId }) {
            let existingTask = data.pendingTasks[index]
            let updatedTask = TaskItem(
                id: existingTask.id,
                title: existingTask.title,
                description: existingTask.description,
                priority: existingTask.priority,
                dueDate: existingTask.dueDate,
                patientId: existingTask.patientId,
                patientName: existingTask.patientName,
                isCompleted: isCompleted,
                category: existingTask.category
            )
            
            var updatedTasks = data.pendingTasks
            updatedTasks[index] = updatedTask
            
            let updatedData = DashboardData(
                statistics: data.statistics,
                recentActivity: data.recentActivity,
                upcomingAppointments: data.upcomingAppointments,
                pendingTasks: updatedTasks,
                alerts: data.alerts
            )
            
            self.dashboardData = updatedData
        }
    }
    
    private func updateLocalAlert(_ alertId: String, isRead: Bool) {
        guard let data = dashboardData else { return }
        
        if let index = data.alerts.firstIndex(where: { $0.id == alertId }) {
            let existingAlert = data.alerts[index]
            let updatedAlert = AlertItem(
                id: existingAlert.id,
                type: existingAlert.type,
                title: existingAlert.title,
                message: existingAlert.message,
                severity: existingAlert.severity,
                timestamp: existingAlert.timestamp,
                isRead: isRead,
                actionRequired: existingAlert.actionRequired,
                patientId: existingAlert.patientId,
                patientName: existingAlert.patientName
            )
            
            var updatedAlerts = data.alerts
            updatedAlerts[index] = updatedAlert
            
            let updatedData = DashboardData(
                statistics: data.statistics,
                recentActivity: data.recentActivity,
                upcomingAppointments: data.upcomingAppointments,
                pendingTasks: data.pendingTasks,
                alerts: updatedAlerts
            )
            
            self.dashboardData = updatedData
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