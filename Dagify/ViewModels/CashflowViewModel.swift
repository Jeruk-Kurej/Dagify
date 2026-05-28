//
//  CashflowViewModel.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Foundation
import Combine

@MainActor
class CashflowViewModel : ObservableObject{
    var records: [FinancialRecord] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let repository: CashflowRepository
    
    init(repository: CashflowRepository) {
        self.repository = repository
    }
    
    // MARK: - Core Operations
    
    func loadRecords(branchId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            records = try await repository.fetchRecords(for: branchId)
        } catch {
            errorMessage = "Gagal memuat data keuangan: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func addTransaction(branchId: String, amount: Double, type: TransactionType, category: ExpenseCategory, notes: String) async {
        isLoading = true
        errorMessage = nil
        
        let newRecord = FinancialRecord(
            branchId: branchId,
            amount: amount,
            type: type,
            category: category,
            timestamp: Date(),
            notes: notes
        )
        
        do {
            _ = try await repository.addRecord(newRecord)
            await loadRecords(branchId: branchId)
        } catch {
            errorMessage = "Gagal menyimpan transaksi."
        }
        
        isLoading = false
    }
    
    func deleteTransaction(recordId: String, branchId: String) async {
        isLoading = true
        do {
            _ = try await repository.deleteRecord(id: recordId)
            await loadRecords(branchId: branchId)
        } catch {
            errorMessage = "Gagal menghapus transaksi."
        }
        isLoading = false
    }
    
    // MARK: - Computations & Analytics (Business Logic)
    
    var totalIncome: Double {
        records.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpense: Double {
        records.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    var netProfit: Double {
        totalIncome - totalExpense
    }
    
    var groupedRecordsByMonth: [String: [FinancialRecord]] {
        Dictionary(grouping: records) { record in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: record.timestamp)
        }
    }
}
