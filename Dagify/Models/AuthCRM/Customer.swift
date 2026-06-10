//
//  CustomerModel.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import FirebaseFirestore
import Foundation

struct Customer: Identifiable, Codable, Equatable {

    // MARK: - Properties
    @DocumentID public var id: String?
    var storeId: String
    var branchId: String?

    var name: String
    var phoneNumber: String
    var totalSpent: Double
    var visitHistory: [Date]

    // MARK: - Computed Properties
    /// Menentukan status loyalitas pelanggan (Syarat: Lebih dari atau sama dengan threshold yang ditentukan toko)
    func isLoyal(threshold: Int) -> Bool {
        return visitHistory.count >= threshold
    }

    // MARK: - Initialization
    init(
        id: String? = nil,
        storeId: String,
        branchId: String? = nil,
        name: String,
        phoneNumber: String,
        totalSpent: Double,
        visitHistory: [Date]
    ) {
        self.id = id
        self.storeId = storeId
        self.branchId = branchId
        self.name = name
        self.phoneNumber = phoneNumber
        self.totalSpent = totalSpent
        self.visitHistory = visitHistory
    }
}
