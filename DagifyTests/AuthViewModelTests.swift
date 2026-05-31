//
//  AuthViewModelTests.swift
//  DagifyTests
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Testing
import Foundation
@testable import Dagify

@Suite("Auth ViewModel Tests")
@MainActor
struct AuthViewModelTests {
    
    @Test("Test Login Sukses")
    func testLoginSuccess() async {
        let mockRepo = MockAuthRepository()
        let vm = AuthViewModel(authProtocol: mockRepo)
        
        await vm.login(email: "test@dagify.com", password: "password123")
        
        #expect(vm.isAuthenticated == true)
        #expect(vm.currentUser?.email == "test@dagify.com")
        #expect(vm.errorMessage == nil)
    }
}
