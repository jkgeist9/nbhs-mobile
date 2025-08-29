//
//  LoginView.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @StateObject private var authService = AuthService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var showForgotPassword = false
    @State private var showBiometricLogin = false
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Logo and Header Section
                    headerSection
                        .frame(minHeight: geometry.size.height * 0.4)
                    
                    // Login Form Section
                    loginFormSection
                        .padding(.top, 40)
                }
                .frame(minHeight: geometry.size.height - keyboardHeight)
            }
            .background(
                LinearGradient(
                    colors: [.teal50, .white],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea(.keyboard)
            .onAppear {
                checkBiometricAvailability()
                setupKeyboardObservers()
            }
            .onDisappear {
                removeKeyboardObservers()
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // NBHS Logo
            VStack(spacing: 16) {
                // NBHS Logo
                Image("NBHSLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 80)
                    .clipped()
                
                VStack(spacing: 8) {
                    Text("NeuroBehavioral Health Services")
                        .font(Typography.heading3)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Provider Portal")
                        .font(Typography.bodyLarge)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Login Form Section
    
    private var loginFormSection: some View {
        VStack(spacing: 24) {
            // Welcome Text
            VStack(spacing: 8) {
                Text("Welcome Back")
                    .font(Typography.heading2)
                    .foregroundColor(.textPrimary)
                
                Text("Sign in to access your provider portal")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Login Form
            VStack(spacing: 20) {
                NBInputField.email(
                    label: "Email Address",
                    text: $email,
                    errorText: authService.authError?.contains("email") == true ? authService.authError : nil,
                    isRequired: true,
                    isDisabled: authService.isLoading
                )
                
                NBInputField.password(
                    label: "Password",
                    text: $password,
                    errorText: authService.authError?.contains("password") == true ? authService.authError : nil,
                    isRequired: true,
                    isDisabled: authService.isLoading
                )
                
                // Remember Me & Forgot Password
                HStack {
                    Button(action: {
                        rememberMe.toggle()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                .foregroundColor(rememberMe ? .teal500 : .textTertiary)
                                .font(.system(size: 16))
                            
                            Text("Remember me")
                                .font(Typography.bodyMedium)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .disabled(authService.isLoading)
                    
                    Spacer()
                    
                    Button(action: {
                        showForgotPassword = true
                    }) {
                        Text("Forgot Password?")
                            .font(Typography.bodyMedium)
                            .foregroundColor(.textLink)
                    }
                    .disabled(authService.isLoading)
                }
                
                // Error Message
                if let error = authService.authError,
                   !error.contains("email") && !error.contains("password") {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.error)
                        
                        Text(error)
                            .font(Typography.bodyMedium)
                            .foregroundColor(.error)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.errorLight)
                    .cornerRadius(8)
                }
                
                // Login Buttons
                VStack(spacing: 12) {
                    NBButton.primary(
                        "Sign In",
                        size: .large,
                        isLoading: authService.isLoading,
                        isDisabled: !isFormValid || authService.isLoading
                    ) {
                        Task {
                            await authService.login(email: email, password: password)
                        }
                    }
                    
                    // Biometric Login Button (if available)
                    if showBiometricLogin {
                        NBButton.secondary(
                            "Sign In with \(biometricType)",
                            size: .large,
                            isDisabled: authService.isLoading,
                            icon: biometricIcon
                        ) {
                            Task {
                                await authService.loginWithBiometrics()
                            }
                        }
                    }
                }
            }
            
            // Footer
            footerSection
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .shadowMedium, radius: 20, x: 0, y: -5)
        )
        .padding(.horizontal, 16)
    }
    
    // MARK: - Footer Section
    
    private var footerSection: some View {
        VStack(spacing: 16) {
            Divider()
                .background(Color.border)
            
            VStack(spacing: 12) {
                Text("Need help accessing your account?")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textSecondary)
                
                HStack(spacing: 24) {
                    Button(action: {
                        // Open support email
                        if let url = URL(string: "mailto:support@nbhealthservices.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "envelope")
                                .font(.system(size: 20))
                                .foregroundColor(.teal500)
                            
                            Text("Email Support")
                                .font(Typography.captionSmall)
                                .foregroundColor(.textLink)
                        }
                    }
                    
                    Button(action: {
                        // Open phone dialer
                        if let url = URL(string: "tel:+12272505330") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "phone")
                                .font(.system(size: 20))
                                .foregroundColor(.teal500)
                            
                            Text("Call Support")
                                .font(Typography.captionSmall)
                                .foregroundColor(.textLink)
                        }
                    }
                }
            }
            
            // App Version
            Text("Version \(AppInfo.version) (\(AppInfo.build))")
                .font(Typography.captionSmall)
                .foregroundColor(.textTertiary)
        }
        .padding(.top, 24)
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        email.contains("@") && 
        email.contains(".")
    }
    
    private var biometricType: String {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "Biometric"
        }
        
        switch context.biometryType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "Biometric"
        }
    }
    
    private var biometricIcon: String {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "touchid"
        }
        
        switch context.biometryType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "touchid"
        }
    }
    
    // MARK: - Helper Methods
    
    private func checkBiometricAvailability() {
        Task {
            showBiometricLogin = await authService.isBiometricAuthenticationAvailable()
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.easeInOut(duration: 0.3)) {
                    keyboardHeight = keyboardFrame.height
                }
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                keyboardHeight = 0
            }
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
}

// MARK: - Forgot Password View

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    @State private var email = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.teal500)
                    
                    Text("Reset Password")
                        .font(Typography.heading2)
                        .foregroundColor(.textPrimary)
                    
                    Text("Enter your email address and we'll send you a link to reset your password.")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                NBInputField.email(
                    label: "Email Address",
                    text: $email,
                    isRequired: true,
                    isDisabled: authService.isLoading
                )
                
                if let error = authService.authError {
                    Text(error)
                        .font(Typography.bodyMedium)
                        .foregroundColor(.error)
                        .multilineTextAlignment(.center)
                }
                
                if showSuccess {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.success)
                        
                        Text("Reset link sent!")
                            .font(Typography.bodyMedium)
                            .foregroundColor(.success)
                        
                        Text("Check your email for password reset instructions.")
                            .font(Typography.bodySmall)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 16)
                }
                
                VStack(spacing: 12) {
                    NBButton.primary(
                        showSuccess ? "Done" : "Send Reset Link",
                        size: .large,
                        isLoading: authService.isLoading,
                        isDisabled: email.isEmpty || authService.isLoading
                    ) {
                        if showSuccess {
                            dismiss()
                        } else {
                            Task {
                                let success = await authService.requestPasswordReset(email: email)
                                if success {
                                    showSuccess = true
                                }
                            }
                        }
                    }
                    
                    if !showSuccess {
                        NBButton.secondary(
                            "Cancel",
                            size: .large,
                            isDisabled: authService.isLoading
                        ) {
                            dismiss()
                        }
                    }
                }
                
                Spacer()
            }
            .padding(24)
            .navigationTitle("Forgot Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
#endif