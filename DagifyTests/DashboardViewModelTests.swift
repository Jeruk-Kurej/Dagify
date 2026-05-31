//
//  DashboardViewModel.swift
//  DagifyTests
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation
import Testing

@testable import Dagify

@MainActor
struct DashboardViewModelTests {

    @Test("1. Evaluasi Perubahan Periode Grafik Dasbor")
    func testDashboardChartPeriod() async {
        let mockCashflow = MockCashflowRepository()
        let mockCRM = MockCRMRepository()
        let mockOp = MockOperationalRepository()

        let viewModel = DashboardViewModel(
            cashflowProtocol: mockCashflow,
            crmProtocol: mockCRM,
            operationalProtocol: mockOp
        )

        let record = FinancialRecord(
            branchId: "B-1",
            amount: 200000,
            type: .income,
            category: .sales,
            timestamp: Date(),
            notes: "Test Dasbor"
        )
        _ = try? await mockCashflow.addRecord(record)

        await viewModel.loadDashboardSummary(storeId: "S-1", branchId: "B-1")

        viewModel.selectedPeriod = .harian
        #expect(
            !viewModel.revenueTrend.isEmpty,
            "Grafik harian harus memiliki data"
        )

        viewModel.selectedPeriod = .bulanan
        #expect(
            !viewModel.revenueTrend.isEmpty,
            "Grafik bulanan harus menyesuaikan data"
        )
    }
}
