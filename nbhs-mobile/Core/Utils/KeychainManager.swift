//
//  KeychainManager.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import Foundation
import Security
import LocalAuthentication

class KeychainManager {
    static let shared = KeychainManager()
    
    private let service = "com.nbhealthservices.provider"
    private let tokenKey = "auth_token"
    private let refreshTokenKey = "refresh_token"
    
    private init() {}
    
    // MARK: - Token Management
    
    func store(token: String) {
        store(value: token, for: tokenKey)
    }
    
    func getToken() -> String? {
        return getValue(for: tokenKey)
    }
    
    func deleteToken() {
        deleteValue(for: tokenKey)
    }
    
    // MARK: - Refresh Token Management
    
    func store(refreshToken: String) {
        store(value: refreshToken, for: refreshTokenKey)
    }
    
    func getRefreshToken() -> String? {
        return getValue(for: refreshTokenKey)
    }
    
    func deleteRefreshToken() {
        deleteValue(for: refreshTokenKey)
    }
    
    // MARK: - Clear All
    
    func clearAll() {
        deleteToken()
        deleteRefreshToken()
    }
    
    // MARK: - Private Methods
    
    private func store(value: String, for key: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("Keychain store error: \(status)")
        }
    }
    
    private func getValue(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        }
        
        return nil
    }
    
    func deleteValue(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Keychain delete error: \(status)")
        }
    }
    
    // MARK: - Biometric Authentication Support
    
    func storeWithBiometrics(value: String, for key: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("Keychain biometric store error: \(status)")
        }
    }
    
    func getValueWithBiometrics(for key: String, prompt: String) async -> String? {
        let context = LAContext()
        context.localizedReason = prompt
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationContext as String: context
        ]
        
        return await withCheckedContinuation { continuation in
            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)
            
            if status == errSecSuccess,
               let data = result as? Data,
               let value = String(data: data, encoding: .utf8) {
                continuation.resume(returning: value)
            } else {
                continuation.resume(returning: nil)
            }
        }
    }
}

// MARK: - Keychain Errors

extension KeychainManager {
    enum KeychainError: Error {
        case duplicateItem
        case itemNotFound
        case invalidItemFormat
        case unexpectedStatus(OSStatus)
        
        var localizedDescription: String {
            switch self {
            case .duplicateItem:
                return "Duplicate item in keychain"
            case .itemNotFound:
                return "Item not found in keychain"
            case .invalidItemFormat:
                return "Invalid item format"
            case .unexpectedStatus(let status):
                return "Unexpected keychain status: \(status)"
            }
        }
    }
}