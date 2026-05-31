//
//  CashflowViewModel.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Foundation
import Observation

enum CashflowPeriod: String, CaseIterable {
    case harian = "Harian"
    case bulanan = "Bulan"
    case tahunan = "Tahun"
}

@MainActor
@Observable
class CashflowViewModel {
    var records: [FinancialRecord] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var selectedPeriod: CashflowPeriod = .bulanan

    var totalIncome: Double { records.filter { $0.type == .income }.reduce(0) { $0 + $1.amount } }
    var totalExpense: Double { records.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount } }
    var netProfit: Double { totalIncome - totalExpense }

    var chartData: [(period: String, income: Double, expense: Double)] {
        var dict: [String: (income: Double, expense: Double)] = [:]
        let formatter = DateFormatter()
        
        switch selectedPeriod {
        case .harian: formatter.dateFormat = "dd MMM"
        case .bulanan: formatter.dateFormat = "MMM yy"
        case .tahunan: formatter.dateFormat = "yyyy"
        }
        
        for record in records {
            let key = formatter.string(from: record.timestamp)
            let current = dict[key] ?? (income: 0, expense: 0)
            if record.type == .income {
                dict[key] = (income: current.income + record.amount, expense: current.expense)
            } else {
                dict[key] = (income: current.income, expense: current.expense + record.amount)
            }
        }
        
        let sortedKeys = dict.keys.sorted {
            guard let d1 = formatter.date(from: $0), let d2 = formatter.date(from: $1) else { return false }
            return d1 < d2
        }
        return sortedKeys.map { (period: $0, income: dict[$0]!.income, expense: dict[$0]!.expense) }
    }

    var groupedRecordsByMonth: [(month: String, records: [FinancialRecord])] {
        let dict = Dictionary(grouping: records) { record -> String in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: record.timestamp)
        }
        return dict.map { (month: $0.key, records: $0.value) }.sorted { $0.month > $1.month }
    }

    private let cashProtocol: CashflowProtocol

    init(cashProtocol: CashflowProtocol) {
        self.cashProtocol = cashProtocol
    }

    func loadRecords(branchId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            records = try await cashProtocol.fetchRecords(for: branchId)
        } catch {
            errorMessage = "Gagal memuat data keuangan."
        }
        isLoading = false
    }

    func addTransaction(record: FinancialRecord, branchId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await cashProtocol.addRecord(record)
            await loadRecords(branchId: branchId)
        } catch {
            errorMessage = "Gagal menyimpan transaksi."
        }
        isLoading = false
    }

    func deleteTransaction(recordId: String, branchId: String) async {
        isLoading = true
        do {
            _ = try await cashProtocol.deleteRecord(id: recordId)
            await loadRecords(branchId: branchId)
        } catch {
            errorMessage = "Gagal menghapus transaksi."
        }
        isLoading = false
    }
}
