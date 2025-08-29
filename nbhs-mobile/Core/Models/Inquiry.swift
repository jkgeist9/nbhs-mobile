//
//  Inquiry.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Inquiry Models

struct Inquiry: Codable, Identifiable {
    let id: String
    let publicId: String?
    let createdAt: Date
    let updatedAt: Date
    let inquiryFor: String
    let patientId: String
    let guardianId: String?
    let referralSource: String
    let referralDetails: String?
    let urgencyLevel: String
    let preferredContact: String
    let bestTimeToCall: String?
    let statusRaw: String
    
    private enum CodingKeys: String, CodingKey {
        case id, publicId, createdAt, updatedAt, inquiryFor, patientId, guardianId
        case referralSource, referralDetails, urgencyLevel, preferredContact
        case bestTimeToCall, priority, reviewedAt, reviewedById, reviewNotes
        case reviewDecision, assignedToId, assignedAt, patient, guardian, contactAttempts
        case statusRaw = "status"
    }
    let priority: String
    let reviewedAt: Date?
    let reviewedById: String?
    let reviewNotes: String?
    let reviewDecision: String?
    let assignedToId: String?
    let assignedAt: Date?
    let patient: InquiryPatient?
    let guardian: InquiryGuardian?
    let contactAttempts: ContactAttemptsData?
    
    // Computed properties to match the UI expectations
    var firstName: String { patient?.firstName ?? "Unknown" }
    var lastName: String { patient?.lastName ?? "Unknown" }
    var email: String? { patient?.email }
    var phone: String? { patient?.phone }
    var dateOfBirth: Date? { patient?.dateOfBirth }
    var guardianName: String? { 
        guard let guardian = guardian else { return nil }
        return guardian.firstName
    }
    var guardianEmail: String? { guardian?.email }
    var guardianPhone: String? { guardian?.phone }
    var reasonForInquiry: String { referralDetails ?? "No reason provided" }
    var preferredContactMethod: ContactMethod { 
        switch preferredContact.uppercased() {
        case "PHONE": return .phone
        case "EMAIL": return .email
        case "TEXT", "SMS": return .text
        case "ANY": return .any
        default: return .phone
        }
    }
    var urgency: InquiryUrgency { 
        switch urgencyLevel.uppercased() {
        case "LOW": return .low
        case "MEDIUM", "ROUTINE": return .medium
        case "HIGH": return .high
        case "URGENT": return .urgent
        default: return .medium
        }
    }
    var status: InquiryStatus { 
        switch statusRaw.uppercased() {
        case "NEW": return .new
        case "IN_PROGRESS", "INPROGRESS": return .inProgress
        case "AWAITING_RESPONSE", "AWAITINGRESPONSE": return .awaitingResponse
        case "SCHEDULED": return .scheduled
        case "COMPLETED": return .completed
        case "CONVERTED": return .converted
        case "CLOSED": return .closed
        default: return .new
        }
    }
    var assignedProviderId: String? { assignedToId }
    var assignedProviderName: String? { nil } // Would need to be fetched from backend
    var source: InquirySource { 
        switch referralSource.uppercased() {
        case "WEBSITE": return .website
        case "PHONE": return .phone
        case "EMAIL": return .email
        case "REFERRAL": return .referral
        case "WALK_IN", "WALKIN": return .walkIn
        case "PSYCHIATRIST": return .referral
        default: return .phone
        }
    }
    var notes: String? { reviewNotes }
    var followUpDate: Date? { nil } // Would need to be added to backend model
    
    // Additional computed properties for UI compatibility
    var fullName: String { 
        let first = firstName.isEmpty ? "Unknown" : firstName
        let last = lastName.isEmpty ? "Unknown" : lastName
        return "\(first) \(last)"
    }
    
    var initials: String {
        let firstInitial = String(firstName.prefix(1))
        let lastInitial = String(lastName.prefix(1))
        return "\(firstInitial)\(lastInitial)".uppercased()
    }
    
    var age: Int? {
        guard let dob = dateOfBirth else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: dob, to: Date())
        return components.year
    }
    
    var daysSinceCreated: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: createdAt, to: Date())
        return components.day ?? 0
    }
    
    var isOverdue: Bool { 
        guard let followUp = followUpDate else { return false }
        return followUp < Date() 
    }
}

struct InquiryPatient: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String?
    let phone: String?
    let patientDetails: InquiryPatientDetails?
    
    var dateOfBirth: Date? { patientDetails?.dateOfBirth }
}

