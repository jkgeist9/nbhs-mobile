//
//  AuthService.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import Foundation
import Combine
import LocalAuthentication

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var authError: String?
    
    private let apiClient = APIClient.shared
    private let keychain = KeychainManager.shared
    
    private init() {
        // Check for existing auth state
        checkAuthState()
    }
    
    // MARK: - Authentication Methods
    
    @MainActor
    func login(email: String, password: String) async {
        isLoading = true
        authError = nil
        
        do {
            let loginRequest = LoginRequest(email: email, password: password)
            let response: APIResponse<LoginResponse> = try await apiClient.post(
                endpoint: APIConfig.Endpoints.login,
                body: loginRequest,
                requiresAuth: false
            )
            
            guard let loginData = response.data,
                  loginData.success,
                  let user = loginData.user,
                  let token = loginData.token else {
                throw APIError.serverError(400, response.data?.message ?? "Login failed")
            }
            
            // Store authentication data
            apiClient.setAuthToken(token)
            
            if let refreshToken = loginData.refreshToken {
                keychain.store(refreshToken: refreshToken)
            }
            
            // Update state
            self.user = user
            self.isAuthenticated = true
            
            // Check if biometric authentication is available and store token securely
            if await isBiometricAuthenticationAvailable() {
                keychain.storeWithBiometrics(value: token, for: "auth_token_biometric")
            }
            
        } catch {
            if let apiError = error as? APIError {
                self.authError = apiError.localizedDescription
            } else {
                self.authError = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    @MainActor
    func logout() async {
        isLoading = true
        
        do {
            // Call logout endpoint if authenticated
            if isAuthenticated {
                let _: APIResponse<LogoutResponse> = try await apiClient.post(
                    endpoint: APIConfig.Endpoints.logout,
                    body: ["message": "Logout request"]
                )
            }
        } catch {
            // Continue with logout even if API call fails
            print("Logout API call failed: \(error)")
        }
        
        // Clear local state
        clearAuthState()
        isLoading = false
    }
    
    @MainActor
    func refreshToken() async -> Bool {
        guard let refreshToken = keychain.getRefreshToken() else {
            return false
        }
        
        do {
            let refreshRequest = RefreshTokenRequest(refreshToken: refreshToken)
            let response: APIResponse<RefreshTokenResponse> = try await apiClient.post(
                endpoint: APIConfig.Endpoints.refresh,
                body: refreshRequest,
                requiresAuth: false
            )
            
            guard let refreshData = response.data,
                  refreshData.success,
                  let newToken = refreshData.token else {
                return false
            }
            
            // Update token
            apiClient.setAuthToken(newToken)
            return true
            
        } catch {
            print("Token refresh failed: \(error)")
            return false
        }
    }
    
    // MARK: - Biometric Authentication
    
    func isBiometricAuthenticationAvailable() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    @MainActor
    func loginWithBiometrics() async {
        guard await isBiometricAuthenticationAvailable() else {
            authError = "Biometric authentication is not available"
            return
        }
        
        isLoading = true
        authError = nil
        
        let token = await keychain.getValueWithBiometrics(
            for: "auth_token_biometric",
            prompt: "Authenticate to access NBHS Provider Portal"
        )
        
        guard let token = token else {
            authError = "Biometric authentication failed"
            isLoading = false
            return
        }
        
        // Verify token with backend
        apiClient.setAuthToken(token)
        
        do {
            let response: APIResponse<User> = try await apiClient.get(
                endpoint: "/auth/me",
                requiresAuth: true
            )
            
            if let user = response.data {
                self.user = user
                self.isAuthenticated = true
            } else {
                throw APIError.unauthorized
            }
            
        } catch {
            // Token is invalid, clear biometric storage and require regular login
            keychain.deleteValue(for: "auth_token_biometric")
            clearAuthState()
            
            if let apiError = error as? APIError {
                self.authError = apiError.localizedDescription
            } else {
                self.authError = "Authentication failed"
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Password Management
    
    @MainActor
    func changePassword(currentPassword: String, newPassword: String) async -> Bool {
        isLoading = true
        authError = nil
        
        do {
            let request = [
                "currentPassword": currentPassword,
                "newPassword": newPassword
            ]
            
            let response: APIResponse<[String: String]> = try await apiClient.post(
                endpoint: "/auth/change-password",
                body: request
            )
            
            isLoading = false
            return response.data?["success"] == "true"
            
        } catch {
            if let apiError = error as? APIError {
                self.authError = apiError.localizedDescription
            } else {
                self.authError = error.localizedDescription
            }
            isLoading = false
            return false
        }
    }
    
    @MainActor
    func requestPasswordReset(email: String) async -> Bool {
        isLoading = true
        authError = nil
        
        do {
            let request = ["email": email]
            let response: APIResponse<[String: String]> = try await apiClient.post(
                endpoint: "/auth/forgot-password",
                body: request,
                requiresAuth: false
            )
            
            isLoading = false
            return response.success
            
        } catch {
            if let apiError = error as? APIError {
                self.authError = apiError.localizedDescription
            } else {
                self.authError = error.localizedDescription
            }
            isLoading = false
            return false
        }
    }
    
    // MARK: - User Profile
    
    @MainActor
    func updateProfile(firstName: String, lastName: String, phone: String?) async -> Bool {
        isLoading = true
        authError = nil
        
        do {
            let request = [
                "firstName": firstName,
                "lastName": lastName,
                "phone": phone ?? ""
            ]
            
            let response: APIResponse<User> = try await apiClient.put(
                endpoint: "/users/profile",
                body: request
            )
            
            if let updatedUser = response.data {
                self.user = updatedUser
            }
            
            isLoading = false
            return response.success
            
        } catch {
            if let apiError = error as? APIError {
                self.authError = apiError.localizedDescription
            } else {
                self.authError = error.localizedDescription
            }
            isLoading = false
            return false
        }
    }
    
    // MARK: - Helper Methods
    
    private func checkAuthState() {
        if let token = keychain.getToken() {
            apiClient.setAuthToken(token)
            
            // Verify token with backend (optional, could be done lazily)
            Task {
                await verifyStoredToken()
            }
        }
    }
    
    @MainActor
    private func verifyStoredToken() async {
        do {
            let response: APIResponse<User> = try await apiClient.get(
                endpoint: "/auth/me",
                requiresAuth: true
            )
            
            if let user = response.data {
                self.user = user
                self.isAuthenticated = true
            } else {
                clearAuthState()
            }
            
        } catch {
            // Token is invalid or expired, try to refresh
            let refreshSuccess = await refreshToken()
            if !refreshSuccess {
                clearAuthState()
            } else {
                // Try again with new token
                await verifyStoredToken()
            }
        }
    }
    
    private func clearAuthState() {
        self.user = nil
        self.isAuthenticated = false
        self.authError = nil
        
        apiClient.clearAuthToken()
        keychain.clearAll()
    }
    
    // MARK: - Session Management
    
    func shouldAutoLogout() -> Bool {
        // Implement session timeout logic based on your requirements
        // For now, keep session active while app is in use
        return false
    }
    
    func extendSession() {
        // Called when user interacts with app to extend session
        // Could implement token refresh or update last activity time
    }
}

// MARK: - Notification Names

extension AuthService {
    static let didLoginNotification = Notification.Name("AuthService.didLogin")
    static let didLogoutNotification = Notification.Name("AuthService.didLogout")
    static let tokenDidExpireNotification = Notification.Name("AuthService.tokenDidExpire")
}