//
//  CRMRepository.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation

protocol CRMRepository {
    func fetchCustomers() async throws -> [Customer]
}
