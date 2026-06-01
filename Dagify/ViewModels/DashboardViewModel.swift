//
//  DashboardViewModel.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Charts
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

        return dict.keys.sorted().map { (date: $0, amount: dict[$0]!) }
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

struct DashboardView: View {
    @Bindable var viewModel: DashboardViewModel
    let storeId: String
    let branchId: String
    let columns = [GridItem(.adaptive(minimum: 160))]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("Menyiapkan Metrik...").frame(
                            maxHeight: .infinity
                        )
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            DashItemCard(
                                title: "Pendapatan Hari Ini",
                                value:
                                    "Rp \(viewModel.todayRevenue, specifier: "%.0f")",
                                icon: "arrow.up.circle.fill",
                                color: .themeSuccess
                            )
                            DashItemCard(
                                title: "Laba Bersih",
                                value:
                                    "Rp \(viewModel.todayNetProfit, specifier: "%.0f")",
                                icon: "banknote.fill",
                                color: .themePrimary
                            )
                            DashItemCard(
                                title: "Pelanggan Loyal",
                                value: "\(viewModel.totalLoyalCustomers)",
                                icon: "person.2.fill",
                                color: .themeWarning
                            )
                            DashItemCard(
                                title: "Stok Menipis",
                                value: "\(viewModel.lowStockAlertsCount)",
                                icon: "exclamationmark.triangle.fill",
                                color: .themeDestructive
                            )
                        }
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Tren Penjualan").font(.headline)
                                Spacer()
                                Picker(
                                    "Periode",
                                    selection: $viewModel.selectedPeriod
                                ) {
                                    ForEach(ChartPeriod.allCases, id: \.self) {
                                        Text($0.rawValue).tag($0)
                                    }
                                }.pickerStyle(.menu)
                            }
                            if viewModel.revenueTrend.isEmpty {
                                ContentUnavailableView(
                                    "Tidak Ada Data",
                                    systemImage: "chart.xyaxis.line"
                                ).frame(height: 200)
                            } else {
                                Chart {
                                    ForEach(viewModel.revenueTrend, id: \.date)
                                    { item in
                                        LineMark(
                                            x: .value("Tanggal", item.date),
                                            y: .value("Total", item.amount)
                                        ).foregroundStyle(Color.themePrimary)
                                            .symbol(
                                                Circle().strokeBorder(
                                                    lineWidth: 2
                                                )
                                            )
                                        AreaMark(
                                            x: .value("Tanggal", item.date),
                                            y: .value("Total", item.amount)
                                        ).foregroundStyle(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.themePrimary.opacity(
                                                        0.4
                                                    ), .clear,
                                                ]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                    }
                                }.frame(height: 250)
                            }
                        }.padding().background(Color.themeBgSecondary)
                            .cornerRadius(12)
                    }
                }.padding()
            }.navigationTitle("Dashboard").background(Color.themeBgMain)
                .onAppear {
                    Task {
                        await viewModel.loadDashboardSummary(
                            storeId: storeId,
                            branchId: branchId
                        )
                    }
                }
        }
    }
}
