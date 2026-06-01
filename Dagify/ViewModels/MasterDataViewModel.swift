//
//  MasterDataViewModel.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import Observation

@MainActor
@Observable
class MasterDataViewModel {
    var isSuccess: Bool = false
    var errorMessage: String? = nil
    let operationalProtocol: OperationalProtocol
    
    init(operationalProtocol: OperationalProtocol) { self.operationalProtocol = operationalProtocol }
    
    func createProduct(name: String, priceString: String, storeId: String) async {
        guard let price = Double(priceString) else { errorMessage = "Harga harus berupa angka valid"; return }
        let product = Product(name: name, price: price, category: "Menu", isAvailable: true, recipe: [])
        _ = try? await operationalProtocol.addProduct(product, storeId: storeId)
        isSuccess = true
    }
}
