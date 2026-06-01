//
//  MasterDataViewModelTests.swift
//  DagifyTests
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Testing
import Foundation

@testable import Dagify

@MainActor
struct MasterDataViewModelTests {
    
    @Test("1. Validasi Tipe Data Input Master Data")
    func testCreateProductValidation() async {
        let mockOp = MockOperationalRepository()
        let viewModel = MasterDataViewModel(operationalProtocol: mockOp)
        
        await viewModel.createProduct(name: "Ayam Goreng", priceString: "25000", storeId: "S-1")
        #expect(viewModel.isSuccess == true, "Produk dengan harga valid gagal disimpan")
        #expect(viewModel.errorMessage == nil)
        
        viewModel.isSuccess = false
        await viewModel.createProduct(name: "Es Teh", priceString: "Lima Ribu", storeId: "S-1")
        #expect(viewModel.isSuccess == false, "Sistem kebobolan menyimpan harga berbentuk huruf")
        #expect(viewModel.errorMessage != nil, "Pesan error validasi tidak muncul")
    }
}
