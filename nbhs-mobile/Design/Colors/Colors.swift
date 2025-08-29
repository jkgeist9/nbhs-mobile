//
//  Colors.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI
import UIKit

extension Color {
    
    // MARK: - Primary Brand Colors (Teal - matching Tailwind)
    
    static let teal50 = Color(hex: "#F0FDFA")
    static let teal100 = Color(hex: "#CCFBF1")
    static let teal200 = Color(hex: "#99F6E4")
    static let teal300 = Color(hex: "#5EEAD4")
    static let teal400 = Color(hex: "#2DD4BF")
    static let teal500 = Color(hex: "#14B8A6")  // Primary brand color
    static let teal600 = Color(hex: "#0D9488")  // Primary hover
    static let teal700 = Color(hex: "#0F766E")
    static let teal800 = Color(hex: "#115E59")
    static let teal900 = Color(hex: "#134E4A")
    static let teal950 = Color(hex: "#042F2E")
    
    // MARK: - Semantic Colors
    
    static let primary = teal500
    static let primaryHover = teal600
    static let primaryPressed = teal700
    static let primaryDisabled = Color(hex: "#9CA3AF")
    
    // MARK: - Gray Scale (Matching Tailwind)
    
    static let gray50 = Color(hex: "#F9FAFB")
    static let gray100 = Color(hex: "#F3F4F6")
    static let gray200 = Color(hex: "#E5E7EB")
    static let gray300 = Color(hex: "#D1D5DB")
    static let gray400 = Color(hex: "#9CA3AF")
    static let gray500 = Color(hex: "#6B7280")
    static let gray600 = Color(hex: "#4B5563")
    static let gray700 = Color(hex: "#374151")
    static let gray800 = Color(hex: "#1F2937")
    static let gray900 = Color(hex: "#111827")
    static let gray950 = Color(hex: "#030712")
    
    // MARK: - Status Colors
    
    static let success = Color(hex: "#10B981")      // Green-500
    static let successLight = Color(hex: "#D1FAE5") // Green-100
    static let successDark = Color(hex: "#047857")   // Green-700
    
    static let warning = Color(hex: "#F59E0B")      // Amber-500
    static let warningLight = Color(hex: "#FEF3C7") // Amber-100
    static let warningDark = Color(hex: "#D97706")   // Amber-600
    
    static let error = Color(hex: "#EF4444")        // Red-500
    static let errorLight = Color(hex: "#FEE2E2")   // Red-100
    static let errorDark = Color(hex: "#DC2626")     // Red-600
    
    static let info = Color(hex: "#3B82F6")         // Blue-500
    static let infoLight = Color(hex: "#DBEAFE")    // Blue-100
    static let infoDark = Color(hex: "#2563EB")      // Blue-600
    
    // MARK: - Background Colors
    
    static let background = Color(hex: "#FFFFFF")
    static let backgroundSecondary = gray50
    static let backgroundTertiary = gray100
    
    // MARK: - Surface Colors
    
    static let surface = Color(hex: "#FFFFFF")
    static let surfaceSecondary = gray50
    static let overlay = Color.black.opacity(0.5)
    
    // MARK: - Border Colors
    
    static let border = gray200
    static let borderFocus = teal500
    static let borderError = error
    static let borderSuccess = success
    
    // MARK: - Text Colors
    
    static let textPrimary = gray900
    static let textSecondary = gray600
    static let textTertiary = gray500
    static let textPlaceholder = gray400
    static let textInverse = Color(hex: "#FFFFFF")
    static let textLink = teal600
    static let textLinkHover = teal700
    
    // MARK: - Button Colors
    
    static let buttonPrimary = teal500
    static let buttonPrimaryHover = teal600
    static let buttonPrimaryPressed = teal700
    static let buttonPrimaryDisabled = gray300
    
    static let buttonSecondary = Color(hex: "#FFFFFF")
    static let buttonSecondaryHover = gray50
    static let buttonSecondaryPressed = gray100
    static let buttonSecondaryBorder = gray300
    
    static let buttonDestructive = error
    static let buttonDestructiveHover = errorDark
    
    // MARK: - Navigation Colors
    
    static let navigationBackground = Color(hex: "#FFFFFF")
    static let navigationBorder = gray200
    static let navigationActive = teal50
    static let navigationActiveText = teal700
    static let navigationInactive = gray600
    
    // MARK: - Form Colors
    
    static let inputBackground = Color(hex: "#FFFFFF")
    static let inputBorder = gray300
    static let inputBorderFocus = teal500
    static let inputBorderError = error
    static let inputPlaceholder = gray400
    
    // MARK: - Shadow Colors
    
    static let shadowLight = Color.black.opacity(0.05)
    static let shadowMedium = Color.black.opacity(0.1)
    static let shadowHeavy = Color.black.opacity(0.25)
}

// MARK: - Color Helper

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Dynamic Colors (Light/Dark Mode Support)

extension Color {
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
    
    // Dark mode variants
    static let adaptiveBackground = adaptive(
        light: .background,
        dark: .gray900
    )
    
    static let adaptiveTextPrimary = adaptive(
        light: .textPrimary,
        dark: .gray100
    )
    
    static let adaptiveTextSecondary = adaptive(
        light: .textSecondary,
        dark: .gray400
    )
    
    static let adaptiveSurface = adaptive(
        light: .surface,
        dark: .gray800
    )
    
    static let adaptiveBorder = adaptive(
        light: .border,
        dark: .gray700
    )
}

// MARK: - Color Previews

#if DEBUG
struct ColorsPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                colorSection("Primary Colors", colors: [
                    ("Teal 500", .teal500),
                    ("Teal 600", .teal600),
                    ("Primary", .primary),
                    ("Primary Hover", .primaryHover)
                ])
                
                colorSection("Status Colors", colors: [
                    ("Success", .success),
                    ("Warning", .warning),
                    ("Error", .error),
                    ("Info", .info)
                ])
                
                colorSection("Gray Scale", colors: [
                    ("Gray 100", .gray100),
                    ("Gray 300", .gray300),
                    ("Gray 500", .gray500),
                    ("Gray 700", .gray700),
                    ("Gray 900", .gray900)
                ])
                
                colorSection("Text Colors", colors: [
                    ("Text Primary", .textPrimary),
                    ("Text Secondary", .textSecondary),
                    ("Text Link", .textLink)
                ])
            }
            .padding()
        }
    }
    
    private func colorSection(_ title: String, colors: [(String, Color)]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(colors, id: \.0) { name, color in
                    HStack {
                        Rectangle()
                            .fill(color)
                            .frame(width: 30, height: 30)
                            .cornerRadius(6)
                        
                        Text(name)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

struct ColorsPreview_Previews: PreviewProvider {
    static var previews: some View {
        ColorsPreview()
    }
}
#endif