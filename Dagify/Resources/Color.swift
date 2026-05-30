//
//  Color.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 30/05/26.
//

import SwiftUI

extension Color {
    // MARK: - Warna Utama & Brand
    static let themePrimary = Color(red: 0/255, green: 163/255, blue: 163/255)       // #00A3A3
    static let themeHighlight = Color(red: 77/255, green: 189/255, blue: 189/255)    // #4DBDBD
    
    // MARK: - Warna Semantik & Status (Alerts)
    static let themeSuccess = Color(red: 16/255, green: 185/255, blue: 129/255)      // #10B981
    static let themeWarning = Color(red: 245/255, green: 158/255, blue: 11/255)      // #F59E0B
    static let themeDestructive = Color(red: 239/255, green: 68/255, blue: 68/255)   // #EF4444
    
    // MARK: - Warna Netral & Permukaan
    static let themeBgMain = Color(red: 249/255, green: 250/255, blue: 251/255)      // #F9FAFB
    static let themeBgSecondary = Color(red: 255/255, green: 255/255, blue: 255/255) // #FFFFFF
    static let themeTextPrimary = Color(red: 17/255, green: 24/255, blue: 39/255)    // #111827
    static let themeTextSecondary = Color(red: 107/255, green: 114/255, blue: 128/255) // #6B7280
    static let themeBorder = Color(red: 229/255, green: 231/255, blue: 235/255)      // #E5E7EB
}
