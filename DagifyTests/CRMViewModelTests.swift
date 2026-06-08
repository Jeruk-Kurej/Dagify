//
//  CRMViewModelTests.swift
//  DagifyTests
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation
import Testing

@testable import Dagify

@Suite("CRM ViewModel Tests")
@MainActor
struct CRMViewModelTests {

    @Test("Fungsi: loadCustomers() - Skenario Berhasil")
    func testLoadCustomersSuccess() async {
        let mockCrmRepo = MockCRMRepository()
        let mockStoreRepo = MockStoreRepository()
        let vm = CRMViewModel(
            crmProtocol: mockCrmRepo,
            storeProtocol: mockStoreRepo
        )

        // Setup mock data
        let c1 = Customer(
            id: "1",
            storeId: "S-1",
            branchId: "B-1",
            name: "Budi",
            phoneNumber: "081",
            totalSpent: 10000,
            visitHistory: [Date(), Date(), Date(), Date(), Date()]
        )
        let c2 = Customer(
            id: "2",
            storeId: "S-1",
            branchId: "B-1",
            name: "Siti",
            phoneNumber: "082",
            totalSpent: 5000,
            visitHistory: [Date(), Date()]
        )
        mockCrmRepo.customers = [c1, c2]

        await vm.loadCustomers(storeId: "S-1")

        #expect(vm.customers.count == 2)
        #expect(vm.customers.first?.name == "Budi")
        #expect(vm.isLoading == false)
    }

    @Test("Fungsi: loadCustomers() - Skenario Error")
    func testLoadCustomersFailure() async {
        let mockCrmRepo = MockCRMRepository()
        let mockStoreRepo = MockStoreRepository()
        let vm = CRMViewModel(
            crmProtocol: mockCrmRepo,
            storeProtocol: mockStoreRepo
        )

        mockCrmRepo.shouldThrowError = true

        await vm.loadCustomers(storeId: "S-1")

        #expect(vm.customers.isEmpty == true)
        #expect(vm.errorMessage != nil)
        #expect(vm.isLoading == false)
    }

    @Test("Fungsi: getCustomerCount() - Skenario Filter")
    func testGetCustomerCount() async {
        let mockCrmRepo = MockCRMRepository()
        let mockStoreRepo = MockStoreRepository()
        let vm = CRMViewModel(
            crmProtocol: mockCrmRepo,
            storeProtocol: mockStoreRepo
        )

        let c1 = Customer(
            id: "1",
            storeId: "S-1",
            branchId: "B-1",
            name: "Budi",
            phoneNumber: "081",
            totalSpent: 10000,
            visitHistory: [Date(), Date(), Date(), Date(), Date()]
        )
        let c2 = Customer(
            id: "2",
            storeId: "S-1",
            branchId: "B-1",
            name: "Siti",
            phoneNumber: "082",
            totalSpent: 5000,
            visitHistory: [Date(), Date()]
        )
        let c3 = Customer(
            id: "3",
            storeId: "S-1",
            branchId: "B-1",
            name: "Agus",
            phoneNumber: "083",
            totalSpent: 20000,
            visitHistory: Array(repeating: Date(), count: 10)
        )
        mockCrmRepo.customers = [c1, c2, c3]

        await vm.loadCustomers(storeId: "S-1")

        let totalLoyal = vm.getCustomerCount(for: "B-1", isLoyalOnly: true)
        let totalSemua = vm.getCustomerCount(for: "B-1", isLoyalOnly: false)

        #expect(totalLoyal == 2)
        #expect(totalSemua == 3)
    }
}
