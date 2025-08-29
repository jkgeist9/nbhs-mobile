//
//  Typography.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

// MARK: - Typography System

struct Typography {
    
    // MARK: - Font Families
    
    static let sans = "Inter"
    static let display = "Lexend"
    static let merriweather = "Merriweather"
    static let montserrat = "Montserrat"
    
    // MARK: - Font Weights
    
    enum FontWeight {
        case thin
        case light
        case regular
        case medium
        case semibold
        case bold
        case heavy
        case black
        
        var weight: Font.Weight {
            switch self {
            case .thin: return .thin
            case .light: return .light
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            case .heavy: return .heavy
            case .black: return .black
            }
        }
        
        var name: String {
            switch self {
            case .thin: return "Thin"
            case .light: return "Light"
            case .regular: return "Regular"
            case .medium: return "Medium"
            case .semibold: return "SemiBold"
            case .bold: return "Bold"
            case .heavy: return "Heavy"
            case .black: return "Black"
            }
        }
    }
    
    // MARK: - Display Fonts (Montserrat)
    
    static let display9xl = Font.montserrat(128, weight: .bold)               // 8rem
    static let display8xl = Font.montserrat(96, weight: .bold)                // 6rem
    static let display7xl = Font.montserrat(72, weight: .bold)                // 4.5rem
    static let display6xl = Font.montserrat(60, weight: .bold)                // 3.75rem
    static let display5xl = Font.montserrat(48, weight: .bold)                // 3rem
    static let display4xl = Font.montserrat(40, weight: .bold)                // 2.5rem
    static let display3xl = Font.montserrat(32, weight: .bold)                // 2rem
    static let display2xl = Font.montserrat(24, weight: .bold)                // 1.5rem
    static let displayXl = Font.montserrat(20, weight: .bold)                 // 1.25rem
    static let displayLg = Font.montserrat(18, weight: .bold)                 // 1.125rem
    
    // MARK: - Heading Fonts (Montserrat)
    
    static let heading1 = Font.montserrat(32, weight: .bold)                  // H1
    static let heading2 = Font.montserrat(28, weight: .bold)                  // H2
    static let heading3 = Font.montserrat(24, weight: .semibold)              // H3
    static let heading4 = Font.montserrat(20, weight: .semibold)              // H4
    static let heading5 = Font.montserrat(18, weight: .medium)                // H5
    static let heading6 = Font.montserrat(16, weight: .medium)                // H6
    
    // MARK: - Body Text (Montserrat)
    
    static let bodyXl = Font.montserrat(20, weight: .regular)                 // 1.25rem
    static let bodyLarge = Font.montserrat(18, weight: .regular)              // 1.125rem
    static let body = Font.montserrat(16, weight: .regular)                   // 1rem - Base size
    static let bodyMedium = Font.montserrat(14, weight: .regular)             // 0.875rem
    static let bodySmall = Font.montserrat(12, weight: .regular)              // 0.75rem
    
    // MARK: - Label Text (Montserrat)
    
    static let labelLarge = Font.montserrat(16, weight: .medium)              
    static let label = Font.montserrat(14, weight: .medium)                   
    static let labelSmall = Font.montserrat(12, weight: .medium)              
    static let labelTiny = Font.montserrat(10, weight: .medium)        
    
    // MARK: - Caption Text (Montserrat)
    
    static let caption = Font.montserrat(12, weight: .regular)                
    static let captionSmall = Font.montserrat(10, weight: .regular)    
    
    // MARK: - Button Text (Montserrat)
    
    static let buttonLarge = Font.montserrat(16, weight: .semibold)           
    static let button = Font.montserrat(14, weight: .semibold)                
    static let buttonSmall = Font.montserrat(12, weight: .semibold)    
    
    // MARK: - Specialized Fonts
    
    static let code = Font.system(.body, design: .monospaced)
    static let tabular = Font.system(.body, design: .monospaced)
    
