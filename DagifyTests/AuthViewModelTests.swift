//
//  AuthViewModelTests.swift
//  DagifyTests
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Testing
import Foundation
@testable import Dagify

@Suite("AuthViewModel Tests")
struct AuthViewModelTests {
    
    @Test @MainActor func testLoginSuccessfully() async throws {
        let mockRepo = MockAuthRepository()
        let vm = AuthViewModel(repo: mockRepo)
        
        await vm.login(email: "owner@dagify.com", password: "password123")
        
        #expect(vm.errorMessage == nil)
        #expect(vm.isLoading == false)
    }
    
    @Test @MainActor func testLoginFailsWithEmptyFields() async throws {
        let mockRepo = MockAuthRepository()
        let vm = AuthViewModel(repo: mockRepo)
        
        await vm.login(email: "", password: "")
        
        #expect(vm.errorMessage != nil)
    }
}
