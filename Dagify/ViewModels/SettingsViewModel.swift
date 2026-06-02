import Foundation
import Observation

@MainActor
@Observable
class SettingsViewModel {
    var currentStore: Store? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private let storeProtocol: StoreProtocol

    init(storeProtocol: StoreProtocol) {
        self.storeProtocol = storeProtocol
    }

    func loadStore(storeId: String) async {
        // ✅ UX FIX: Hanya tampilkan "Memuat..." jika data toko masih kosong.
        // Jika sudah ada, refresh diam-diam di background (Silent Refresh).
        if currentStore == nil {
            isLoading = true
        }

        do {
            let fetchedStore = try await storeProtocol.fetchStore(
                storeId: storeId
            )
            self.currentStore = fetchedStore
        } catch {
            if currentStore == nil {
                errorMessage = "Gagal memuat informasi toko."
            }
        }
        isLoading = false
    }

    func createNewBranch(
        storeId: String,
        branchName: String,
        branchAddress: String
    ) async -> Branch? {
        guard !branchName.isEmpty else {
            errorMessage = "Nama cabang tidak boleh kosong."
            return nil
        }
        isLoading = true
        let newBranch = Branch(
            id: "B-\(UUID().uuidString.prefix(6))",
            name: branchName,
            address: branchAddress.isEmpty ? "Belum Diatur" : branchAddress
        )

        do {
            _ = try await storeProtocol.addBranch(
                storeId: storeId,
                branch: newBranch
            )

            // ✅ OPTIMISTIC UPDATE: Langsung tambahkan ke list lokal
            if currentStore != nil {
                currentStore!.branches.append(newBranch)
            }

            isLoading = false
            return newBranch
        } catch {
            errorMessage =
                "Gagal menambah cabang: \(error.localizedDescription)"
            isLoading = false
            return nil
        }
    }
}
