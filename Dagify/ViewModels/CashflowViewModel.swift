import Foundation
import Observation

// ✅ ENUM & STRUKTUR BARU UNTUK GRAFIK
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
    let cumulativeNet: Double // Untuk garis "Cash Flow"
}

@MainActor
@Observable
class CashflowViewModel {
    var records: [FinancialRecord] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    // --- STATE TRANSAKSI LIST & PDF ---
    var currentMonthDate: Date = Date()
    
    // ✅ STATE GRAFIK (Independen dari List)
    var chartFilter: ChartFilter = .thisMonth
    
    private let cashProtocol: CashflowProtocol

    init(cashProtocol: CashflowProtocol) {
        self.cashProtocol = cashProtocol
    }

    // --- LOGIKA TRANSAKSI LIST & PDF ---
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

    func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentMonthDate) { currentMonthDate = newDate }
    }

    func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentMonthDate) { currentMonthDate = newDate }
    }

    // --- ✅ LOGIKA GRAFIK (KOMPUTASI DATA) ---
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
        
        // 1. Filter data mentah sesuai pilihan
        let baseRecords: [FinancialRecord]
        switch chartFilter {
        case .all:
            baseRecords = records
        case .thisYear:
            baseRecords = records.filter { calendar.isDate($0.timestamp, equalTo: now, toGranularity: .year) }
        case .thisMonth:
            baseRecords = records.filter { calendar.isDate($0.timestamp, equalTo: now, toGranularity: .month) && calendar.isDate($0.timestamp, equalTo: now, toGranularity: .year) }
        case .today:
            baseRecords = records.filter { calendar.isDateInToday($0.timestamp) }
        }
        
        // 2. Gabungkan transaksi berdasarkan unit waktu
        var grouped: [Date: (income: Double, expense: Double)] = [:]
        
        for record in baseRecords {
            var components = calendar.dateComponents([.year, .month, .day, .hour], from: record.timestamp)
            // Normalisasi Tanggal agar Chart menumpuknya dengan rapi
            switch chartFilter {
            case .all: components.month = 1; components.day = 1; components.hour = 0
            case .thisYear: components.day = 1; components.hour = 0
            case .thisMonth: components.hour = 0
            case .today: break // Pertahankan Jam
            }
            guard let normalizedDate = calendar.date(from: components) else { continue }
            
            let current = grouped[normalizedDate] ?? (0, 0)
            if record.type == .income { grouped[normalizedDate] = (current.income + record.amount, current.expense) }
            else { grouped[normalizedDate] = (current.income, current.expense + record.amount) }
        }
        
        // 3. Sortir dan hitung kumulatif (Cash Flow)
        let sortedKeys = grouped.keys.sorted()
        var result: [CashflowChartData] = []
        var runningNet: Double = 0
        
        for key in sortedKeys {
            let val = grouped[key]!
            let net = val.income - val.expense
            runningNet += net
            result.append(CashflowChartData(date: key, income: val.income, expense: val.expense, cumulativeNet: runningNet))
        }
        
        return result
    }

    // --- CORE OPERATIONS ---
    func loadRecords(branchId: String) async {
        isLoading = true
        errorMessage = nil
        do { records = try await cashProtocol.fetchRecords(for: branchId) }
        catch { errorMessage = "Gagal memuat arus kas: \(error.localizedDescription)" }
        isLoading = false
    }

    func addTransaction(branchId: String, amount: Double, type: TransactionType, category: ExpenseCategory, notes: String) async {
        isLoading = true
        let record = FinancialRecord(id: UUID().uuidString, branchId: branchId, amount: amount, type: type, category: category, timestamp: Date(), notes: notes)
        do {
            _ = try await cashProtocol.addRecord(record)
            currentMonthDate = Date()
            await loadRecords(branchId: branchId)
        } catch { errorMessage = "Gagal menambah transaksi: \(error.localizedDescription)" }
        isLoading = false
    }
}
