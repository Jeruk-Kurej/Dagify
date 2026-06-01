//
//  MasterDataViewModel.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
class MasterDataViewModel {
    var isSuccess: Bool = false
    var errorMessage: String? = nil
    let operationalProtocol: OperationalProtocol
    
    init(operationalProtocol: OperationalProtocol) { self.operationalProtocol = operationalProtocol }
    
    func createProduct(name: String, priceString: String, storeId: String) async {
        guard let price = Double(priceString) else { errorMessage = "Harga harus berupa angka valid"; return }
        
        let product = Product(id: nil, name: name, price: price, category: "Menu Kasir", imageURL: nil, isAvailable: true, recipe: [])
        _ = try? await operationalProtocol.addProduct(product, storeId: storeId)
        isSuccess = true
    }

    func createIngredient(name: String, stockStr: String, unit: String, costStr: String, branchId: String) async {
        guard let stock = Double(stockStr.replacingOccurrences(of: ",", with: ".")), let cost = Double(costStr) else {
            errorMessage = "Format angka untuk stok/harga salah."
            return
        }
        
        let ingredient = Ingredient(id: nil, name: name, currentStock: stock, unit: unit, expiryDate: nil, minimumStockWarning: 5, costPerUnit: cost)
        _ = try? await operationalProtocol.addIngredient(ingredient, branchId: branchId)
        isSuccess = true
    }
}
