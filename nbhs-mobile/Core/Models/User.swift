//
//  User.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import Foundation

// MARK: - User

struct User: Codable, Identifiable, Equatable {
    let id: String
    let publicId: String?
    let createdAt: Date
    let updatedAt: Date
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let role: UserRole
    let status: UserStatus
    let mustChangePassword: Bool
    let isEmailVerified: Bool
    let providerDetails: ProviderDetails?
    let patientDetails: PatientDetails?
    let guardianDetails: GuardianDetails?
    
    // Computed properties
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var initials: String {
        "\(firstName.prefix(1))\(lastName.prefix(1))".uppercased()
    }
    
    var displayName: String {
        if let providerDetails = providerDetails {
            return "\(fullName) (\(providerDetails.credentials ?? providerDetails.providerType.displayName))"
        }
        return fullName
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - UserRole

enum UserRole: String, Codable, CaseIterable {
    case PATIENT = "PATIENT"
    case PROVIDER = "PROVIDER"
    case ADMIN = "ADMIN"
    case GUARDIAN = "GUARDIAN"
    
    var displayName: String {
        switch self {
        case .PATIENT: return "Patient"
        case .PROVIDER: return "Provider"
        case .ADMIN: return "Administrator"
        case .GUARDIAN: return "Guardian"
        }
    }
    
    var canAccessProviderPortal: Bool {
        return self == .PROVIDER || self == .ADMIN
    }
}

// MARK: - UserStatus

enum UserStatus: String, Codable, CaseIterable {
    case ACTIVE = "ACTIVE"
    case INACTIVE = "INACTIVE"
    case PENDING = "PENDING"
    case INQUIRY = "INQUIRY"
    case INELIGIBLE = "INELIGIBLE"
    
    var displayName: String {
        switch self {
        case .ACTIVE: return "Active"
        case .INACTIVE: return "Inactive"
        case .PENDING: return "Pending"
        case .INQUIRY: return "Inquiry"
        case .INELIGIBLE: return "Ineligible"
        }
    }
    
    var color: String {
        switch self {
        case .ACTIVE: return "green"
        case .INACTIVE: return "gray"
        case .PENDING: return "yellow"
        case .INQUIRY: return "blue"
        case .INELIGIBLE: return "red"
        }
    }
}

// MARK: - ProviderDetails

struct ProviderDetails: Codable, Identifiable {
    let id: String
    let createdAt: Date
    let updatedAt: Date
    let providerType: ProviderType
    let credentials: String?
    let licenseNumber: String?
    let npiNumber: String?
    let specialties: String?
    let bio: String?
    let userId: String
    
    var specialtiesArray: [String] {
        specialties?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } ?? []
    }
}

// MARK: - ProviderType

enum ProviderType: String, Codable, CaseIterable {
    case PSYCHOLOGIST = "PSYCHOLOGIST"
    case PSYCHOMETRIST = "PSYCHOMETRIST"
    case PSYCHIATRIST = "PSYCHIATRIST"
    case THERAPIST = "THERAPIST"
    case COUNSELOR = "COUNSELOR"
    case SOCIAL_WORKER = "SOCIAL_WORKER"
    case NURSE_PRACTITIONER = "NURSE_PRACTITIONER"
    case PHYSICIAN_ASSISTANT = "PHYSICIAN_ASSISTANT"
    case TECHNICIAN = "TECHNICIAN"
    case OTHER = "OTHER"
    
    var displayName: String {
        switch self {
        case .PSYCHOLOGIST: return "Psychologist"
        case .PSYCHOMETRIST: return "Psychometrist"
        case .PSYCHIATRIST: return "Psychiatrist"
        case .THERAPIST: return "Therapist"
        case .COUNSELOR: return "Counselor"
        case .SOCIAL_WORKER: return "Social Worker"
        case .NURSE_PRACTITIONER: return "Nurse Practitioner"
        case .PHYSICIAN_ASSISTANT: return "Physician Assistant"
        case .TECHNICIAN: return "Technician"
        case .OTHER: return "Other"
        }
    }
    
    var abbreviation: String {
        switch self {
        case .PSYCHOLOGIST: return "PhD"
        case .PSYCHOMETRIST: return "MA"
        case .PSYCHIATRIST: return "MD"
        case .THERAPIST: return "LCSW"
        case .COUNSELOR: return "LPC"
        case .SOCIAL_WORKER: return "LCSW"
        case .NURSE_PRACTITIONER: return "NP"
        case .PHYSICIAN_ASSISTANT: return "PA"
        case .TECHNICIAN: return "Tech"
        case .OTHER: return ""
        }
    }
}

// MARK: - PatientDetails

struct PatientDetails: Codable, Identifiable {
    let id: String
    let publicId: String?
    let createdAt: Date
    let updatedAt: Date
    let dateOfBirth: Date?
    let addressStreet: String?
    let addressCity: String?
    let addressState: String?
    let addressZipCode: String?
    let stripeCustomerId: String?
    let preferredLanguage: String
    let userId: String
    
    var fullAddress: String? {
        let components = [addressStreet, addressCity, addressState, addressZipCode].compactMap { $0 }
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
    
    var age: Int? {
        guard let dateOfBirth = dateOfBirth else { return nil }
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: now)
        return ageComponents.year
    }
}

// MARK: - GuardianDetails

struct GuardianDetails: Codable, Identifiable {
    let id: String
    let publicId: String?
    let createdAt: Date
    let updatedAt: Date
    let addressStreet: String?
    let addressCity: String?
    let addressState: String?
    let addressZipCode: String?
    let userId: String
    
    var fullAddress: String? {
        let components = [addressStreet, addressCity, addressState, addressZipCode].compactMap { $0 }
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
}

// MARK: - Authentication Models

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let user: User?
    let token: String?
    let refreshToken: String?
    let expiresIn: Int?
}

struct LogoutResponse: Codable {
    let success: Bool
    let message: String
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

struct RefreshTokenResponse: Codable {
    let success: Bool
    let token: String?
    let expiresIn: Int?
}