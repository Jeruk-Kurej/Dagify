//
//  ProductAnalyticsViewModelTests.swift
//  DagifyTests
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation
import Testing

@testable import Dagify

@Suite("ProductAnalytics ViewModel Tests")
@MainActor
struct ProductAnalyticsViewModelTests {

    @Test("Fungsi: loadAnalyticsData() - Skenario Berhasil")
    func testLoadAnalyticsDataSuccess() async {
        let mockOpRepo = MockOperationalRepository()
        let vm = ProductAnalyticsViewModel(operationalProtocol: mockOpRepo)

        let p1 = Product(id: "1", name: "Kopi", price: 10000, recipe: [])
        let p2 = Product(id: "2", name: "Teh", price: 5000, recipe: [])
        mockOpRepo.products = [p1, p2]

        await vm.loadAnalyticsData(branchId: "B-1")

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
    }

    @Test("Fungsi: loadAnalyticsData() - Skenario Error")
    func testLoadAnalyticsDataFailure() async {
        let mockOpRepo = MockOperationalRepository()
        let vm = ProductAnalyticsViewModel(operationalProtocol: mockOpRepo)

        mockOpRepo.shouldThrowError = true

        await vm.loadAnalyticsData(branchId: "B-1")

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage != nil)
        #expect(vm.chartData.isEmpty == true)
    }
}
