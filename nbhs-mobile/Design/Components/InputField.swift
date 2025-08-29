//
//  InputField.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

// MARK: - Input Field Types

enum NBInputType {
    case text
    case email
    case password
    case number
    case phone
    case url
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .text: return .default
        case .email: return .emailAddress
        case .password: return .default
        case .number: return .numberPad
        case .phone: return .phonePad
        case .url: return .URL
        }
    }
    
    var textContentType: UITextContentType? {
        switch self {
        case .text: return nil
        case .email: return .emailAddress
        case .password: return .password
        case .number: return nil
        case .phone: return .telephoneNumber
        case .url: return .URL
        }
    }
    
    var autocapitalization: UITextAutocapitalizationType {
        switch self {
        case .text: return .sentences
        case .email: return .none
        case .password: return .none
        case .number: return .none
        case .phone: return .none
        case .url: return .none
        }
    }
}

// MARK: - Input Field State

enum NBInputState {
    case normal
    case focused
    case error
    case success
    case disabled
    
    var borderColor: Color {
        switch self {
        case .normal: return .inputBorder
        case .focused: return .inputBorderFocus
        case .error: return .inputBorderError
        case .success: return .borderSuccess
        case .disabled: return .gray300
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .disabled: return .gray100
        default: return .inputBackground
        }
    }
}

// MARK: - NBInputField View

struct NBInputField: View {
    let label: String?
    let placeholder: String
    let type: NBInputType
    let helperText: String?
    let errorText: String?
    let successText: String?
    let isRequired: Bool
    let isDisabled: Bool
    let maxLength: Int?
    let leadingIcon: String?
    let trailingIcon: String?
    let onTrailingIconTap: (() -> Void)?
    
    @Binding var text: String
    @FocusState private var isFocused: Bool
    @State private var isSecure: Bool
    
    init(
        label: String? = nil,
        placeholder: String,
        text: Binding<String>,
        type: NBInputType = .text,
        helperText: String? = nil,
        errorText: String? = nil,
        successText: String? = nil,
        isRequired: Bool = false,
        isDisabled: Bool = false,
        leadingIcon: String? = nil,
        maxLength: Int? = nil,
        trailingIcon: String? = nil,
        onTrailingIconTap: (() -> Void)? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.type = type
        self.helperText = helperText
        self.errorText = errorText
        self.successText = successText
        self.isRequired = isRequired
        self.isDisabled = isDisabled
        self.maxLength = maxLength
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.onTrailingIconTap = onTrailingIconTap
        self._isSecure = State(initialValue: type == .password)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Label
            if let label = label {
                HStack(spacing: 4) {
                    Text(label)
                        .labelStyle(LabelSize.regular, color: currentState == .disabled ? .textTertiary : .textSecondary)
                    
                    if isRequired {
                        Text("*")
                            .labelStyle(LabelSize.regular, color: .error)
                    }
                }
            }
            
            // Input Container
            HStack(spacing: 12) {
                // Leading Icon
                if let leadingIcon = leadingIcon {
                    Image(systemName: leadingIcon)
                        .foregroundColor(.textTertiary)
                        .frame(width: 16, height: 16)
                }
                
                // Text Field
                if type == .password && isSecure {
                    SecureField(placeholder, text: $text)
                        .textFieldStyle(NBTextFieldStyle(state: currentState))
                        .focused($isFocused)
                        .disabled(isDisabled)
                        .textContentType(type.textContentType)
                        .autocapitalization(type.autocapitalization)
                        .onChange(of: text) { oldValue, newValue in
                            if let maxLength = maxLength, newValue.count > maxLength {
                                text = String(newValue.prefix(maxLength))
                            }
                        }
                } else {
                    TextField(placeholder, text: $text)
                        .textFieldStyle(NBTextFieldStyle(state: currentState))
                        .focused($isFocused)
                        .disabled(isDisabled)
                        .keyboardType(type.keyboardType)
                        .textContentType(type.textContentType)
                        .autocapitalization(type.autocapitalization)
                        .onChange(of: text) { oldValue, newValue in
                            if let maxLength = maxLength, newValue.count > maxLength {
                                text = String(newValue.prefix(maxLength))
                            }
                        }
                }
                
                // Trailing Icon or Password Toggle
                if type == .password {
                    Button(action: {
                        isSecure.toggle()
                    }) {
                        Image(systemName: isSecure ? "eye" : "eye.slash")
                            .foregroundColor(.textTertiary)
                            .frame(width: 16, height: 16)
                    }
                    .disabled(isDisabled)
                } else if let trailingIcon = trailingIcon {
                    Button(action: {
                        onTrailingIconTap?()
                    }) {
                        Image(systemName: trailingIcon)
                            .foregroundColor(.textTertiary)
                            .frame(width: 16, height: 16)
                    }
                    .disabled(isDisabled)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(currentState.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(currentState.borderColor, lineWidth: currentState == .focused ? 2 : 1)
            )
            .cornerRadius(8)
            
            // Helper/Error/Success Text
            if let errorText = errorText {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.caption)
                        .foregroundColor(.error)
                    Text(errorText)
                        .captionStyle(CaptionSize.regular, color: .error)
                }
            } else if let successText = successText {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(.success)
                    Text(successText)
                        .captionStyle(CaptionSize.regular, color: .success)
                }
            } else if let helperText = helperText {
                Text(helperText)
                    .captionStyle(CaptionSize.regular, color: .textTertiary)
            }
            
