//
//  FirebaseCRMService.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import FirebaseFirestore
import Foundation

class FirebaseCRMService: CRMProtocol {

    // MARK: - Properties
    private let db = Firestore.firestore()
    private let collectionName = "customers"

    // MARK: - Initialization
    init() {}

    // MARK: - Create
    func addCustomer(_ customer: Customer) async throws -> Bool {
        guard let id = customer.id else { return false }
        let ref = db.collection(collectionName).document(id)
        try ref.setData(from: customer)
        return true
    }

    // MARK: - Read
    func fetchCustomers(for storeId: String) async throws -> [Customer] {
        let snapshot = try await db.collection(collectionName)
            .whereField("storeId", isEqualTo: storeId)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: Customer.self) }
    }

    // MARK: - Update (Business Logic)
    func recordNewVisit(customerId: String, spent: Double, date: Date)
        async throws -> Bool
    {
        let ref = db.collection(collectionName).document(customerId)

        try await ref.updateData([
            "totalSpent": FieldValue.increment(spent),
            "visitHistory": FieldValue.arrayUnion([date]),
        ])
        return true
    }
}
