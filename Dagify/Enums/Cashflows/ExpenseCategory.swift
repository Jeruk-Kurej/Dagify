//
//  ExpenseCategory.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//
enum ExpenseCategory: String, Codable, Equatable, CaseIterable, Identifiable {
    case cogs = "COGS (HPP)"
    case operational = "Operational (Sewa, Gaji, dll)"
    case incidental = "Incidental (Tak Terduga)"
    case none = "Pendapatan Umum"
    var id: String { self.rawValue }
}
