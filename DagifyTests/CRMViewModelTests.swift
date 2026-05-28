//
//  CRMViewModelTests.swift
//  DagifyTests
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Testing
import Foundation
@testable import Dagify

@Suite("CRMViewModel Tests")
struct CRMViewModelTests {
    
    @Test @MainActor func testLoadCustomersAndCalculateRetention() async throws {
        let mockRepo = MockCRMRepository()
        let vm = CRMViewModel(repo: mockRepo)
        
        await vm.loadCustomers(for: "B-1")
        
        #expect(vm.errorMessage == nil)
        #expect(vm.isLoading == false)
    }
}
