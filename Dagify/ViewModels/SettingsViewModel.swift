//
//  SettingsViewModel.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 04/06/26.
//

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
        /// Only show loading state if the store data is empty. Otherwise, perform a silent background refresh.
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

            /// Optimistically add the new branch to the local list.
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

