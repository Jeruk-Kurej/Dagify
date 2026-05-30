//
//  DashboardViewModel.swift
//  DagifyTests
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Testing
import Foundation
@testable import Dagify

@Suite("Dashboard ViewModel Tests")
@MainActor
struct DashboardViewModelTests {
    @Test("Test Kalkulasi Hari Ini di Dashboard")
    func testDashboardDailySummary() async {
        let mockCash = MockCashflowRepository()
        let mockCRM = MockCRMRepository()
        let mockOp = MockOperationalRepository()
        let vm = DashboardViewModel(cashflowProtocol: mockCash, crmProtocol: mockCRM, operationalProtocol: mockOp)
        
        let recordIncome = FinancialRecord(branchId: "B1", amount: 100000, type: .income, category: .none, timestamp: Date(), notes: "")
        _ = try? await mockCash.addRecord(recordIncome)
        
        await vm.loadDashboardSummary(storeId: "S1", branchId: "B1")
        
        #expect(vm.todayRevenue == 100000)
    }
}

