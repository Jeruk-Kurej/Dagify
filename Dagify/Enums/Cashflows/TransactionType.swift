//
//  TransactionType.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Foundation

/// Menentukan jenis mutasi transaksi keuangan di dalam sistem Kasir dan Arus Kas.
enum TransactionType: String, Codable, CaseIterable {
    case income = "Pemasukan"
    case expense = "Pengeluaran"
}