struct InquiryPatientDetails: Codable {
    let dateOfBirth: Date?
}

struct InquiryGuardian: Codable {
    let id: String
    let firstName: String
    let lastName: String?
    let email: String?
    let phone: String?
    
    // MARK: - Computed Properties
    
    var fullName: String {
        let last = lastName ?? ""
        return "\(firstName) \(last)".trimmingCharacters(in: .whitespaces)
    }
    
    var initials: String {
        let firstInitial = String(firstName.prefix(1))
        let lastInitial = lastName.map { String($0.prefix(1)) } ?? ""
        return "\(firstInitial)\(lastInitial)".uppercased()
    }
    
}

enum InquiryStatus: String, Codable, CaseIterable {
    case new = "new"
    case inProgress = "in_progress"
    case awaitingResponse = "awaiting_response"
    case scheduled = "scheduled"
    case completed = "completed"
    case converted = "converted"
    case closed = "closed"
    
    var displayName: String {
        switch self {
        case .new: return "New"
        case .inProgress: return "In Progress"
        case .awaitingResponse: return "Awaiting Response"
        case .scheduled: return "Scheduled"
        case .completed: return "Completed"
        case .converted: return "Converted"
        case .closed: return "Closed"
        }
    }
    
    var icon: String {
        switch self {
        case .new: return "envelope.badge"
        case .inProgress: return "clock"
        case .awaitingResponse: return "ellipsis.message"
        case .scheduled: return "calendar"
        case .completed: return "checkmark.circle"
        case .converted: return "person.badge.plus"
        case .closed: return "xmark.circle"
        }
    }
    
    var color: String {
        switch self {
        case .new: return "info"
        case .inProgress: return "warning"
        case .awaitingResponse: return "textSecondary"
        case .scheduled: return "success"
        case .completed: return "success"
        case .converted: return "teal500"
        case .closed: return "error"
        }
    }
}

enum InquiryUrgency: String, Codable, CaseIterable {
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
    
    var icon: String {
        switch self {
        case .low: return "circle"
        case .medium: return "circle.fill"
        case .high: return "exclamationmark.circle"
        case .urgent: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "success"
        case .medium: return "warning"
        case .high: return "error"
        case .urgent: return "error"
        }
    }
}

enum InquirySource: String, Codable, CaseIterable {
    case website = "website"
    case phone = "phone"
    case email = "email"
    case referral = "referral"
    case walkIn = "walk_in"
    case socialMedia = "social_media"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .website: return "Website"
        case .phone: return "Phone"
        case .email: return "Email"
        case .referral: return "Referral"
        case .walkIn: return "Walk-in"
        case .socialMedia: return "Social Media"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .website: return "globe"
        case .phone: return "phone"
        case .email: return "envelope"
        case .referral: return "person.2"
        case .walkIn: return "door.left.hand.open"
        case .socialMedia: return "at"
        case .other: return "questionmark.circle"
        }
    }
}

enum ContactMethod: String, Codable, CaseIterable {
    case email = "email"
    case phone = "phone"
    case text = "text"
    case any = "any"
    
    var displayName: String {
        switch self {
        case .email: return "Email"
        case .phone: return "Phone"
        case .text: return "Text"
        case .any: return "Any"
        }
    }
    
    var icon: String {
        switch self {
        case .email: return "envelope"
        case .phone: return "phone"
        case .text: return "message"
        case .any: return "ellipsis.message"
        }
    }
}

// MARK: - Contact Attempts Data

enum ContactAttemptsData: Codable {
    case count(Int)
    case array([ContactAttempt])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let count = try? container.decode(Int.self) {
            self = .count(count)
        } else if let array = try? container.decode([ContactAttempt].self) {
            self = .array(array)
        } else {
            throw DecodingError.typeMismatch(ContactAttemptsData.self, 
                DecodingError.Context(codingPath: decoder.codingPath, 
                                    debugDescription: "Expected Int or [ContactAttempt]"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .count(let count):
            try container.encode(count)
        case .array(let array):
            try container.encode(array)
        }
    }
    
    var contactAttemptsList: [ContactAttempt] {
        switch self {
        case .count(_):
            return []
        case .array(let array):
            return array
        }
    }
    
    var contactAttemptsCount: Int {
        switch self {
        case .count(let count):
            return count
        case .array(let array):
            return array.count
        }
    }
    
    var isEmpty: Bool {
        switch self {
        case .count(let count):
            return count == 0
        case .array(let array):
            return array.isEmpty
        }
    }
}

// MARK: - Contact Attempt

struct ContactAttempt: Codable, Identifiable {
    let id: String
    let inquiryId: String
    let method: ContactMethod
    let outcome: ContactOutcome
    let notes: String?
    let scheduledFollowUp: Date?
    let createdAt: Date
    let createdBy: String
    let createdByName: String
}

enum ContactOutcome: String, Codable, CaseIterable {
    case successful = "successful"
    case noAnswer = "no_answer"
    case leftMessage = "left_message"
    case busySignal = "busy_signal"
    case invalidNumber = "invalid_number"
    case emailBounced = "email_bounced"
    case requestedCallback = "requested_callback"
    
