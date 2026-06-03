import FirebaseFirestore
import Foundation

struct Customer: Identifiable, Codable, Equatable {
    @DocumentID public var id: String?
    public var storeId: String
    public var branchId: String? // ✅ DITAMBAHKAN: Untuk melacak di cabang mana dia mendaftar
    public let name: String
    public let phoneNumber: String
    public var totalSpent: Double
    public var visitHistory: [Date]
    
    // ✅ init dimodifikasi dengan default nil agar data lama dari Firebase tidak error/crash
    public init(id: String? = nil, storeId: String, branchId: String? = nil, name: String, phoneNumber: String, totalSpent: Double, visitHistory: [Date]) {
        self.id = id
        self.storeId = storeId
        self.branchId = branchId
        self.name = name
        self.phoneNumber = phoneNumber
        self.totalSpent = totalSpent
        self.visitHistory = visitHistory
    }
    
    public var isLoyal: Bool {
        return visitHistory.count >= 5
    }
}
