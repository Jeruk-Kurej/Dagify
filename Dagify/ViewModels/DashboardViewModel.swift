import Foundation
import Observation

struct ChartData: Identifiable {
    let id = UUID()
    let productName: String
    let quantity: Int
}

@MainActor
@Observable
class DashboardViewModel {
    var todayRevenue: Double = 0
    var totalLoyalCustomers: Int = 0
    var lowStockAlertsCount: Int = 0
    var todayExpense: Double = 0
    var todayNetProfit: Double = 0
    var storeName: String = ""
    var branchName: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    /// Chart state variables.
    var orders: [Order] = []
    var categories: [ProductCategory] = []
    var selectedCategoryId: String? = nil
    
    var chartData: [ChartData] {
        var salesDict: [String: Int] = [:]
        for order in orders {
            for item in order.items {
                if selectedCategoryId == nil || item.product.categoryId == selectedCategoryId {
                    salesDict[item.product.name, default: 0] += item.quantity
                }
            }
        }
        return salesDict.map { ChartData(productName: $0.key, quantity: $0.value) }.sorted { $0.quantity > $1.quantity }
    }

    let cashflowProtocol: CashflowProtocol
    let crmProtocol: CRMProtocol
    let operationalProtocol: OperationalProtocol
    let storeProtocol: StoreProtocol

    init(cashflowProtocol: CashflowProtocol, crmProtocol: CRMProtocol, operationalProtocol: OperationalProtocol, storeProtocol: StoreProtocol) {
        self.cashflowProtocol = cashflowProtocol
        self.crmProtocol = crmProtocol
        self.operationalProtocol = operationalProtocol
        self.storeProtocol = storeProtocol
    }

    func loadDashboardSummary(storeId: String, branchId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            async let fetchCashflow = cashflowProtocol.fetchRecords(for: branchId)
            async let fetchCustomers = crmProtocol.fetchCustomers(for: storeId)
            async let fetchIngredients = operationalProtocol.fetchIngredients(for: branchId)
            async let fetchStoreInfo = storeProtocol.fetchStore(storeId: storeId)
            async let fetchOrders = operationalProtocol.fetchOrders(for: branchId)
            async let fetchCategories = operationalProtocol.fetchCategories(for: branchId)
            
            let (records, customers, ingredients, storeInfo, orders, categories) = try await (fetchCashflow, fetchCustomers, fetchIngredients, fetchStoreInfo, fetchOrders, fetchCategories)
            
            self.storeName = storeInfo.name
            self.branchName = storeInfo.branches.first(where: { $0.id == branchId })?.name ?? "Cabang Tidak Diketahui"
            self.orders = orders
            self.categories = categories
            
            let calendar = Calendar.current
            let todaysRecords = records.filter { calendar.isDateInToday($0.timestamp) }
            
            todayRevenue = todaysRecords.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
            todayExpense = todaysRecords.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
            todayNetProfit = todayRevenue - todayExpense
            totalLoyalCustomers = customers.filter { $0.isLoyal }.count
            lowStockAlertsCount = ingredients.filter { $0.currentStock <= $0.minimumStockWarning }.count
        } catch { errorMessage = "Gagal memuat dashboard." }
        isLoading = false
    }
}
