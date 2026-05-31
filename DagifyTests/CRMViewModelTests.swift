//
//  CRMViewModelTests.swift
//  DagifyTests
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Testing
import Foundation
@testable import Dagify

@Suite("CRM ViewModel Tests")
@MainActor
struct CRMViewModelTests {
    
    @Test("Test Load Customers & Persentase Loyalitas")
    func testLoadCustomersAndLoyalty() async {
        let mockRepo = MockCRMRepository()
        let vm = CRMViewModel(crmProtocol: mockRepo)
        
        // Cust 1 = Biasa (2 kunjungan), Cust 2 = Loyal (5 kunjungan)
        let cust1 = Customer(name: "Pelanggan A", phoneNumber: "1", totalSpent: 20, visitHistory: [Date(), Date()])
        let cust2 = Customer(name: "Pelanggan B", phoneNumber: "2", totalSpent: 100, visitHistory: [Date(), Date(), Date(), Date(), Date()])
        
        _ = try? await mockRepo.addCustomer(cust1)
        _ = try? await mockRepo.addCustomer(cust2)
        
        await vm.loadCustomers(storeId: "S1")
        
        #expect(vm.customers.count == 2)
        #expect(vm.loyalCustomerPercentage == 50.0) // 1 dari 2 pelanggan adalah loyal
    }
    
    @Test("Test Heatmap Jam Sibuk (Busiest Hours)")
    func testBusiestHours() async {
        let mockRepo = MockCRMRepository()
        let vm = CRMViewModel(crmProtocol: mockRepo)
        
        var components = DateComponents()
        components.hour = 14 // Jam 2 Siang
        let date2PM = Calendar.current.date(from: components)!
        
        let cust = Customer(name: "Pelanggan C", phoneNumber: "3", totalSpent: 10, visitHistory: [date2PM, date2PM])
        _ = try? await mockRepo.addCustomer(cust)
        
        await vm.loadCustomers(storeId: "S1")
        
        #expect(vm.busiestHours[14] == 2) // Jam 2 siang harus tercatat 2 kali kunjungan
    }
}
