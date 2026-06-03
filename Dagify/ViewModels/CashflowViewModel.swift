import Foundation
import Observation

enum ChartFilter: String, CaseIterable, Identifiable {
    case all = "Semua"
    case thisYear = "Tahun Ini"
    case thisMonth = "Bulan Ini"
    case today = "Hari Ini"
    var id: String { self.rawValue }
}

struct CashflowChartData: Identifiable {
    let id = UUID()
    let date: Date
    let income: Double
    let expense: Double
    let cumulativeNet: Double
}

@MainActor
@Observable
class CashflowViewModel {
    var records: [FinancialRecord] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    var currentMonthDate: Date = Date()
    var chartFilter: ChartFilter = .thisMonth
    
    private let cashProtocol: CashflowProtocol

    init(cashProtocol: CashflowProtocol) {
        self.cashProtocol = cashProtocol
    }

    var filteredRecords: [FinancialRecord] {
        let calendar = Calendar.current
        return records.filter {
            calendar.isDate($0.timestamp, equalTo: currentMonthDate, toGranularity: .month) &&
            calendar.isDate($0.timestamp, equalTo: currentMonthDate, toGranularity: .year)
        }.sorted(by: { $0.timestamp > $1.timestamp })
    }

    var totalIncome: Double { filteredRecords.filter { $0.type == .income }.reduce(0) { $0 + $1.amount } }
    var totalExpense: Double { filteredRecords.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount } }
    var netProfit: Double { totalIncome - totalExpense }

    var currentMonthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: currentMonthDate)
    }

    /// Checks if the currently viewed month is the current calendar month.
    var isCurrentMonthTheLatest: Bool {
        let calendar = Calendar.current
        let now = Date()
        return calendar.isDate(currentMonthDate, equalTo: now, toGranularity: .month) &&
               calendar.isDate(currentMonthDate, equalTo: now, toGranularity: .year)
    }

    func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentMonthDate) { currentMonthDate = newDate }
    }

    func nextMonth() {
        /// Prevent navigating beyond the current month.
        guard !isCurrentMonthTheLatest else { return }
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentMonthDate) { currentMonthDate = newDate }
    }

    var chartUnit: Calendar.Component {
        switch chartFilter {
        case .all: return .year
        case .thisYear: return .month
        case .thisMonth: return .day
        case .today: return .hour
        }
    }
    
    var chartData: [CashflowChartData] {
        let calendar = Calendar.current
        let now = Date()
        
        let baseRecords: [FinancialRecord]
        switch chartFilter {
        case .all: baseRecords = records
        case .thisYear: baseRecords = records.filter { calendar.isDate($0.timestamp, equalTo: now, toGranularity: .year) }
        case .thisMonth: baseRecords = records.filter { calendar.isDate($0.timestamp, equalTo: now, toGranularity: .month) && calendar.isDate($0.timestamp, equalTo: now, toGranularity: .year) }
        case .today: baseRecords = records.filter { calendar.isDateInToday($0.timestamp) }
        }
        
        var grouped: [Date: (income: Double, expense: Double)] = [:]
        for record in baseRecords {
            var components = calendar.dateComponents([.year, .month, .day, .hour], from: record.timestamp)
            switch chartFilter {
            case .all: components.month = 1; components.day = 1; components.hour = 0
            case .thisYear: components.day = 1; components.hour = 0
            case .thisMonth: components.hour = 0
            case .today: break
            }
            guard let normalizedDate = calendar.date(from: components) else { continue }
            
            let current = grouped[normalizedDate] ?? (0, 0)
            if record.type == .income { grouped[normalizedDate] = (current.income + record.amount, current.expense) }
            else { grouped[normalizedDate] = (current.income, current.expense + record.amount) }
        }
        
        let sortedKeys = grouped.keys.sorted()
        var result: [CashflowChartData] = []
        var runningNet: Double = 0
        
        for key in sortedKeys {
            let val = grouped[key]!
            runningNet += (val.income - val.expense)
            result.append(CashflowChartData(date: key, income: val.income, expense: val.expense, cumulativeNet: runningNet))
        }
        return result
    }

    func loadRecords(branchId: String) async {
        isLoading = true
        errorMessage = nil
        do { records = try await cashProtocol.fetchRecords(for: branchId) }
        catch { errorMessage = "Gagal memuat arus kas: \(error.localizedDescription)" }
        isLoading = false
    }

    func addTransaction(branchId: String, amount: Double, type: TransactionType, category: ExpenseCategory, notes: String, date: Date) async {
        isLoading = true
        let record = FinancialRecord(id: UUID().uuidString, branchId: branchId, amount: amount, type: type, category: category, timestamp: date, notes: notes)
        do {
            _ = try await cashProtocol.addRecord(record)
            currentMonthDate = record.timestamp // Pindah ke bulan transaksi
            await loadRecords(branchId: branchId)
        } catch { errorMessage = "Gagal menambah transaksi: \(error.localizedDescription)" }
        isLoading = false
    }

    func updateTransaction(_ record: FinancialRecord) async {
        isLoading = true
        do {
            _ = try await cashProtocol.updateRecord(record)
            currentMonthDate = record.timestamp // Pindah ke bulan transaksi
            await loadRecords(branchId: record.branchId)
        } catch { errorMessage = "Gagal memperbarui transaksi." }
        isLoading = false
    }
    
    func deleteTransaction(recordId: String, branchId: String) async {
        isLoading = true
        do {
            _ = try await cashProtocol.deleteRecord(id: recordId)
            await loadRecords(branchId: branchId)
        } catch { errorMessage = "Gagal menghapus transaksi." }
        isLoading = false
    }
}
