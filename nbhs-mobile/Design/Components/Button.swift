//
//  Button.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

// MARK: - Button Styles

enum NBButtonStyle {
    case primary
    case secondary
    case destructive
    case ghost
    case link
    
    var backgroundColor: Color {
        switch self {
        case .primary: return .buttonPrimary
        case .secondary: return .buttonSecondary
        case .destructive: return .buttonDestructive
        case .ghost: return .clear
        case .link: return .clear
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary: return .textInverse
        case .secondary: return .textPrimary
        case .destructive: return .textInverse
        case .ghost: return .textPrimary
        case .link: return .textLink
        }
    }
    
    var borderColor: Color {
        switch self {
        case .primary: return .clear
        case .secondary: return .buttonSecondaryBorder
        case .destructive: return .clear
        case .ghost: return .border
        case .link: return .clear
        }
    }
    
    var hoverBackgroundColor: Color {
        switch self {
        case .primary: return .buttonPrimaryHover
        case .secondary: return .buttonSecondaryHover
        case .destructive: return .buttonDestructiveHover
        case .ghost: return .backgroundSecondary
        case .link: return .clear
        }
    }
    
    var pressedBackgroundColor: Color {
        switch self {
        case .primary: return .buttonPrimaryPressed
        case .secondary: return .buttonSecondaryPressed
        case .destructive: return .buttonDestructiveHover
        case .ghost: return .backgroundTertiary
        case .link: return .clear
        }
    }
}

enum NBButtonSize {
    case small
    case medium
    case large
    
    var height: CGFloat {
        switch self {
        case .small: return 32
        case .medium: return 40
        case .large: return 48
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 16
        case .large: return 20
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .small: return 6
        case .medium: return 8
        case .large: return 12
        }
    }
    
    var fontSize: ButtonTextSize {
        switch self {
        case .small: return .small
        case .medium: return .regular
        case .large: return .large
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small: return 6
        case .medium: return 8
        case .large: return 10
        }
    }
}

// MARK: - NBButton View

struct NBButton: View {
    let title: String
    let style: NBButtonStyle
    let size: NBButtonSize
    let isLoading: Bool
    let isDisabled: Bool
    let icon: String?
    let iconPosition: IconPosition
    let action: () -> Void
    
    @State private var isPressed = false
    
    enum IconPosition {
        case leading
        case trailing
    }
    
