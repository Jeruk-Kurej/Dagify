//
//  AuthCRMViewModelTests.swift
//  DagifyTests
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation
import Testing

@testable import Dagify

@Suite("AuthViewModel Swift Tests")
struct AuthViewModelTests {

    @Test @MainActor func testLoginSuccessfully() async throws {
        let mockRepo = MockAuthRepository()
        let vm = AuthViewModel(authRepo: mockRepo)

        // Memastikan awal State kosong
        #expect(vm.isAuthenticated == false)

        await vm.login(
            email: "bcarlielukito@student.ciputra.ac.id",
            password: "password123"
        )

        #expect(vm.isAuthenticated == true)
        #expect(vm.currentUser?.storeId == "S-1")
        #expect(vm.errorMessage == nil)
    }

    @Test @MainActor func testLoginFails() async throws {
        let mockRepo = MockAuthRepository()
        mockRepo.shouldThrowError = true
        let vm = AuthViewModel(authRepo: mockRepo)

        await vm.login(email: "wrong@email.com", password: "wrong")

        #expect(vm.isAuthenticated == false)
        #expect(vm.errorMessage != nil)
    }
    
    @Test @MainActor func testRegisterSuccessfullyCreatesUserAndStore() async throws {
            let mockRepo = MockAuthRepository()
            let vm = AuthViewModel(authRepo: mockRepo)
            
            await vm.register(
                email: "bcarlielukito@student.ciputra.ac.id",
                password: "securepassword",
                storeName: "Kopi Ciputra",
                branchName: "Pusat Surabaya"
            )
            
            #expect(vm.isAuthenticated == true)
            #expect(vm.currentUser != nil)
            #expect(mockRepo.registeredStore != nil)
            #expect(mockRepo.registeredStore?.name == "Kopi Ciputra")
            #expect(mockRepo.registeredStore?.branches.count == 1)
            #expect(vm.errorMessage == nil)
        }
        
        @Test @MainActor func testRegisterFailsEmptyFields() async throws {
            let mockRepo = MockAuthRepository()
            let vm = AuthViewModel(authRepo: mockRepo)
            
            await vm.register(email: "test@test.com", password: "pass", storeName: "", branchName: "")
            
            #expect(vm.isAuthenticated == false)
            #expect(vm.errorMessage == "Semua kolom pendaftaran wajib diisi.")
        }
}

@Suite("CRMViewModel Swift Tests")
struct CRMViewModelTests {

    let testDate = Date()

    @Test @MainActor func testLoyalCustomerPercentage() async throws {
        let mockRepo = MockCRMRepository()

        // 1 Pelanggan Loyal (5 kunjungan), 1 Pelanggan Biasa (1 kunjungan)
        mockRepo.customers = [
            Customer(
                id: "C-1",
                name: "Budi",
                phoneNumber: "081",
                totalSpent: 100000,
                visitHistory: [
                    testDate, testDate, testDate, testDate, testDate,
                ]
            ),
            Customer(
                id: "C-2",
                name: "Andi",
                phoneNumber: "082",
                totalSpent: 20000,
                visitHistory: [testDate]
            ),
        ]

        let vm = CRMViewModel(crmRepo: mockRepo)
        await vm.loadCustomers(storeId: "S-1")

        // Dari 2 orang, 1 orang loyal = 50%
        #expect(vm.loyalCustomerPercentage == 50.0)
    }

    @Test @MainActor func testBusiestHoursAnalytics() async throws {
        let mockRepo = MockCRMRepository()
        let calendar = Calendar.current

        // Set kunjungan jam 14.00 dan jam 19.00
        let date2PM = calendar.date(
            bySettingHour: 14,
            minute: 0,
            second: 0,
            of: Date()
        )!
        let date7PM = calendar.date(
            bySettingHour: 19,
            minute: 0,
            second: 0,
            of: Date()
        )!

        mockRepo.customers = [
            Customer(
                id: "C-1",
                name: "Budi",
                phoneNumber: "081",
                totalSpent: 50000,
                visitHistory: [date2PM, date2PM, date7PM]
            )
        ]

        let vm = CRMViewModel(crmRepo: mockRepo)
        await vm.loadCustomers(storeId: "S-1")

        let heatmap = vm.busiestHours
        #expect(heatmap[14] == 2)  // Jam 2 Siang ada 2 kunjungan
        #expect(heatmap[19] == 1)  // Jam 7 Malam ada 1 kunjungan
    }
}
