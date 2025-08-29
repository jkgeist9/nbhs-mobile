//
//  Dashboard.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import Foundation

// MARK: - Dashboard Data Models

struct DashboardData: Codable {
    let statistics: DashboardStatistics
    let recentActivity: [ActivityItem]
    let upcomingAppointments: [Appointment]
    let pendingTasks: [TaskItem]
    let alerts: [AlertItem]
}

struct DashboardStatistics: Codable {
    let todayAppointments: Int
    let weekAppointments: Int
    let monthAppointments: Int
    let activePatients: Int
    let pendingInquiries: Int
    let completedEvaluations: Int
    let revenue: DashboardRevenue
    let patientSatisfaction: Double
}

struct DashboardRevenue: Codable {
    let today: Double
    let week: Double
    let month: Double
    let year: Double
}

struct ActivityItem: Codable, Identifiable {
    let id: String
    let type: ActivityType
    let title: String
    let description: String
    let timestamp: Date
    let patientId: String?
    let patientName: String?
}

enum ActivityType: String, Codable, CaseIterable {
    case appointment = "appointment"
    case evaluation = "evaluation"
    case inquiry = "inquiry"
    case note = "note"
    case billing = "billing"
    case document = "document"
    
    var displayName: String {
        switch self {
        case .appointment: return "Appointment"
        case .evaluation: return "Evaluation"
        case .inquiry: return "Inquiry"
        case .note: return "Clinical Note"
        case .billing: return "Billing"
        case .document: return "Document"
        }
    }
    
    var icon: String {
        switch self {
        case .appointment: return "calendar"
        case .evaluation: return "doc.text"
        case .inquiry: return "questionmark.circle"
        case .note: return "note.text"
        case .billing: return "creditcard"
        case .document: return "folder"
        }
    }
    
    var color: String {
        switch self {
        case .appointment: return "teal500"
        case .evaluation: return "info"
        case .inquiry: return "warning"
        case .note: return "success"
        case .billing: return "textSecondary"
        case .document: return "textTertiary"
        }
    }
}

struct TaskItem: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let priority: TaskPriority
    let dueDate: Date?
    let patientId: String?
    let patientName: String?
    let isCompleted: Bool
    let category: TaskCategory
}

enum TaskPriority: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .urgent: return "Urgent"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "textTertiary"
        case .medium: return "warning"
        case .high: return "error"
        case .urgent: return "error"
        }
    }
}

enum TaskCategory: String, Codable, CaseIterable {
    case clinical = "clinical"
    case administrative = "administrative"
    case billing = "billing"
    case documentation = "documentation"
    
    var displayName: String {
        switch self {
        case .clinical: return "Clinical"
        case .administrative: return "Administrative"
        case .billing: return "Billing"
        case .documentation: return "Documentation"
        }
    }
}

struct AlertItem: Codable, Identifiable {
    let id: String
    let type: AlertType
    let title: String
    let message: String
    let severity: AlertSeverity
    let timestamp: Date
    let isRead: Bool
    let actionRequired: Bool
    let patientId: String?
    let patientName: String?
}

enum AlertType: String, Codable, CaseIterable {
    case appointment = "appointment"
    case lab = "lab"
    case medication = "medication"
    case billing = "billing"
    case system = "system"
    case compliance = "compliance"
    
    var displayName: String {
        switch self {
        case .appointment: return "Appointment"
        case .lab: return "Lab Result"
        case .medication: return "Medication"
        case .billing: return "Billing"
        case .system: return "System"
        case .compliance: return "Compliance"
        }
    }
    
    var icon: String {
        switch self {
        case .appointment: return "calendar.badge.exclamationmark"
        case .lab: return "flask"
        case .medication: return "pill"
        case .billing: return "creditcard"
        case .system: return "gear"
        case .compliance: return "shield"
        }
    }
}

enum AlertSeverity: String, Codable, CaseIterable {
    case info = "info"
    case warning = "warning"
    case critical = "critical"
    
    var displayName: String {
        switch self {
        case .info: return "Info"
        case .warning: return "Warning"
        case .critical: return "Critical"
        }
    }
    
    var color: String {
        switch self {
        case .info: return "info"
        case .warning: return "warning"
        case .critical: return "error"
        }
    }
}