    // MARK: - Line Heights (Matching Tailwind CSS)
    
    enum LineHeight: CGFloat {
        case tight = 1.25
        case normal = 1.5
        case relaxed = 1.625
        case loose = 2.0
    }
    
    // MARK: - Font Loading Test
    
    static func testFontLoading() {
        let fontNames = [
            "Montserrat-Regular",
            "Montserrat-Medium", 
            "Montserrat-SemiBold",
            "Montserrat-Bold",
            "Merriweather-Regular",
            "Merriweather-Bold"
        ]
        
        print("=== Font Loading Test ===")
        for fontName in fontNames {
            let font = UIFont(name: fontName, size: 16)
            if font != nil {
                print("✅ \(fontName) loaded successfully")
            } else {
                print("❌ \(fontName) failed to load")
            }
        }
        print("=== End Font Test ===")
    }
}

// MARK: - Font Extensions

extension Font {
    static func inter(_ size: CGFloat, weight: Typography.FontWeight = .regular) -> Font {
        Font.custom(Typography.sans + "-" + weight.name, size: size)
    }
    
    static func lexend(_ size: CGFloat, weight: Typography.FontWeight = .regular) -> Font {
        Font.custom(Typography.display + "-" + weight.name, size: size)
    }
    
    static func merriweather(_ size: CGFloat, weight: Typography.FontWeight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .bold: fontName = "Merriweather-Bold"
        default: fontName = "Merriweather-Regular"
        }
        return Font.custom(fontName, size: size)
    }
    
    static func montserrat(_ size: CGFloat, weight: Typography.FontWeight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .regular: fontName = "Montserrat-Regular"
        case .medium: fontName = "Montserrat-Medium"
        case .semibold: fontName = "Montserrat-SemiBold"
        case .bold: fontName = "Montserrat-Bold"
        default: fontName = "Montserrat-Regular"
        }
        return Font.custom(fontName, size: size)
    }
}

// MARK: - Text Style Modifiers

struct TextStyleModifier: ViewModifier {
    let font: Font
    let color: Color
    let lineHeight: Typography.LineHeight?
    
    init(font: Font, color: Color = .textPrimary, lineHeight: Typography.LineHeight? = nil) {
        self.font = font
        self.color = color
        self.lineHeight = lineHeight
    }
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
            .lineSpacing(lineHeight?.rawValue ?? Typography.LineHeight.normal.rawValue)
    }
}

extension Text {
    // MARK: - Display Styles
    
    func displayStyle(_ size: DisplaySize = .xl, color: Color = .textPrimary) -> some View {
        let font: Font = {
            switch size {
            case .xs: return Typography.displayLg
            case .sm: return Typography.displayXl
            case .md: return Typography.display2xl
            case .lg: return Typography.display3xl
            case .xl: return Typography.display4xl
            case .xxl: return Typography.display5xl
            case .xxxl: return Typography.display6xl
            }
        }()
        
        return modifier(TextStyleModifier(font: font, color: color, lineHeight: .tight))
    }
    
    // MARK: - Heading Styles
    
    func headingStyle(_ level: HeadingLevel = .h3, color: Color = .textPrimary) -> some View {
        let font: Font = {
            switch level {
            case .h1: return Typography.heading1
            case .h2: return Typography.heading2
            case .h3: return Typography.heading3
            case .h4: return Typography.heading4
            case .h5: return Typography.heading5
            case .h6: return Typography.heading6
            }
        }()
        
        return modifier(TextStyleModifier(font: font, color: color, lineHeight: .tight))
    }
    
    // MARK: - Body Styles
    
    func bodyStyle(_ size: BodySize = .regular, color: Color = .textPrimary) -> some View {
        let font: Font = {
            switch size {
            case .small: return Typography.bodySmall
            case .medium: return Typography.bodyMedium
            case .regular: return Typography.body
            case .large: return Typography.bodyLarge
            case .xl: return Typography.bodyXl
            }
        }()
        
        return modifier(TextStyleModifier(font: font, color: color, lineHeight: .normal))
    }
    
