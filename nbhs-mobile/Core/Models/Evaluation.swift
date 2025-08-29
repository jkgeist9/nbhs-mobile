//
//  Evaluation.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Evaluation Models

struct Evaluation: Codable, Identifiable {
    let id: String
    let patientId: String
    let patientName: String
    let patientAge: Int?
    let providerId: String
    let providerName: String
    let type: EvaluationType
    let status: EvaluationStatus
    let scheduledDate: Date?
    let completedDate: Date?
    let referralSource: String?
    let chiefComplaint: String
    let presentingProblem: String
    let evaluationSummary: String?
    let recommendations: [String]
    let diagnoses: [Diagnosis]
    let testingResults: [TestResult]
    let attachments: [EvaluationAttachment]
    let followUpRequired: Bool
    let followUpDate: Date?
    let notes: String?
    let createdAt: Date
    let updatedAt: Date
    
    // MARK: - Computed Properties
    
    var isCompleted: Bool {
        status == .completed
    }
    
    var isOverdue: Bool {
        guard let scheduledDate = scheduledDate else { return false }
        return scheduledDate < Date() && status != .completed && status != .cancelled
    }
    
    var daysSinceCreated: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: createdAt, to: Date())
        return components.day ?? 0
    }
    
    var hasAttachments: Bool {
        !attachments.isEmpty
    }
    
    var hasDiagnoses: Bool {
        !diagnoses.isEmpty
    }
    
    var hasTestResults: Bool {
        !testingResults.isEmpty
    }
    
    var progressPercentage: Double {
        switch status {
        case .scheduled: return 0.2
        case .inProgress: return 0.6
        case .reviewPending: return 0.8
        case .completed: return 1.0
        case .cancelled: return 0.0
        }
    }
}

enum EvaluationType: String, Codable, CaseIterable {
    case psychological = "psychological"
    case neuropsychological = "neuropsychological"
    case psychiatric = "psychiatric"
    case behavioral = "behavioral"
    case developmental = "developmental"
    case educational = "educational"
    case vocational = "vocational"
    case forensic = "forensic"
    
    var displayName: String {
        switch self {
        case .psychological: return "Psychological"
        case .neuropsychological: return "Neuropsychological"
        case .psychiatric: return "Psychiatric"
        case .behavioral: return "Behavioral"
        case .developmental: return "Developmental"
        case .educational: return "Educational"
        case .vocational: return "Vocational"
        case .forensic: return "Forensic"
        }
    }
    
    var icon: String {
        switch self {
        case .psychological: return "brain.head.profile"
        case .neuropsychological: return "brain"
        case .psychiatric: return "stethoscope"
        case .behavioral: return "person.2"
        case .developmental: return "figure.child"
        case .educational: return "book"
        case .vocational: return "briefcase"
        case .forensic: return "doc.text.magnifyingglass"
        }
    }
    
    var color: String {
        switch self {
        case .psychological: return "teal500"
        case .neuropsychological: return "info"
        case .psychiatric: return "textPrimary"
        case .behavioral: return "warning"
        case .developmental: return "success"
        case .educational: return "textSecondary"
        case .vocational: return "teal600"
        case .forensic: return "error"
        }
    }
}

enum EvaluationStatus: String, Codable, CaseIterable {
    case scheduled = "scheduled"
    case inProgress = "in_progress"
    case reviewPending = "review_pending"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .scheduled: return "Scheduled"
        case .inProgress: return "In Progress"
        case .reviewPending: return "Review Pending"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var icon: String {
        switch self {
        case .scheduled: return "calendar"
        case .inProgress: return "clock"
        case .reviewPending: return "eye"
        case .completed: return "checkmark.circle"
        case .cancelled: return "xmark.circle"
        }
    }
    
    var color: String {
        switch self {
        case .scheduled: return "info"
        case .inProgress: return "warning"
        case .reviewPending: return "textSecondary"
        case .completed: return "success"
        case .cancelled: return "error"
        }
    }
}

// MARK: - Supporting Models

struct Diagnosis: Codable, Identifiable {
    let id: String
    let code: String
    let description: String
    let type: DiagnosisType
    let severity: DiagnosisSeverity?
    let onset: String?
    let notes: String?
}

enum DiagnosisType: String, Codable, CaseIterable {
    case primary = "primary"
    case secondary = "secondary"
    case differential = "differential"
    case ruleOut = "rule_out"
    
    var displayName: String {
        switch self {
        case .primary: return "Primary"
        case .secondary: return "Secondary"
        case .differential: return "Differential"
        case .ruleOut: return "Rule Out"
        }
    }
}

enum DiagnosisSeverity: String, Codable, CaseIterable {
    case mild = "mild"
    case moderate = "moderate"
    case severe = "severe"
    
    var displayName: String {
        switch self {
        case .mild: return "Mild"
        case .moderate: return "Moderate"
        case .severe: return "Severe"
        }
    }
    
    var color: String {
        switch self {
        case .mild: return "success"
        case .moderate: return "warning"
        case .severe: return "error"
        }
    }
}

struct TestResult: Codable, Identifiable {
    let id: String
    let testName: String
    let testType: TestType
    let score: String?
    let percentile: Int?
    let standardScore: Int?
    let interpretation: String
    let administeredDate: Date
    let notes: String?
}

enum TestType: String, Codable, CaseIterable {
    case cognitive = "cognitive"
    case personality = "personality"
    case achievement = "achievement"
    case behavioral = "behavioral"
    case neuropsychological = "neuropsychological"
    case developmental = "developmental"
    
