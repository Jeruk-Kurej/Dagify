//
//  ExpenseCategory.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//
enum ExpenseCategory: String, Codable, Equatable {
    case cogs = "COGS (HPP)"
    case operational = "Operational (Listrik, Sewa, Gaji)"
    case incidental = "Incidental (Tak Terduga)"
    case none = "None"
}