    // MARK: - Label Styles
    
    func labelStyle(_ size: LabelSize = .regular, color: Color = .textSecondary) -> some View {
        let font: Font = {
            switch size {
            case .tiny: return Typography.labelTiny
            case .small: return Typography.labelSmall
            case .regular: return Typography.label
            case .large: return Typography.labelLarge
            }
        }()
        
        return modifier(TextStyleModifier(font: font, color: color))
    }
    
    // MARK: - Caption Styles
    
    func captionStyle(_ size: CaptionSize = .regular, color: Color = .textTertiary) -> some View {
        let font: Font = {
            switch size {
            case .small: return Typography.captionSmall
            case .regular: return Typography.caption
            }
        }()
        
        return modifier(TextStyleModifier(font: font, color: color))
    }
    
    // MARK: - Button Styles
    
    func buttonStyle(_ size: ButtonTextSize = .regular, color: Color = .textInverse) -> some View {
        let font: Font = {
            switch size {
            case .small: return Typography.buttonSmall
            case .regular: return Typography.button
            case .large: return Typography.buttonLarge
            }
        }()
        
        return modifier(TextStyleModifier(font: font, color: color))
    }
}

// MARK: - Size Enums

enum DisplaySize {
    case xs, sm, md, lg, xl, xxl, xxxl
}

enum HeadingLevel {
    case h1, h2, h3, h4, h5, h6
}

enum BodySize {
    case small, medium, regular, large, xl
}

enum LabelSize {
    case tiny, small, regular, large
}

enum CaptionSize {
    case small, regular
}

enum ButtonTextSize {
    case small, regular, large
}

// MARK: - Typography Preview

#if DEBUG
struct TypographyPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Display Styles")
                        .headingStyle(.h2)
                    
                    Text("Display XL - Hero Headline")
                        .displayStyle(.xl)
                    
                    Text("Display Large - Section Header")
                        .displayStyle(.lg)
                    
                    Text("Display Medium - Card Title")
                        .displayStyle(.md)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Heading Styles")
                        .headingStyle(.h2)
                    
                    Text("Heading 1 - Page Title")
                        .headingStyle(.h1)
                    
                    Text("Heading 2 - Section Title")
                        .headingStyle(.h2)
                    
                    Text("Heading 3 - Subsection Title")
                        .headingStyle(.h3)
                    
                    Text("Heading 4 - Component Title")
                        .headingStyle(.h4)
                    
                    Text("Heading 5 - Small Header")
                        .headingStyle(.h5)
                    
                    Text("Heading 6 - Tiny Header")
                        .headingStyle(.h6)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Body Text Styles")
                        .headingStyle(.h2)
                    
                    Text("Body XL - Large body text for important content.")
                        .bodyStyle(.xl)
                    
                    Text("Body Large - Emphasized body text for readability.")
                        .bodyStyle(.large)
                    
                    Text("Body Regular - Standard body text for most content.")
                        .bodyStyle(.regular)
                    
                    Text("Body Medium - Compact body text for dense layouts.")
                        .bodyStyle(.medium)
                    
                    Text("Body Small - Small body text for secondary content.")
                        .bodyStyle(.small)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Label & Caption Styles")
                        .headingStyle(.h2)
                    
                    Text("Label Large - Form labels")
                        .labelStyle(.large)
                    
                    Text("Label Regular - Standard labels")
                        .labelStyle(.regular)
                    
                    Text("Label Small - Compact labels")
                        .labelStyle(.small)
                    
                    Text("Caption - Supplementary text")
                        .captionStyle(.regular)
                    
                    Text("Caption Small - Fine print")
                        .captionStyle(.small)
                }
            }
            .padding()
        }
    }
}

struct TypographyPreview_Previews: PreviewProvider {
    static var previews: some View {
        TypographyPreview()
    }
}
#endif