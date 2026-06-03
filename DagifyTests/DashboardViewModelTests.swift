//
//  DashboardViewModel.swift
//  DagifyTests
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation
import Testing

@testable import Dagify

@Suite("Dashboard ViewModel Tests")
@MainActor
struct DashboardViewModelTests {

    @Test("Fungsi: loadDashboardSummary() - Skenario Berhasil")
    func testLoadDashboardSummarySuccess() async {
        let mockCashflowRepo = MockCashflowRepository()
        let mockCrmRepo = MockCRMRepository()
        let mockOpRepo = MockOperationalRepository()
        let mockStoreRepo = MockStoreRepository()
        
        let vm = DashboardViewModel(
            cashflowProtocol: mockCashflowRepo,
            crmProtocol: mockCrmRepo,
            operationalProtocol: mockOpRepo,
            storeProtocol: mockStoreRepo
        )

        // Setup mock data
        let r1 = FinancialRecord(id: "1", branchId: "B-1", amount: 10000, type: .income, category: .none, timestamp: Date(), notes: "")
        let r2 = FinancialRecord(id: "2", branchId: "B-1", amount: 2000, type: .expense, category: .marketing, timestamp: Date(), notes: "")
        mockCashflowRepo.records = [r1, r2]
        
        let c1 = Customer(id: "1", storeId: "S-1", branchId: "B-1", name: "Budi", phoneNumber: "081", totalSpent: 10000, visitHistory: [Date(), Date(), Date(), Date(), Date()])
        mockCrmRepo.customers = [c1]
        
        let p1 = Product(id: "1", branchId: "B-1", name: "Kopi", price: 10000, recipe: [])
        mockOpRepo.products = [p1]

        await vm.loadDashboardSummary(storeId: "S-1", branchId: "B-1")

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
        
        // Income - Expense = 10000 - 2000 = 8000
        #expect(vm.todayNetProfit == 8000)
        #expect(vm.totalLoyalCustomers == 1) // because no loyal customers were added
        #expect(vm.chartData.isEmpty == true) // No orders added
    }

    @Test("Fungsi: loadDashboardSummary() - Skenario Error")
    func testLoadDashboardSummaryFailure() async {
        let mockCashflowRepo = MockCashflowRepository()
        let mockCrmRepo = MockCRMRepository()
        let mockOpRepo = MockOperationalRepository()
        let mockStoreRepo = MockStoreRepository()
        
        let vm = DashboardViewModel(
            cashflowProtocol: mockCashflowRepo,
            crmProtocol: mockCrmRepo,
            operationalProtocol: mockOpRepo,
            storeProtocol: mockStoreRepo
        )

        mockCashflowRepo.shouldThrowError = true

        await vm.loadDashboardSummary(storeId: "S-1", branchId: "B-1")

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage != nil)
        #expect(vm.todayNetProfit == 0)
    }
}