    var displayName: String {
        switch self {
        case .successful: return "Successful Contact"
        case .noAnswer: return "No Answer"
        case .leftMessage: return "Left Message"
        case .busySignal: return "Busy Signal"
        case .invalidNumber: return "Invalid Number"
        case .emailBounced: return "Email Bounced"
        case .requestedCallback: return "Requested Callback"
        }
    }
    
    var icon: String {
        switch self {
        case .successful: return "checkmark.circle"
        case .noAnswer: return "phone.down"
        case .leftMessage: return "voicemail"
        case .busySignal: return "phone.badge.plus"
        case .invalidNumber: return "phone.slash"
        case .emailBounced: return "envelope.badge.shield.half.filled"
        case .requestedCallback: return "phone.arrow.down.left"
        }
    }
    
    var color: String {
        switch self {
        case .successful: return "success"
        case .noAnswer, .busySignal: return "warning"
        case .leftMessage, .requestedCallback: return "info"
        case .invalidNumber, .emailBounced: return "error"
        }
    }
}

// MARK: - Request/Response Types

struct CreateInquiryRequest: Codable {
    let firstName: String
    let lastName: String
    let email: String?
    let phone: String?
    let dateOfBirth: Date?
    let guardianName: String?
    let guardianEmail: String?
    let guardianPhone: String?
    let reasonForInquiry: String
    let preferredContactMethod: ContactMethod
    let urgency: InquiryUrgency
    let source: InquirySource
    let notes: String?
}

struct UpdateInquiryRequest: Codable {
    let status: InquiryStatus?
    let assignedProviderId: String?
    let notes: String?
    let followUpDate: Date?
    let urgency: InquiryUrgency?
}

struct CreateContactAttemptRequest: Codable {
    let method: ContactMethod
    let outcome: ContactOutcome
    let notes: String?
    let scheduledFollowUp: Date?
}

struct ConvertInquiryRequest: Codable {
    let assignedProviderId: String?
    let notes: String?
}

struct InquiryListResponse: Codable {
    let inquiries: [Inquiry]
    let pagination: PaginationInfo
    
    // Computed properties for backward compatibility
    var totalCount: Int { pagination.total }
    var hasMore: Bool { pagination.page < pagination.pages }
}

struct PaginationInfo: Codable {
    let page: Int
    let limit: Int
    let total: Int
    let pages: Int
}

struct InquiryStatsResponse: Codable {
    let totalInquiries: Int
    let newInquiries: Int
    let inProgressInquiries: Int
    let convertedInquiries: Int
    let averageResponseTime: Double
    let conversionRate: Double
}

// MARK: - Supporting Types for Filtering

enum InquiryFilterOption: String, CaseIterable {
    case all = "all"
    case new = "new"
    case assigned = "assigned"
    case overdue = "overdue"
    case high_priority = "high_priority"
    
    var displayName: String {
        switch self {
        case .all: return "All Inquiries"
        case .new: return "New"
        case .assigned: return "Assigned to Me"
        case .overdue: return "Overdue"
        case .high_priority: return "High Priority"
        }
    }
}

enum InquirySortOption: String, CaseIterable {
    case createdAt = "createdAt"
    case updatedAt = "updatedAt"
    case urgency = "urgency"
    case status = "status"
    case followUpDate = "followUpDate"
    
    var displayName: String {
        switch self {
        case .createdAt: return "Created Date"
        case .updatedAt: return "Last Updated"
        case .urgency: return "Urgency"
        case .status: return "Status"
        case .followUpDate: return "Follow-up Date"
        }
    }
}