    init(
        _ title: String,
        style: NBButtonStyle = .primary,
        size: NBButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        icon: String? = nil,
        iconPosition: IconPosition = .leading,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.icon = icon
        self.iconPosition = iconPosition
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if !isDisabled && !isLoading {
                action()
            }
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                        .foregroundColor(currentForegroundColor)
                } else {
                    if let icon = icon, iconPosition == .leading {
                        Image(systemName: icon)
                            .font(.system(size: iconSize))
                    }
                    
                    Text(title)
                        .buttonStyle(size.fontSize, color: currentForegroundColor)
                        .lineLimit(1)
                    
                    if let icon = icon, iconPosition == .trailing {
                        Image(systemName: icon)
                            .font(.system(size: iconSize))
                    }
                }
            }
            .frame(minHeight: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(currentBackgroundColor)
            .cornerRadius(size.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(style.borderColor, lineWidth: style == .secondary || style == .ghost ? 1 : 0)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .opacity(isDisabled ? 0.6 : 1.0)
        }
        .disabled(isDisabled || isLoading)
        .onTapGesture {
            if !isDisabled && !isLoading {
                action()
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
    
    private var currentBackgroundColor: Color {
        if isDisabled {
            return .buttonPrimaryDisabled
        } else if isPressed {
            return style.pressedBackgroundColor
        } else {
            return style.backgroundColor
        }
    }
    
    private var currentForegroundColor: Color {
        if isDisabled && style == .primary {
            return .textInverse
        } else if isDisabled {
            return .textTertiary
        } else {
            return style.foregroundColor
        }
    }
    
    private var iconSize: CGFloat {
        switch size {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        }
    }
}

// MARK: - Convenience Initializers

extension NBButton {
    static func primary(
        _ title: String,
        size: NBButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        icon: String? = nil,
        iconPosition: IconPosition = .leading,
        action: @escaping () -> Void
    ) -> NBButton {
        NBButton(
            title,
            style: .primary,
            size: size,
            isLoading: isLoading,
            isDisabled: isDisabled,
            icon: icon,
            iconPosition: iconPosition,
            action: action
        )
    }
    
    static func secondary(
        _ title: String,
        size: NBButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        icon: String? = nil,
        iconPosition: IconPosition = .leading,
        action: @escaping () -> Void
    ) -> NBButton {
        NBButton(
            title,
            style: .secondary,
            size: size,
            isLoading: isLoading,
            isDisabled: isDisabled,
            icon: icon,
            iconPosition: iconPosition,
            action: action
        )
    }
    
    static func destructive(
        _ title: String,
        size: NBButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        icon: String? = nil,
        iconPosition: IconPosition = .leading,
        action: @escaping () -> Void
    ) -> NBButton {
        NBButton(
            title,
            style: .destructive,
            size: size,
            isLoading: isLoading,
            isDisabled: isDisabled,
            icon: icon,
            iconPosition: iconPosition,
            action: action
        )
    }
    
    static func ghost(
        _ title: String,
        size: NBButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        icon: String? = nil,
        iconPosition: IconPosition = .leading,
        action: @escaping () -> Void
    ) -> NBButton {
        NBButton(
            title,
            style: .ghost,
            size: size,
            isLoading: isLoading,
            isDisabled: isDisabled,
            icon: icon,
            iconPosition: iconPosition,
            action: action
        )
    }
    
    static func link(
        _ title: String,
        size: NBButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        icon: String? = nil,
        iconPosition: IconPosition = .leading,
        action: @escaping () -> Void
    ) -> NBButton {
        NBButton(
            title,
            style: .link,
            size: size,
            isLoading: isLoading,
            isDisabled: isDisabled,
            icon: icon,
            iconPosition: iconPosition,
            action: action
        )
    }
}

// MARK: - Button Previews

#if DEBUG
struct ButtonPreview: View {
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text("Button Styles")
                        .headingStyle(.h3)
                    
                    NBButton.primary("Primary Button") {}
                    NBButton.secondary("Secondary Button") {}
                    NBButton.destructive("Destructive Button") {}
                    NBButton.ghost("Ghost Button") {}
                    NBButton.link("Link Button") {}
                }
                
                VStack(spacing: 12) {
                    Text("Button Sizes")
                        .headingStyle(.h3)
                    
                    NBButton.primary("Small", size: .small) {}
                    NBButton.primary("Medium", size: .medium) {}
                    NBButton.primary("Large", size: .large) {}
                }
                
                VStack(spacing: 12) {
                    Text("Button States")
                        .headingStyle(.h3)
                    
                    NBButton.primary("Normal Button") {}
                    NBButton.primary("Loading Button", isLoading: true) {}
                    NBButton.primary("Disabled Button", isDisabled: true) {}
                }
                
                VStack(spacing: 12) {
                    Text("Buttons with Icons")
                        .headingStyle(.h3)
                    
                    NBButton.primary("Save", icon: "checkmark") {}
                    NBButton.secondary("Cancel", icon: "xmark") {}
                    NBButton.primary("Next", icon: "arrow.right", iconPosition: .trailing) {}
                    NBButton.ghost("Settings", icon: "gear") {}
                }
                
                VStack(spacing: 12) {
                    Text("Interactive Example")
                        .headingStyle(.h3)
                    
                    NBButton.primary(
                        isLoading ? "Loading..." : "Start Loading",
                        isLoading: isLoading
                    ) {
                        isLoading.toggle()
                        if isLoading {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isLoading = false
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct ButtonPreview_Previews: PreviewProvider {
    static var previews: some View {
        ButtonPreview()
    }
}
#endif