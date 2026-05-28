//
//  DashboardViewModel.swift
//  DagifyTests
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Testing
import Foundation
@testable import Dagify

@Suite("DashboardViewModel Tests")
struct DashboardViewModelTests {
    
    @Test @MainActor func testLoadDashboardSummary() async throws {
        let mockRepo = MockOperationalRepository()
        let vm = DashboardViewModel(repo: mockRepo)
        
        await vm.loadDashboardData(branchId: "B-1")
        
        #expect(vm.errorMessage == nil)
        #expect(vm.isLoading == false)
    }
}
