//
//  CashflowViewModel.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class CashflowViewModel {
    private let repository: CashflowProtocol
    private let pdfService = PDFGeneratorService()
    
    var records: [FinancialRecord] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    var totalIncome: Double = 0.0
    var totalExpense: Double = 0.0
    var netProfit: Double = 0.0
    var chartData: [(date: Date, income: Double, expense: Double)] = []
    var groupedRecords: [(month: String, records: [FinancialRecord])] = []
    var generatedPDFURL: URL? = nil
    
    var selectedPeriod: ChartPeriod = .bulanan { didSet { Task { await recalculateCharts() } } }
    
    init(repository: CashflowProtocol) { self.repository = repository }
    
    func loadData(branchId: String, context: ModelContext) {
        isLoading = true
        do {
            records = try repository.fetchLocalRecords(branchId: branchId, context: context)
            Task { await computeAnalytics() }
            Task { try? await repository.syncUnsyncedRecords(context: context) }
        } catch { errorMessage = "Gagal memuat data lokal." }
        isLoading = false
    }
    
    func addTransaction(amount: Double, type: TransactionType, category: ExpenseCategory, notes: String, branchId: String, context: ModelContext) async {
        let newRecord = FinancialRecord(branchId: branchId, amount: amount, type: type, category: category, notes: notes)
        do {
            try await repository.addRecord(newRecord, context: context)
            loadData(branchId: branchId, context: context)
        } catch { errorMessage = "Gagal menyimpan transaksi." }
    }
    
    func deleteTransaction(_ record: FinancialRecord, branchId: String, context: ModelContext) async {
        do {
            try await repository.deleteRecord(record, context: context)
            loadData(branchId: branchId, context: context)
        } catch { errorMessage = "Gagal menghapus data." }
    }
    
    func requestPDFGeneration(branchId: String) {
        generatedPDFURL = pdfService.generatePDF(for: branchId, income: totalIncome, expense: totalExpense, profit: netProfit)
    }
    
    private func computeAnalytics() async {
        let safeRecords = records
        let income = safeRecords.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let expense = safeRecords.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        
        let formatter = DateFormatter(); formatter.dateFormat = "MMMM yyyy"
        let dict = Dictionary(grouping: safeRecords) { formatter.string(from: $0.timestamp) }
        
        self.totalIncome = income
        self.totalExpense = expense
        self.netProfit = income - expense
        self.groupedRecords = dict.map { (month: $0.key, records: $0.value) }.sorted { $0.month > $1.month }
        await recalculateCharts()
    }
    
    private func recalculateCharts() async {
        let safeRecords = records; let period = selectedPeriod
        Task.detached {
            var dict: [Date: (income: Double, expense: Double)] = [:]
            let calendar = Calendar.current
            for record in safeRecords {
                let keyDate: Date
                switch period {
                case .harian: keyDate = calendar.startOfDay(for: record.timestamp)
                case .bulanan: keyDate = calendar.date(from: calendar.dateComponents([.year, .month], from: record.timestamp)) ?? record.timestamp
                case .tahunan: keyDate = calendar.date(from: calendar.dateComponents([.year], from: record.timestamp)) ?? record.timestamp
                }
                let current = dict[keyDate] ?? (0, 0)
                if record.typeRaw == TransactionType.income.rawValue { dict[keyDate] = (current.income + record.amount, current.expense) }
                else { dict[keyDate] = (current.income, current.expense + record.amount) }
            }
            let sortedChart = dict.keys.sorted().map { (date: $0, income: dict[$0]!.income, expense: dict[$0]!.expense) }
            await MainActor.run { self.chartData = sortedChart }
        }
    }
}
