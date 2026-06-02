import Foundation
import Observation
import SwiftData

// ✅ 1. DEPENDENCY INVERSION PRINCIPLE (DIP)
// Kita buat abstraksi untuk Network Monitor, bukan bergantung pada Class konkret.
protocol NetworkMonitorProtocol {
    var isConnected: Bool { get }
}

// ✅ 2. LISKOV SUBSTITUTION PRINCIPLE (LSP)
// Kita buat NetworkMonitor bawaanmu otomatis mematuhi protokol di atas.
extension NetworkMonitor: NetworkMonitorProtocol {}

@MainActor
@Observable
class POSViewModel {
    var availableProducts: [Product] = []
    var cart: [OrderItem] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isCheckoutSuccess: Bool = false

    private let operationalProtocol: OperationalProtocol
    private let cashflowProtocol: CashflowProtocol
    
    // Menerima abstraksi (Protocol), bukan class konkret
    private let networkMonitor: NetworkMonitorProtocol
    private let syncManager: SyncManagerProtocol

    init(
        operationalProtocol: OperationalProtocol,
        cashflowProtocol: CashflowProtocol,
        networkMonitor: NetworkMonitorProtocol,
        syncManager: SyncManagerProtocol
    ) {
        self.operationalProtocol = operationalProtocol
        self.cashflowProtocol = cashflowProtocol
        self.networkMonitor = networkMonitor
        self.syncManager = syncManager
    }

    var subtotal: Double {
        cart.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }

    func loadProducts(branchId: String) async {
        isLoading = true
        do {
            availableProducts = try await operationalProtocol.fetchProducts(for: branchId)
        } catch {
            errorMessage = "Gagal memuat menu."
        }
        isLoading = false
    }

    func addToCart(product: Product) {
        if let index = cart.firstIndex(where: { $0.product.id == product.id }) {
            cart[index].quantity += 1
        } else {
            cart.append(OrderItem(product: product, quantity: 1))
        }
    }

    func removeOrDecreaseFromCart(product: Product) {
        if let index = cart.firstIndex(where: { $0.product.id == product.id }) {
            if cart[index].quantity > 1 {
                cart[index].quantity -= 1
            } else {
                cart.remove(at: index)
            }
        }
    }

    func checkout(branchId: String, context: ModelContext) async {
        guard !cart.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        let order = Order(
            id: UUID().uuidString,
            branchId: branchId,
            customerId: nil,
            items: cart,
            totalAmount: subtotal,
            timestamp: Date()
        )

        let incomeRecord = FinancialRecord(
            id: UUID().uuidString,
            branchId: branchId,
            amount: subtotal,
            type: .income,
            category: .none,
            timestamp: Date(),
            notes: "Penjualan Kasir (POS)"
        )

        if networkMonitor.isConnected {
            do {
                // ✅ 3. SINGLE RESPONSIBILITY & OPEN/CLOSED PRINCIPLE
                // Kita eksekusi Kas terlebih dahulu secara mandiri.
                _ = try await cashflowProtocol.addRecord(incomeRecord)
                
                // Lalu kita proses Gudang. Dibungkus try-catch agar jika Gudang gagal/error,
                // pencatatan Kas tidak ikut terbatal (Data tetap valid).
                do {
                    _ = try await operationalProtocol.submitOrderAndUpdateInventory(order: order)
                } catch {
                    print("Peringatan: Inventori gagal diperbarui, namun pendapatan Kas berhasil dicatat.")
                }
                
                isCheckoutSuccess = true
                cart.removeAll()
            } catch {
                errorMessage = "Gagal menyetor Kas ke server: \(error.localizedDescription)"
            }
        } else {
            // Mode Offline
            do {
                let encoder = JSONEncoder()
                let encodedOrderData = try encoder.encode(order)
                
                let offlineOrder = OfflineOrderModel(
                    id: UUID().uuidString,
                    orderData: encodedOrderData,
                    timestamp: Date()
                )
                
                context.insert(offlineOrder)
                try context.save()
                isCheckoutSuccess = true
                cart.removeAll()
            } catch {
                errorMessage = "Gagal menyimpan transaksi offline: \(error.localizedDescription)"
            }
        }
        isLoading = false
    }
}
