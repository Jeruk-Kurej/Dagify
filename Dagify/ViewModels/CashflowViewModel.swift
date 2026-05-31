//
//  CashflowViewModel.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
class CashflowViewModel {
    var records: [FinancialRecord] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var selectedPeriod: ChartPeriod = .bulanan
    var generatedPDFURL: URL? = nil

    var totalIncome: Double { records.filter { $0.type == .income }.reduce(0) { $0 + $1.amount } }
    var totalExpense: Double { records.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount } }
    var netProfit: Double { totalIncome - totalExpense }

    var chartData: [(date: Date, income: Double, expense: Double)] {
        var dict: [Date: (income: Double, expense: Double)] = [:]
        let calendar = Calendar.current
        
        for record in records {
            let keyDate: Date
            switch selectedPeriod {
            case .harian: keyDate = calendar.startOfDay(for: record.timestamp)
            case .bulanan: keyDate = calendar.date(from: calendar.dateComponents([.year, .month], from: record.timestamp)) ?? record.timestamp
            case .tahunan: keyDate = calendar.date(from: calendar.dateComponents([.year], from: record.timestamp)) ?? record.timestamp
            }
            
            let current = dict[keyDate] ?? (0, 0)
            if record.type == .income { dict[keyDate] = (current.income + record.amount, current.expense) }
            else { dict[keyDate] = (current.income, current.expense + record.amount) }
        }
        
        let sortedKeys = dict.keys.sorted()
        return sortedKeys.map { (date: $0, income: dict[$0]!.income, expense: dict[$0]!.expense) }
    }

    var groupedRecordsByMonth: [(month: String, records: [FinancialRecord])] {
        let dict = Dictionary(grouping: records) { record -> String in
            let formatter = DateFormatter(); formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: record.timestamp)
        }
        return dict.map { (month: $0.key, records: $0.value) }.sorted { $0.month > $1.month }
    }

    private let cashProtocol: CashflowProtocol
    init(cashProtocol: CashflowProtocol) { self.cashProtocol = cashProtocol }

    func loadRecords(branchId: String) async {
        isLoading = true
        records = (try? await cashProtocol.fetchRecords(for: branchId)) ?? []
        isLoading = false
    }

    func addTransaction(record: FinancialRecord, branchId: String) async {
        isLoading = true; _ = try? await cashProtocol.addRecord(record)
        await loadRecords(branchId: branchId); isLoading = false
    }

    func deleteTransaction(recordId: String, branchId: String) async {
        isLoading = true; _ = try? await cashProtocol.deleteRecord(id: recordId)
        await loadRecords(branchId: branchId); isLoading = false
    }
    
    func generateFinancialReport(branchId: String) {
        let template = CashflowPDFTemplate(totalIncome: totalIncome, totalExpense: totalExpense, netProfit: netProfit, branchId: branchId)
        self.generatedPDFURL = PDFGeneratorService.renderViewToPDF(view: template, filename: "Laporan_Cashflow_\(branchId)_\(Int(Date().timeIntervalSince1970))")
    }
}