            // Character Count (if maxLength is set)
            if let maxLength = maxLength {
                HStack {
                    Spacer()
                    Text("\(text.count)/\(maxLength)")
                        .captionStyle(CaptionSize.small, color: text.count >= maxLength ? .error : .textTertiary)
                }
            }
        }
    }
    
    private var currentState: NBInputState {
        if isDisabled {
            return .disabled
        } else if errorText != nil {
            return .error
        } else if successText != nil {
            return .success
        } else if isFocused {
            return .focused
        } else {
            return .normal
        }
    }
}

// MARK: - Custom Text Field Style

struct NBTextFieldStyle: TextFieldStyle {
    let state: NBInputState
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(Typography.body)
            .foregroundColor(state == .disabled ? .textTertiary : .textPrimary)
    }
}

// MARK: - Convenience Initializers

extension NBInputField {
    static func email(
        label: String? = nil,
        placeholder: String = "Enter your email",
        text: Binding<String>,
        errorText: String? = nil,
        isRequired: Bool = false,
        isDisabled: Bool = false
    ) -> NBInputField {
        NBInputField(
            label: label,
            placeholder: placeholder,
            text: text,
            type: .email,
            errorText: errorText,
            isRequired: isRequired,
            isDisabled: isDisabled,
            leadingIcon: "envelope"
        )
    }
    
    static func password(
        label: String? = nil,
        placeholder: String = "Enter your password",
        text: Binding<String>,
        errorText: String? = nil,
        isRequired: Bool = false,
        isDisabled: Bool = false
    ) -> NBInputField {
        NBInputField(
            label: label,
            placeholder: placeholder,
            text: text,
            type: .password,
            errorText: errorText,
            isRequired: isRequired,
            isDisabled: isDisabled,
            leadingIcon: "lock"
        )
    }
    
    static func phone(
        label: String? = nil,
        placeholder: String = "Enter your phone number",
        text: Binding<String>,
        errorText: String? = nil,
        isRequired: Bool = false,
        isDisabled: Bool = false
    ) -> NBInputField {
        NBInputField(
            label: label,
            placeholder: placeholder,
            text: text,
            type: .phone,
            errorText: errorText,
            isRequired: isRequired,
            isDisabled: isDisabled,
            leadingIcon: "phone",
            maxLength: 14 // (XXX) XXX-XXXX format
        )
    }
    
    static func search(
        placeholder: String = "Search...",
        text: Binding<String>,
        onTrailingIconTap: @escaping () -> Void = {}
    ) -> NBInputField {
        NBInputField(
            placeholder: placeholder,
            text: text,
            type: .text,
            leadingIcon: "magnifyingglass",
            trailingIcon: text.wrappedValue.isEmpty ? nil : "xmark.circle.fill",
            onTrailingIconTap: {
                text.wrappedValue = ""
                onTrailingIconTap()
            }
        )
    }
}

// MARK: - Input Field Previews

#if DEBUG
struct InputFieldPreview: View {
    @State private var email = ""
    @State private var password = ""
    @State private var phone = ""
    @State private var search = ""
    @State private var textWithError = ""
    @State private var textWithSuccess = "Valid input"
    @State private var disabledText = "Disabled"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Input Field Examples")
                        .headingStyle(.h2)
                    
                    NBInputField.email(
                        label: "Email Address",
                        text: $email,
                        isRequired: true
                    )
                    
                    NBInputField.password(
                        label: "Password",
                        text: $password,
                        isRequired: true
                    )
                    
                    NBInputField.phone(
                        label: "Phone Number",
                        text: $phone
                    )
                    
                    NBInputField.search(
                        placeholder: "Search patients...",
                        text: $search
                    )
                }
                
                VStack(spacing: 16) {
                    Text("Input States")
                        .headingStyle(.h3)
                    
                    NBInputField(
                        label: "Text with Error",
                        placeholder: "Enter text",
                        text: $textWithError,
                        errorText: "This field is required",
                        isRequired: true
                    )
                    
                    NBInputField(
                        label: "Text with Success",
                        placeholder: "Enter text",
                        text: $textWithSuccess,
                        successText: "Looks good!"
                    )
                    
                    NBInputField(
                        label: "Disabled Input",
                        placeholder: "Cannot edit",
                        text: $disabledText,
                        helperText: "This field is disabled",
                        isDisabled: true
                    )
                    
                    NBInputField(
                        label: "Text with Character Limit",
                        placeholder: "Max 50 characters",
                        text: $search,
                        helperText: "Brief description only",
                        maxLength: 50
                    )
                }
            }
            .padding()
        }
    }
}

struct InputFieldPreview_Previews: PreviewProvider {
    static var previews: some View {
        InputFieldPreview()
    }
}
#endif