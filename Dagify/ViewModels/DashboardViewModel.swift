//
//  DashboardViewModel.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
class DashboardViewModel {
    var todayRevenue: Double = 0
    var todayExpense: Double = 0
    var todayNetProfit: Double = 0
    var totalLoyalCustomers: Int = 0
    var lowStockAlertsCount: Int = 0

    var isLoading: Bool = false
    var selectedPeriod: ChartPeriod = .harian
    private var allRecords: [FinancialRecord] = []

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

    var revenueTrend: [(date: Date, amount: Double)] {
        var dict: [Date: Double] = [:]
        let calendar = Calendar.current

        for record in allRecords where record.type == .income {
            let keyDate: Date
            switch selectedPeriod {
            case .harian: keyDate = calendar.startOfDay(for: record.timestamp)
            case .bulanan:
                keyDate =
                    calendar.date(
                        from: calendar.dateComponents(
                            [.year, .month],
                            from: record.timestamp
                        )
                    ) ?? record.timestamp
            case .tahunan:
                keyDate =
                    calendar.date(
                        from: calendar.dateComponents(
                            [.year],
                            from: record.timestamp
                        )
                    ) ?? record.timestamp
            }
            dict[keyDate, default: 0] += record.amount
        }

        let sortedKeys = dict.keys.sorted()
        return sortedKeys.map { (date: $0, amount: dict[$0]!) }
    }

    func loadDashboardSummary(storeId: String, branchId: String) async {
        isLoading = true
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
            self.allRecords = records
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
        } catch { print("Error Loading Dashboard") }
        isLoading = false
    }
}
