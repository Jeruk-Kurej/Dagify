import Foundation
import Observation

@MainActor
@Observable
class CashflowViewModel {
    var records: [FinancialRecord] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    // ✅ STATE BARU: Indikator Bulan Aktif
    var currentMonthDate: Date = Date()

    private let cashProtocol: CashflowProtocol

    init(cashProtocol: CashflowProtocol) {
        self.cashProtocol = cashProtocol
    }

    // ✅ FITUR BARU: Mem-filter transaksi berdasarkan Bulan dan Tahun yang dipilih
    var filteredRecords: [FinancialRecord] {
        let calendar = Calendar.current
        return records.filter {
            calendar.isDate($0.timestamp, equalTo: currentMonthDate, toGranularity: .month) &&
            calendar.isDate($0.timestamp, equalTo: currentMonthDate, toGranularity: .year)
        }.sorted(by: { $0.timestamp > $1.timestamp }) // Urutkan transaksi terbaru di paling atas
    }

    // Perhitungan Laba & PDF sekarang HANYA melihat data bulan tersebut
    var totalIncome: Double {
        filteredRecords.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    var totalExpense: Double {
        filteredRecords.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    var netProfit: Double {
        totalIncome - totalExpense
    }

    // Diformat ala Indonesia (Cth: Agustus 2026)
    var currentMonthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: currentMonthDate)
    }

    func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentMonthDate) {
            currentMonthDate = newDate
        }
    }

    func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentMonthDate) {
            currentMonthDate = newDate
        }
    }

    func loadRecords(branchId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            records = try await cashProtocol.fetchRecords(for: branchId)
        } catch {
            errorMessage = "Gagal memuat arus kas: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func addTransaction(branchId: String, amount: Double, type: TransactionType, category: ExpenseCategory, notes: String) async {
        isLoading = true
        let record = FinancialRecord(
            id: UUID().uuidString,
            branchId: branchId,
            amount: amount,
            type: type,
            category: category,
            timestamp: Date(),
            notes: notes
        )
        do {
            _ = try await cashProtocol.addRecord(record)
            currentMonthDate = Date() // Otomatis balik ke bulan saat ini jika tambah data baru
            await loadRecords(branchId: branchId)
        } catch {
            errorMessage = "Gagal menambah transaksi: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
