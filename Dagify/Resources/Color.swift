//
//  Color.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 30/05/26.
//

import SwiftUI

// MARK: - Color.swift
extension Color {
    static let dagifyPrimary = Color(hex: "#00A3A3")
    static let dagifyHighlight = Color(hex: "#4DBDBD")
    static let dagifySuccess = Color(hex: "#10B981")
    static let dagifyWarning = Color(hex: "#F59E0B")
    static let dagifyDestructive = Color(hex: "#EF4444")
    static let dagifyMainBG = Color(hex: "#F9FAFB")
    static let dagifySecBG = Color(hex: "#FFFFFF")
    static let dagifyTextPrimary = Color(hex: "#111827")
    static let dagifyTextSec = Color(hex: "#6B7280")
    static let dagifyBorder = Color(hex: "#E5E7EB")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

