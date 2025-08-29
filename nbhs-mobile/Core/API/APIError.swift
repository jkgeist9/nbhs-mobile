//
//  APIError.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case serverError(Int, String)
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case maintenance
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .unauthorized:
            return "Authentication required. Please log in again."
        case .forbidden:
            return "Access denied. You don't have permission to perform this action."
        case .notFound:
            return "The requested resource was not found."
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .maintenance:
            return "The service is temporarily unavailable for maintenance."
        case .unknownError:
            return "An unknown error occurred"
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkError:
            return true
        case .serverError(let code, _):
            return code >= 500 || code == 429
        case .rateLimited:
            return true
        default:
            return false
        }
    }
    
    var shouldLogOut: Bool {
        switch self {
        case .unauthorized:
            return true
        default:
            return false
        }
    }
}

// MARK: - API Response

struct APIResponse<T: Codable>: Codable {
    let data: T?
    let message: String?
    let success: Bool
    let error: String?
    
    init(data: T? = nil, message: String? = nil, success: Bool = true, error: String? = nil) {
        self.data = data
        self.message = message
        self.success = success
        self.error = error
    }
}

// MARK: - Error Response

struct ErrorResponse: Codable {
    let message: String
    let error: String?
    let details: [String: String]?
    
    init(message: String, error: String? = nil, details: [String: String]? = nil) {
        self.message = message
        self.error = error
        self.details = details
    }
}