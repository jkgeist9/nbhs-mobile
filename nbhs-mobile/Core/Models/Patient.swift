//
//  Patient.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import Foundation

// MARK: - API Response Models (exact match to backend)

struct PatientAPIDetails: Codable {
    let id: String
    let publicId: String
}

struct Patient: Codable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String?
    let phone: String?
    let dateOfBirth: Date?
    let status: String
    let patientWorkflowStatus: String?
    let evaluationsCount: Int?
    let appointmentsCount: Int?
    let patientDetails: PatientAPIDetails?
    
    // MARK: - Computed Properties
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var initials: String {
        "\(firstName.prefix(1))\(lastName.prefix(1))".uppercased()
    }
    
    var age: Int {
        guard let dateOfBirth = dateOfBirth else { return 0 }
        return Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }
    
    var displayName: String {
        fullName
    }
    
    var publicId: String? { 
        patientDetails?.publicId 
    }
}

// MARK: - Patient List Response

struct PatientListResponse: Codable {
    let patients: [Patient]
    let pagination: PatientPagination
}

struct PatientPagination: Codable {
    let page: Int
    let limit: Int
    let total: Int
    let totalPages: Int
}