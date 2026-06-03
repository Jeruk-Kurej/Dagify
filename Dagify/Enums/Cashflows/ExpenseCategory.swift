//
//  ExpenseCategory.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//
import Foundation

/// Kategori spesifik untuk mengelompokkan jenis pengeluaran bisnis.
enum ExpenseCategory: String, Codable, CaseIterable {
    case cogs = "HPP (Bahan Baku)"
    case operational = "Operasional"
    case marketing = "Pemasaran"
    case payroll = "Gaji Karyawan"
    case none = "Lainnya"
}

