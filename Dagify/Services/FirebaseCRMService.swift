//
//  FirebaseCRMService.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class FirebaseCRMService: CRMProtocol {
    private let db = Firestore.firestore()

     init() {}

     func addCustomer(_ customer: Customer) async throws -> Bool {
        let ref = db.collection("customers").document()
        try ref.setData(from: customer)
        return true
    }

     func fetchCustomers(for storeId: String) async throws -> [Customer] {
        let snapshot = try await db.collection("customers")
            .whereField("storeId", isEqualTo: storeId)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: Customer.self) }
    }

     func recordNewVisit(customerId: String, spent: Double, date: Date)
        async throws -> Bool
    {
        let ref = db.collection("customers").document(customerId)

        try await ref.updateData([
            "totalSpent": FieldValue.increment(spent),
            "visitHistory": FieldValue.arrayUnion([date]),
        ])
        return true
    }
}
