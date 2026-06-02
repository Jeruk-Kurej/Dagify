//
//  POSViewModel.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
class POSViewModel {
    var availableProducts: [Product] = []
    var cart: [OrderItem] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isCheckoutSuccess: Bool = false

    private let operationalProtocol: OperationalProtocol
    // ✅ DITAMBAHKAN: Jalur komunikasi Kasir ke Arus Kas
    private let cashflowProtocol: CashflowProtocol
    private let networkMonitor: NetworkMonitor
    private let syncManager: SyncManagerProtocol

    init(
        operationalProtocol: OperationalProtocol,
        cashflowProtocol: CashflowProtocol, // ✅ DITAMBAHKAN
        networkMonitor: NetworkMonitor,
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
            branchId: branchId,
            customerId: nil,
            items: cart,
            totalAmount: subtotal,
            timestamp: Date()
        )

        // ✅ BUAT NOTA KEUANGAN OTOMATIS
        let incomeRecord = FinancialRecord(
            branchId: branchId,
            amount: subtotal,
            type: .income,
            category: .none,
            timestamp: Date(),
            notes: "Penjualan Kasir (POS)"
        )

        if networkMonitor.isConnected {
            do {
                // 1. Potong Stok Gudang & Catat Pesanan
                _ = try await operationalProtocol.submitOrderAndUpdateInventory(order: order)
                // 2. Setor Uang ke Arus Kas
                _ = try await cashflowProtocol.addRecord(incomeRecord)
                
                isCheckoutSuccess = true
                cart.removeAll()
            } catch {
                errorMessage = "Gagal memproses transaksi: \(error.localizedDescription)"
            }
        } else {
            // Mode Offline (Nantinya bisa di-sync ke Cashflow saat koneksi kembali)
            do {
                let offlineOrder = OfflineOrderModel(branchId: branchId, customerId: nil, totalAmount: subtotal, timestamp: Date())
                context.insert(offlineOrder)
                try context.save()
                isCheckoutSuccess = true
                cart.removeAll()
            } catch {
                errorMessage = "Gagal menyimpan transaksi offline."
            }
        }
        isLoading = false
    }
}
