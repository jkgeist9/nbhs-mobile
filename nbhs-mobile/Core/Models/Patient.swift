//
//  Patient.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import Foundation

// MARK: - Patient Models

struct Patient: Codable, Identifiable {
    let id: String
    let publicId: String?
    let firstName: String
    let lastName: String
    let dateOfBirth: Date
    let email: String?
    let phone: String?
    let address: PatientAddress?
    let emergencyContact: EmergencyContact?
    let insurance: InsuranceInfo?
    let medicalRecord: MedicalRecordInfo?
    let status: PatientStatus
    let assignedProviderId: String?
    let assignedProviderName: String?
    let createdAt: Date
    let updatedAt: Date
    let lastAppointment: Date?
    let nextAppointment: Date?
    
    // MARK: - Computed Properties
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var initials: String {
        "\(firstName.prefix(1))\(lastName.prefix(1))".uppercased()
    }
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }
    
    var displayName: String {
        fullName
    }
    
    var contactInfo: String {
        if let phone = phone {
            return phone
        } else if let email = email {
            return email
        }
        return "No contact info"
    }
    
    var isActive: Bool {
        status == .active
    }
    
    var hasUpcomingAppointment: Bool {
        guard let nextAppointment = nextAppointment else { return false }
        return nextAppointment > Date()
    }
    
    var daysSinceLastAppointment: Int? {
        guard let lastAppointment = lastAppointment else { return nil }
        return Calendar.current.dateComponents([.day], from: lastAppointment, to: Date()).day
    }
}

enum PatientStatus: String, Codable, CaseIterable {
    case active = "active"
    case inactive = "inactive"
    case discharged = "discharged"
    case pending = "pending"
    case archived = "archived"
    
    var displayName: String {
        switch self {
        case .active: return "Active"
        case .inactive: return "Inactive"
        case .discharged: return "Discharged"
        case .pending: return "Pending"
        case .archived: return "Archived"
        }
    }
    
    var color: String {
        switch self {
        case .active: return "success"
        case .inactive: return "warning"
        case .discharged: return "textSecondary"
        case .pending: return "info"
        case .archived: return "textTertiary"
        }
    }
    
    var icon: String {
        switch self {
        case .active: return "checkmark.circle.fill"
        case .inactive: return "pause.circle"
        case .discharged: return "checkmark.circle"
        case .pending: return "clock.circle"
        case .archived: return "archivebox"
        }
    }
}

struct PatientAddress: Codable {
    let street: String
    let city: String
    let state: String
    let zipCode: String
    let country: String?
    
    var fullAddress: String {
        "\(street), \(city), \(state) \(zipCode)"
    }
}

struct EmergencyContact: Codable {
    let name: String
    let relationship: String
    let phone: String
    let email: String?
}

struct InsuranceInfo: Codable {
    let provider: String
    let policyNumber: String
    let groupNumber: String?
    let subscriberName: String
    let effectiveDate: Date?
    let expirationDate: Date?
    
    var isActive: Bool {
        guard let expiration = expirationDate else { return true }
        return expiration > Date()
    }
}

struct MedicalRecordInfo: Codable {
    let recordNumber: String
    let primaryDiagnosis: String?
    let secondaryDiagnoses: [String]
    let medications: [Medication]
    let allergies: [Allergy]
    let notes: String?
    let lastUpdated: Date
}

struct Medication: Codable, Identifiable {
    let id: String
    let name: String
    let dosage: String
    let frequency: String
    let prescribedDate: Date
    let prescribedBy: String
    let isActive: Bool
    let notes: String?
}

struct Allergy: Codable, Identifiable {
    let id: String
    let allergen: String
    let severity: AllergySeverity
    let reaction: String?
    let notes: String?
}

enum AllergySeverity: String, Codable, CaseIterable {
    case mild = "mild"
    case moderate = "moderate"
    case severe = "severe"
    case lifeThreatening = "life_threatening"
    
    var displayName: String {
        switch self {
        case .mild: return "Mild"
        case .moderate: return "Moderate"
        case .severe: return "Severe"
        case .lifeThreatening: return "Life-Threatening"
        }
    }
    
    var color: String {
        switch self {
        case .mild: return "success"
        case .moderate: return "warning"
        case .severe: return "error"
        case .lifeThreatening: return "error"
        }
    }
}

// MARK: - Patient Search and Filtering

struct PatientSearchCriteria: Codable {
    let searchTerm: String?
    let status: PatientStatus?
    let providerId: String?
    let sortBy: PatientSortOption
    let sortOrder: SortOrder
    let limit: Int?
    let offset: Int?
}

enum PatientSortOption: String, Codable, CaseIterable {
    case name = "name"
    case lastAppointment = "last_appointment"
    case nextAppointment = "next_appointment"
    case createdAt = "created_at"
    case status = "status"
    
    var displayName: String {
        switch self {
        case .name: return "Name"
        case .lastAppointment: return "Last Appointment"
        case .nextAppointment: return "Next Appointment"
        case .createdAt: return "Date Added"
        case .status: return "Status"
        }
    }
}

enum SortOrder: String, Codable, CaseIterable {
    case ascending = "asc"
    case descending = "desc"
    
    var displayName: String {
        switch self {
        case .ascending: return "A-Z"
        case .descending: return "Z-A"
        }
    }
}

// MARK: - Patient List Response

struct PatientListResponse: Codable {
    let patients: [Patient]
    let totalCount: Int
    let hasMore: Bool
    let filters: PatientSearchCriteria
}

// MARK: - Patient Statistics

struct PatientStatistics: Codable {
    let totalPatients: Int
    let activePatients: Int
    let newPatientsThisMonth: Int
    let patientsWithUpcomingAppointments: Int
    let averageAge: Double
    let statusBreakdown: [PatientStatus: Int]
    let appointmentStats: PatientAppointmentStats
}

struct PatientAppointmentStats: Codable {
    let totalAppointments: Int
    let completedAppointments: Int
    let missedAppointments: Int
    let averageAppointmentsPerPatient: Double
    let mostRecentAppointment: Date?
}