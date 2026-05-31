//
//  AuthViewModelTests.swift
//  DagifyTests
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Testing
import Foundation
@testable import Dagify

@Suite("Auth ViewModel Tests")
@MainActor
struct AuthViewModelTests {
    
    @Test("Test Fungsi Login Sukses")
    func testLoginSuccess() async {
        let mockRepo = MockAuthRepository()
        let vm = AuthViewModel(authProtocol: mockRepo)
        
        await vm.login(email: "test@dagify.com", password: "password123")
        
        #expect(vm.isAuthenticated == true)
        #expect(vm.currentUser?.email == "test@dagify.com")
        #expect(vm.errorMessage == nil)
    }
    
    @Test("Test Fungsi Registrasi Toko Baru Sukses")
    func testRegisterSuccess() async {
        let mockRepo = MockAuthRepository()
        let vm = AuthViewModel(authProtocol: mockRepo)
        
        await vm.register(email: "owner@dagify.com", password: "password123", storeName: "Toko A", branchName: "Cabang B")
        
        #expect(vm.isAuthenticated == true)
        #expect(vm.currentUser?.email == "owner@dagify.com")
    }
    
    @Test("Test Fungsi Logout Keluar Sistem")
    func testLogoutSuccess() async {
        let mockRepo = MockAuthRepository()
        let vm = AuthViewModel(authProtocol: mockRepo)
        
        await vm.login(email: "test@dagify.com", password: "password123")
        vm.logout() // Panggil fungsi logout
        
        #expect(vm.isAuthenticated == false)
        #expect(vm.currentUser == nil)
    }
}
