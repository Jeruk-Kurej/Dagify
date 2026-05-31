//
//  CRMViewModelTests.swift
//  DagifyTests
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation
import Testing

@testable import Dagify

@MainActor
struct CRMViewModelTests {

    @Test("1. Kalkulasi Persentase Pelanggan Loyal")
    func testLoyalCustomerPercentage() async {
        let mockRepo = MockCRMRepository()
        let viewModel = CRMViewModel(crmProtocol: mockRepo)

        let loyalCust = Customer(
            name: "A",
            phoneNumber: "1",
            totalSpent: 500,
            visitHistory: [Date(), Date(), Date(), Date(), Date(), Date()]
        )
        let newCust = Customer(
            name: "B",
            phoneNumber: "2",
            totalSpent: 100,
            visitHistory: [Date()]
        )

        _ = try? await mockRepo.addCustomer(loyalCust)
        _ = try? await mockRepo.addCustomer(newCust)

        await viewModel.loadCustomers(storeId: "S-1")

        #expect(
            viewModel.loyalCustomerPercentage == 50.0,
            "Kalkulasi persentase loyalitas CRM salah"
        )
    }

    @Test("2. Logika Pendaftaran Otomatis Saat Checkout")
    func testProcessCustomerCheckout() async {
        let mockRepo = MockCRMRepository()
        let viewModel = CRMViewModel(crmProtocol: mockRepo)

        let newId = await viewModel.processCustomerForCheckout(
            name: "Budi",
            phone: "0812",
            spent: 50000,
            storeId: "S-1"
        )

        #expect(newId == nil, "Pelanggan baru harus mereturn nil untuk ID")

        await viewModel.loadCustomers(storeId: "S-1")
        #expect(
            viewModel.customers.count == 1,
            "Pelanggan baru gagal ditambahkan ke database"
        )
    }
}
