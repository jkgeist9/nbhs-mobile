//
//  Appointment.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import Foundation

// MARK: - Appointment Models

struct Appointment: Codable, Identifiable {
    let id: String
    let providerId: String
    let patientId: String
    let patientName: String
    let patientEmail: String?
    let patientPhone: String?
    let appointmentType: AppointmentType
    let status: AppointmentStatus
    let scheduledStart: Date
    let scheduledEnd: Date
    let actualStart: Date?
    let actualEnd: Date?
    let notes: String?
    let location: String?
    let isVirtual: Bool
    let meetingLink: String?
    let cancelReason: String?
    let createdAt: Date
    let updatedAt: Date
    
    // MARK: - Computed Properties
    
    var duration: TimeInterval {
        scheduledEnd.timeIntervalSince(scheduledStart)
    }
    
    var durationText: String {
        let minutes = Int(duration / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return remainingMinutes > 0 ? "\(hours)h \(remainingMinutes)m" : "\(hours)h"
        }
    }
    
    var isToday: Bool {
        Calendar.current.isDate(scheduledStart, inSameDayAs: Date())
    }
    
    var isUpcoming: Bool {
        scheduledStart > Date()
    }
    
    var isPast: Bool {
        scheduledEnd < Date()
    }
    
    var isInProgress: Bool {
        let now = Date()
        return scheduledStart <= now && now <= scheduledEnd
    }
    
    var timeUntilStart: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: scheduledStart, relativeTo: Date())
    }
}

enum AppointmentType: String, Codable, CaseIterable {
    case initialConsultation = "initial_consultation"
    case followUp = "follow_up"
    case evaluation = "evaluation"
    case therapy = "therapy"
    case groupSession = "group_session"
    case familySession = "family_session"
    case telehealth = "telehealth"
    case emergency = "emergency"
    
    var displayName: String {
        switch self {
        case .initialConsultation: return "Initial Consultation"
        case .followUp: return "Follow-up"
        case .evaluation: return "Evaluation"
        case .therapy: return "Therapy Session"
        case .groupSession: return "Group Session"
        case .familySession: return "Family Session"
        case .telehealth: return "Telehealth"
        case .emergency: return "Emergency"
        }
    }
    
    var icon: String {
        switch self {
        case .initialConsultation: return "person.badge.plus"
        case .followUp: return "arrow.clockwise"
        case .evaluation: return "doc.text"
        case .therapy: return "brain.head.profile"
        case .groupSession: return "person.3"
        case .familySession: return "house"
        case .telehealth: return "video"
        case .emergency: return "exclamationmark.triangle"
        }
    }
    
    var color: String {
        switch self {
        case .initialConsultation: return "teal500"
        case .followUp: return "success"
        case .evaluation: return "info"
        case .therapy: return "textPrimary"
        case .groupSession: return "warning"
        case .familySession: return "textSecondary"
        case .telehealth: return "teal600"
        case .emergency: return "error"
        }
    }
}

enum AppointmentStatus: String, Codable, CaseIterable {
    case scheduled = "scheduled"
    case confirmed = "confirmed"
    case checkedIn = "checked_in"
    case inProgress = "in_progress"
    case completed = "completed"
    case noShow = "no_show"
    case cancelled = "cancelled"
    case rescheduled = "rescheduled"
    
    var displayName: String {
        switch self {
        case .scheduled: return "Scheduled"
        case .confirmed: return "Confirmed"
        case .checkedIn: return "Checked In"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .noShow: return "No Show"
        case .cancelled: return "Cancelled"
        case .rescheduled: return "Rescheduled"
        }
    }
    
    var color: String {
        switch self {
        case .scheduled: return "textSecondary"
        case .confirmed: return "success"
        case .checkedIn: return "info"
        case .inProgress: return "warning"
        case .completed: return "success"
        case .noShow: return "error"
        case .cancelled: return "error"
        case .rescheduled: return "warning"
        }
    }
    
    var icon: String {
        switch self {
        case .scheduled: return "calendar"
        case .confirmed: return "checkmark.circle"
        case .checkedIn: return "person.crop.circle.badge.checkmark"
        case .inProgress: return "clock"
        case .completed: return "checkmark.circle.fill"
        case .noShow: return "person.crop.circle.badge.xmark"
        case .cancelled: return "xmark.circle"
        case .rescheduled: return "arrow.clockwise.circle"
        }
    }
}

// MARK: - Appointment Card Component

struct AppointmentCard: View {
    let appointment: Appointment
    
    var body: some View {
        HStack(spacing: 12) {
            // Time
            VStack(alignment: .leading, spacing: 2) {
                Text(appointment.scheduledStart, format: .dateTime.hour().minute())
                    .bodyStyle(.medium)
                
                Text(appointment.durationText)
                    .captionStyle(.small, color: .textTertiary)
            }
            .frame(width: 60, alignment: .leading)
            
            // Divider
            Rectangle()
                .fill(getStatusColor(appointment.status))
                .frame(width: 3)
                .cornerRadius(1.5)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(appointment.patientName)
                        .bodyStyle(.medium)
                    
                    Spacer()
                    
                    // Status Badge
                    Text(appointment.status.displayName)
                        .captionStyle(.small, color: getStatusColor(appointment.status))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(getStatusColor(appointment.status).opacity(0.1))
                        .cornerRadius(4)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: appointment.appointmentType.icon)
                        .font(.caption)
                        .foregroundColor(getTypeColor(appointment.appointmentType))
                    
                    Text(appointment.appointmentType.displayName)
                        .captionStyle(.regular, color: .textSecondary)
                    
                    if appointment.isVirtual {
                        Image(systemName: "video")
                            .font(.caption)
                            .foregroundColor(.info)
                    }
                }
                
                if let location = appointment.location {
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                        
                        Text(location)
                            .captionStyle(.small, color: .textTertiary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.surface)
        .cornerRadius(8)
        .shadow(color: .shadowLight, radius: 2, x: 0, y: 1)
    }
    
    private func getStatusColor(_ status: AppointmentStatus) -> Color {
        switch status {
        case .scheduled: return .textSecondary
        case .confirmed: return .success
        case .checkedIn: return .info
        case .inProgress: return .warning
        case .completed: return .success
        case .noShow: return .error
        case .cancelled: return .error
        case .rescheduled: return .warning
        }
    }
    
    private func getTypeColor(_ type: AppointmentType) -> Color {
        switch type {
        case .initialConsultation: return .teal500
        case .followUp: return .success
        case .evaluation: return .info
        case .therapy: return .textPrimary
        case .groupSession: return .warning
        case .familySession: return .textSecondary
        case .telehealth: return .teal600
        case .emergency: return .error
        }
    }
}

// MARK: - Create Appointment Request

struct CreateAppointmentRequest: Codable {
    let patientId: String
    let providerId: String
    let appointmentType: AppointmentType
    let scheduledStart: Date
    let scheduledEnd: Date
    let notes: String?
    let location: String?
    let isVirtual: Bool
}

struct UpdateAppointmentRequest: Codable {
    let appointmentType: AppointmentType?
    let scheduledStart: Date?
    let scheduledEnd: Date?
    let notes: String?
    let location: String?
    let isVirtual: Bool?
    let status: AppointmentStatus?
}

// MARK: - Appointment Response Types

struct AppointmentListResponse: Codable {
    let appointments: [Appointment]
    let totalCount: Int
    let hasMore: Bool
}

struct AppointmentStatsResponse: Codable {
    let totalAppointments: Int
    let completedAppointments: Int
    let cancelledAppointments: Int
    let noShowAppointments: Int
    let averageDuration: Double
    let satisfactionRating: Double?
}