    var displayName: String {
        switch self {
        case .cognitive: return "Cognitive"
        case .personality: return "Personality"
        case .achievement: return "Achievement"
        case .behavioral: return "Behavioral"
        case .neuropsychological: return "Neuropsychological"
        case .developmental: return "Developmental"
        }
    }
}

struct EvaluationAttachment: Codable, Identifiable {
    let id: String
    let filename: String
    let fileType: String
    let fileSize: Int
    let uploadedAt: Date
    let uploadedBy: String
    let description: String?
    let isTestReport: Bool
}

// MARK: - Request/Response Types

struct CreateEvaluationRequest: Codable {
    let patientId: String
    let type: EvaluationType
    let scheduledDate: Date?
    let referralSource: String?
    let chiefComplaint: String
    let presentingProblem: String
    let notes: String?
}

struct UpdateEvaluationRequest: Codable {
    let status: EvaluationStatus?
    let scheduledDate: Date?
    let completedDate: Date?
    let evaluationSummary: String?
    let recommendations: [String]?
    let followUpRequired: Bool?
    let followUpDate: Date?
    let notes: String?
}

struct AddDiagnosisRequest: Codable {
    let code: String
    let description: String
    let type: DiagnosisType
    let severity: DiagnosisSeverity?
    let onset: String?
    let notes: String?
}

struct AddTestResultRequest: Codable {
    let testName: String
    let testType: TestType
    let score: String?
    let percentile: Int?
    let standardScore: Int?
    let interpretation: String
    let administeredDate: Date
    let notes: String?
}

struct EvaluationListResponse: Codable {
    let evaluations: [Evaluation]
    let totalCount: Int
    let hasMore: Bool
}

struct EvaluationStatsResponse: Codable {
    let totalEvaluations: Int
    let scheduledEvaluations: Int
    let inProgressEvaluations: Int
    let completedEvaluations: Int
    let averageCompletionDays: Double
    let evaluationsByType: [String: Int]
}

// MARK: - Supporting Types for Filtering

enum EvaluationFilterOption: String, CaseIterable {
    case all = "all"
    case scheduled = "scheduled"
    case inProgress = "in_progress"
    case myEvaluations = "my_evaluations"
    case overdue = "overdue"
    case completed = "completed"
    
    var displayName: String {
        switch self {
        case .all: return "All Evaluations"
        case .scheduled: return "Scheduled"
        case .inProgress: return "In Progress"
        case .myEvaluations: return "My Evaluations"
        case .overdue: return "Overdue"
        case .completed: return "Completed"
        }
    }
}

enum EvaluationSortOption: String, CaseIterable {
    case scheduledDate = "scheduledDate"
    case createdAt = "createdAt"
    case patientName = "patientName"
    case status = "status"
    case type = "type"
    
    var displayName: String {
        switch self {
        case .scheduledDate: return "Scheduled Date"
        case .createdAt: return "Created Date"
        case .patientName: return "Patient Name"
        case .status: return "Status"
        case .type: return "Type"
        }
    }
}

// MARK: - Evaluation Card Component

struct EvaluationCard: View {
    let evaluation: Evaluation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(evaluation.patientName)
                        .bodyStyle(.medium)
                    
                    Text(evaluation.type.displayName)
                        .captionStyle(.regular, color: getTypeColor(evaluation.type))
                }
                
                Spacer()
                
                // Status Badge
                Text(evaluation.status.displayName)
                    .captionStyle(.small, color: getStatusColor(evaluation.status))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(getStatusColor(evaluation.status).opacity(0.1))
                    .cornerRadius(4)
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progress")
                        .captionStyle(.small, color: .textSecondary)
                    
                    Spacer()
                    
                    Text("\(Int(evaluation.progressPercentage * 100))%")
                        .captionStyle(.small, color: .textSecondary)
                }
                
                ProgressView(value: evaluation.progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: getStatusColor(evaluation.status)))
                    .scaleEffect(x: 1, y: 0.8)
            }
            
            // Details
            HStack(spacing: 16) {
                if let scheduledDate = evaluation.scheduledDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                        
                        Text(scheduledDate.formatted(.dateTime.month().day()))
                            .captionStyle(.regular, color: .textSecondary)
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "person")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                    
                    Text(evaluation.providerName)
                        .captionStyle(.regular, color: .textSecondary)
                }
                
                if evaluation.hasAttachments {
                    HStack(spacing: 4) {
                        Image(systemName: "paperclip")
                            .font(.caption)
                            .foregroundColor(.info)
                        
                        Text("\(evaluation.attachments.count)")
                            .captionStyle(.small, color: .info)
                    }
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color.surface)
        .cornerRadius(12)
        .shadow(color: .shadowLight, radius: 2, x: 0, y: 1)
    }
    
    private func getStatusColor(_ status: EvaluationStatus) -> Color {
        switch status {
        case .scheduled: return .info
        case .inProgress: return .warning
        case .reviewPending: return .textSecondary
        case .completed: return .success
        case .cancelled: return .error
        }
    }
    
    private func getTypeColor(_ type: EvaluationType) -> Color {
        switch type {
        case .psychological: return .teal500
        case .neuropsychological: return .info
        case .psychiatric: return .textPrimary
        case .behavioral: return .warning
        case .developmental: return .success
        case .educational: return .textSecondary
        case .vocational: return .teal600
        case .forensic: return .error
        }
    }
}