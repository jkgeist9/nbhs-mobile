//
//  APIConfig.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import Foundation

struct APIConfig {
    // MARK: - Environment Configuration
    
    #if DEBUG
    static let baseURL = "http://localhost:8080/api"
    static let environment = "development"
    #elseif STAGING
    static let baseURL = "https://staging-api.nbhealthservices.com/api"
    static let environment = "staging"
    #else
    static let baseURL = "https://api.nbhealthservices.com/api"
    static let environment = "production"
    #endif
    
    // MARK: - API Endpoints
    
    struct Endpoints {
        // Authentication
        static let login = "/auth/login"
        static let logout = "/auth/logout"
        static let refresh = "/auth/refresh"
        static let health = "/auth/health"
        
        // Dashboard
        static let dashboard = "/dashboard"
        static let activities = "/activities"
        
        // Patients
        static let patients = "/patients"
        static func patient(_ id: String) -> String { "/patients/\(id)" }
        static func patientAppointments(_ patientId: String) -> String { "/appointments?patientId=\(patientId)" }
        static func patientFiles(_ patientId: String) -> String { "/files?patientId=\(patientId)" }
        static func patientBilling(_ patientId: String) -> String { "/billing/patient/\(patientId)" }
        static func patientNotes(_ patientId: String) -> String { "/provider-notes?patientId=\(patientId)" }
        
        // Appointments
        static let appointments = "/appointments"
        static func appointment(_ id: String) -> String { "/appointments/\(id)" }
        
        // Availability
        static let availability = "/availability"
        static func providerAvailability(_ providerId: String) -> String { "/availability/provider/\(providerId)" }
        
        // Inquiries
        static let inquiries = "/inquiries"
        static func inquiry(_ id: String) -> String { "/inquiries/\(id)" }
        static func inquiryStatus(_ id: String) -> String { "/inquiries/\(id)/status" }
        static func inquiryConvert(_ id: String) -> String { "/inquiries/\(id)/convert" }
        static func inquiryContactAttempts(_ id: String) -> String { "/inquiries/\(id)/contact-attempts" }
        
        // Evaluations
        static let evaluations = "/evaluations"
        static func evaluation(_ id: String) -> String { "/evaluations/\(id)" }
        
        // Messages
        static let conversations = "/messages/conversations"
        static let messages = "/messages"
        static func messageRead(_ id: String) -> String { "/messages/\(id)/read" }
        
        // Billing
        static let billingInvoices = "/billing/invoices"
        static let billingReports = "/billing/reports"
        static func invoice(_ id: String) -> String { "/billing/invoices/\(id)" }
        
        // IVR Call Center
        static let ivrCalls = "/ivr/calls"
        static let ivrAnalytics = "/ivr/analytics"
        static func ivrCall(_ id: String) -> String { "/ivr/calls/\(id)" }
        
        // Files/Documents
        static let files = "/files"
        static let filesUpload = "/files/upload"
        static func file(_ id: String) -> String { "/files/\(id)" }
        
        // Provider Notes
        static let providerNotes = "/provider-notes"
        static func providerNote(_ id: String) -> String { "/provider-notes/\(id)" }
    }
    
    // MARK: - Request Configuration
    
    static let timeout: TimeInterval = 30.0
    static let retryAttempts = 3
    
    // MARK: - Headers
    
    static var defaultHeaders: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "NBHS-iOS/\(AppInfo.version) (\(AppInfo.build))"
        ]
    }
    
    static func authHeaders(token: String) -> [String: String] {
        var headers = defaultHeaders
        headers["Authorization"] = "Bearer \(token)"
        return headers
    }
}

// MARK: - App Information

struct AppInfo {
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    static var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "com.nbhealthservices.provider"
    }
}