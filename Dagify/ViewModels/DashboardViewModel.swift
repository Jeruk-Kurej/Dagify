//
//  DashboardViewModel.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Foundation
import Observation

@MainActor
@Observable
class DashboardViewModel {
    var todayRevenue: Double = 0
    var totalLoyalCustomers: Int = 0
    var lowStockAlertsCount: Int = 0

    var todayExpense: Double = 0
    var todayNetProfit: Double = 0

    var isLoading: Bool = false
    var errorMessage: String? = nil

    let cashflowProtocol: CashflowProtocol
    let crmProtocol: CRMProtocol
    let operationalProtocol: OperationalProtocol

    init(
        cashflowProtocol: CashflowProtocol,
        crmProtocol: CRMProtocol,
        operationalProtocol: OperationalProtocol
    ) {
        self.cashflowProtocol = cashflowProtocol
        self.crmProtocol = crmProtocol
        self.operationalProtocol = operationalProtocol
    }

    func loadDashboardSummary(storeId: String, branchId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            async let fetchCashflow = cashflowProtocol.fetchRecords(
                for: branchId
            )
            async let fetchCustomers = crmProtocol.fetchCustomers(for: storeId)
            async let fetchIngredients = operationalProtocol.fetchIngredients(
                for: branchId
            )

            let (records, customers, ingredients) = try await (
                fetchCashflow, fetchCustomers, fetchIngredients
            )

            let calendar = Calendar.current
            let todaysRecords = records.filter {
                calendar.isDateInToday($0.timestamp)
            }

            todayRevenue = todaysRecords.filter { $0.type == .income }.reduce(0)
            { $0 + $1.amount }
            todayExpense = todaysRecords.filter { $0.type == .expense }.reduce(
                0
            ) { $0 + $1.amount }
            todayNetProfit = todayRevenue - todayExpense
            totalLoyalCustomers = customers.filter { $0.isLoyal }.count

            lowStockAlertsCount =
                ingredients.filter { $0.currentStock <= $0.minimumStockWarning }
                .count

        } catch {
            errorMessage = "Gagal memuat dashboard."
        }

        isLoading = false
    }
}
