//
//  Customer.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import FirebaseFirestore
import Foundation

struct Customer: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let name: String
    let phoneNumber: String
    var totalSpent: Double
    var visitHistory: [Date]

    var isLoyal: Bool {
        return visitHistory.count >= 5
    }
}
