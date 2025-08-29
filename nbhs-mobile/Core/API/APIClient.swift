//
//  APIClient.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import Foundation
import Combine

class APIClient: ObservableObject {
    static let shared = APIClient()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // MARK: - Authentication State
    @Published var isAuthenticated = false
    private var authToken: String?
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfig.timeout
        config.timeoutIntervalForResource = APIConfig.timeout * 2
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
        
        // Configure date formatting to match backend
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        // Load saved auth token
        loadAuthToken()
    }
    
    // MARK: - Authentication Management
    
    func setAuthToken(_ token: String) {
        self.authToken = token
        self.isAuthenticated = true
        KeychainManager.shared.store(token: token)
    }
    
    func clearAuthToken() {
        self.authToken = nil
        self.isAuthenticated = false
        KeychainManager.shared.deleteToken()
    }
    
    private func loadAuthToken() {
        if let token = KeychainManager.shared.getToken() {
            self.authToken = token
            self.isAuthenticated = true
        }
    }
    
    // MARK: - Request Methods
    
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil,
        requiresAuth: Bool = true
    ) async throws -> APIResponse<T> {
        
        guard let url = URL(string: APIConfig.baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Add headers
        let headers = requiresAuth && authToken != nil 
            ? APIConfig.authHeaders(token: authToken!)
            : APIConfig.defaultHeaders
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknownError
            }
            
            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401:
                if requiresAuth {
                    clearAuthToken()
                }
                throw APIError.unauthorized
            case 403:
                throw APIError.forbidden
            case 404:
                throw APIError.notFound
            case 429:
                throw APIError.rateLimited
            case 503:
                throw APIError.maintenance
            case 400...499:
                let errorResponse = try? decoder.decode(ErrorResponse.self, from: data)
                throw APIError.serverError(httpResponse.statusCode, errorResponse?.message ?? "Client error")
            case 500...599:
                let errorResponse = try? decoder.decode(ErrorResponse.self, from: data)
                throw APIError.serverError(httpResponse.statusCode, errorResponse?.message ?? "Server error")
            default:
                throw APIError.unknownError
            }
            
            // Decode response
            do {
                let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)
                return apiResponse
            } catch {
                throw APIError.decodingError(error)
            }
            
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Convenience Methods
    
    func get<T: Codable>(
        endpoint: String,
        requiresAuth: Bool = true
    ) async throws -> APIResponse<T> {
        return try await request(
            endpoint: endpoint,
            method: .GET,
            requiresAuth: requiresAuth
        )
    }
    
    func post<T: Codable, U: Codable>(
        endpoint: String,
        body: U,
        requiresAuth: Bool = true
    ) async throws -> APIResponse<T> {
        let bodyData = try encoder.encode(body)
        return try await request(
            endpoint: endpoint,
            method: .POST,
            body: bodyData,
            requiresAuth: requiresAuth
        )
    }
    
    func put<T: Codable, U: Codable>(
        endpoint: String,
        body: U,
        requiresAuth: Bool = true
    ) async throws -> APIResponse<T> {
        let bodyData = try encoder.encode(body)
        return try await request(
            endpoint: endpoint,
            method: .PUT,
            body: bodyData,
            requiresAuth: requiresAuth
        )
    }
    
    func delete<T: Codable>(
        endpoint: String,
        requiresAuth: Bool = true
    ) async throws -> APIResponse<T> {
        return try await request(
            endpoint: endpoint,
            method: .DELETE,
            requiresAuth: requiresAuth
        )
    }
    
    // MARK: - File Upload
    
    func uploadFile<T: Codable>(
        endpoint: String,
        fileData: Data,
        fileName: String,
        mimeType: String,
        additionalFields: [String: String] = [:]
    ) async throws -> APIResponse<T> {
        
        guard let url = URL(string: APIConfig.baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let authToken = authToken {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        
        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add additional fields
        for (key, value) in additionalFields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknownError
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)
                return apiResponse
            case 401:
                clearAuthToken()
                throw APIError.unauthorized
            case 403:
                throw APIError.forbidden
            case 413:
                throw APIError.serverError(413, "File too large")
            default:
                let errorResponse = try? decoder.decode(ErrorResponse.self, from: data)
                throw APIError.serverError(httpResponse.statusCode, errorResponse?.message ?? "Upload failed")
            }
            
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - HTTP Methods

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}