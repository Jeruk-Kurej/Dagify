//
//  MockCRMRepository.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//


import Foundation

class MockCRMRepository: CRMProtocol {

    // MARK: - Mock State
    var shouldThrowError = false
    var customers: [Customer] = []

    // MARK: - CRMProtocol Implementation

    func addCustomer(_ customer: Customer) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        customers.append(customer)
        return true
    }

    func fetchCustomers(for storeId: String) async throws -> [Customer] {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        return customers.filter { $0.storeId == storeId }
    }

    func recordNewVisit(customerId: String, spent: Double, date: Date)
        async throws -> Bool
    {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        if let index = customers.firstIndex(where: { $0.id == customerId }) {
            customers[index].totalSpent += spent
            customers[index].visitHistory.append(date)
            return true
        }
        return false
    }
}
