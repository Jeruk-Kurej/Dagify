//
//  CRMRepository.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation

protocol CRMRepository {
    func addCustomer(_ customer: Customer) async throws -> Bool
    func fetchCustomers(for storeId: String) async throws -> [Customer]
    func recordNewVisit(customerId: String, spent: Double, date: Date) async throws -> Bool
}
