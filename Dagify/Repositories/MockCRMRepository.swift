//
//  MockCRMRepository.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation

public class MockCRMRepository: CRMRepository {
    public var shouldThrowError = false
    public var customers: [Customer] = []

    public init() {}

    public func addCustomer(_ customer: Customer) async throws -> Bool {
        var newCustomer = customer
        if newCustomer.id == nil { newCustomer.id = UUID().uuidString }
        customers.append(newCustomer)
        return true
    }

    public func fetchCustomers(for storeId: String) async throws -> [Customer] {
        if shouldThrowError { throw NSError(domain: "MockCRM", code: 500) }
        return customers
    }

    public func recordNewVisit(customerId: String, spent: Double, date: Date)
        async throws -> Bool
    {
        if let index = customers.firstIndex(where: { $0.id == customerId }) {
            customers[index].totalSpent += spent
            customers[index].visitHistory.append(date)
            return true
        }
        return false
    }
}
