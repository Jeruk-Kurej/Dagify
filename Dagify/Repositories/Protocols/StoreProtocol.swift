import Foundation

protocol StoreProtocol {
    func fetchStore(storeId: String) async throws -> Store
    func addBranch(storeId: String, branch: Branch) async throws -> Bool
}
