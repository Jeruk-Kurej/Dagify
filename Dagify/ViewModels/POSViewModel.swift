import Foundation
import Observation
import SwiftData

protocol NetworkMonitorProtocol { var isConnected: Bool { get } }
extension NetworkMonitor: NetworkMonitorProtocol {}

@MainActor
@Observable
class POSViewModel {
    var availableProducts: [Product] = []
    var cart: [OrderItem] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isCheckoutSuccess: Bool = false
    
    var customerPhone: String = ""
    var customerName: String = ""
    
    // ✅ CRM AUTO-SUGGESTION STATE
    var allCustomers: [Customer] = []
    
    // Komputasi pintar untuk memunculkan dropdown jika nomor diketik
    var suggestedCustomers: [Customer] {
        guard !customerPhone.isEmpty else { return [] }
        // Sembunyikan jika nomornya sudah persis / sudah dipilih
        if allCustomers.contains(where: { $0.phoneNumber == customerPhone }) { return [] }
        return allCustomers.filter { $0.phoneNumber.contains(customerPhone) }
    }

    private let operationalProtocol: OperationalProtocol
    private let cashflowProtocol: CashflowProtocol
    private let crmProtocol: CRMProtocol
    private let networkMonitor: NetworkMonitorProtocol
    private let syncManager: SyncManagerProtocol

    init(operationalProtocol: OperationalProtocol, cashflowProtocol: CashflowProtocol, crmProtocol: CRMProtocol, networkMonitor: NetworkMonitorProtocol, syncManager: SyncManagerProtocol) {
        self.operationalProtocol = operationalProtocol
        self.cashflowProtocol = cashflowProtocol
        self.crmProtocol = crmProtocol
        self.networkMonitor = networkMonitor
        self.syncManager = syncManager
    }

    var subtotal: Double { cart.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) } }

    func getCartQuantity(for product: Product) -> Int {
        return cart.first(where: { $0.product.id == product.id })?.quantity ?? 0
    }

    func loadProducts(branchId: String) async {
        isLoading = true
        do { availableProducts = try await operationalProtocol.fetchProducts(for: branchId) } catch { errorMessage = "Gagal memuat menu." }
        isLoading = false
    }
    
    // ✅ TARIK DATA PELANGGAN DI LATAR BELAKANG
    func loadCustomersForSuggestions(storeId: String) async {
        do { allCustomers = try await crmProtocol.fetchCustomers(for: storeId) } catch { }
    }
    
    // ✅ AKSI SAAT KASIR MEMILIH NOMOR DARI DROPDOWN
    func selectCustomer(_ customer: Customer) {
        customerPhone = customer.phoneNumber
        customerName = customer.name
    }

    func addToCart(product: Product) {
        if let index = cart.firstIndex(where: { $0.product.id == product.id }) { cart[index].quantity += 1 } else { cart.append(OrderItem(product: product, quantity: 1)) }
    }

    func removeOrDecreaseFromCart(product: Product) {
        if let index = cart.firstIndex(where: { $0.product.id == product.id }) {
            if cart[index].quantity > 1 { cart[index].quantity -= 1 } else { cart.remove(at: index) }
        }
    }

    func checkout(storeId: String, branchId: String, context: ModelContext) async {
        guard !cart.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        var finalCustomerId: String? = nil
        
        if !customerPhone.isEmpty && networkMonitor.isConnected {
            do {
                let customers = try await crmProtocol.fetchCustomers(for: storeId)
                if let existingCustomer = customers.first(where: { $0.phoneNumber == customerPhone }) {
                    if let cid = existingCustomer.id {
                        _ = try await crmProtocol.recordNewVisit(customerId: cid, spent: subtotal, date: Date())
                        finalCustomerId = cid
                    }
                } else {
                    let newName = customerName.isEmpty ? "Pelanggan" : customerName
                    let newCustomer = Customer(id: UUID().uuidString, storeId: storeId, name: newName, phoneNumber: customerPhone, totalSpent: subtotal, visitHistory: [Date()])
                    _ = try await crmProtocol.addCustomer(newCustomer)
                    finalCustomerId = newCustomer.id
                }
            } catch { print("Peringatan: Gagal memproses data CRM.") }
        }

        let order = Order(id: UUID().uuidString, branchId: branchId, customerId: finalCustomerId, items: cart, totalAmount: subtotal, timestamp: Date())
        let incomeRecord = FinancialRecord(id: UUID().uuidString, branchId: branchId, amount: subtotal, type: .income, category: .none, timestamp: Date(), notes: "POS: \(customerName.isEmpty ? "Pelanggan Umum" : customerName)")

        if networkMonitor.isConnected {
            do {
                _ = try await cashflowProtocol.addRecord(incomeRecord)
                do { _ = try await operationalProtocol.submitOrderAndUpdateInventory(order: order) } catch { }
                isCheckoutSuccess = true
                cart.removeAll()
                customerName = ""
                customerPhone = ""
            } catch { errorMessage = "Gagal menyetor Kas." }
        } else {
            do {
                let encoder = JSONEncoder()
                let offlineOrder = OfflineOrderModel(id: UUID().uuidString, orderData: try encoder.encode(order), timestamp: Date())
                context.insert(offlineOrder)
                try context.save()
                isCheckoutSuccess = true
                cart.removeAll()
            } catch { errorMessage = "Gagal menyimpan transaksi offline." }
        }
        isLoading = false
    }
}
