import Foundation
import Testing

@testable import Dagify

@Suite("Settings ViewModel Tests")
@MainActor
struct SettingsViewModelTests {

    @Test("Fungsi: loadStore() - Skenario Berhasil")
    func testLoadStoreSuccess() async {
        let mockRepo = MockStoreRepository()
        let vm = SettingsViewModel(storeProtocol: mockRepo)

        let b1 = Branch(id: "B-1", name: "Pusat", address: "Jakarta", phone: "081")
        mockRepo.dummyStore.branches = [b1]

        await vm.loadStore(storeId: "S-1")

        #expect(vm.errorMessage == nil)
        #expect(vm.store?.name == "Dagify Test Store")
        #expect(vm.store?.branches.count == 1)
        #expect(vm.isLoading == false)
    }

    @Test("Fungsi: loadStore() - Skenario Error")
    func testLoadStoreFailure() async {
        let mockRepo = MockStoreRepository()
        let vm = SettingsViewModel(storeProtocol: mockRepo)
        mockRepo.shouldThrowError = true

        await vm.loadStore(storeId: "S-1")

        #expect(vm.store == nil)
        #expect(vm.errorMessage != nil)
        #expect(vm.isLoading == false)
    }

    @Test("Fungsi: createNewBranch() - Skenario Berhasil")
    func testCreateNewBranchSuccess() async {
        let mockRepo = MockStoreRepository()
        let vm = SettingsViewModel(storeProtocol: mockRepo)
        
        let initialBranchCount = mockRepo.dummyStore.branches.count

        await vm.createNewBranch(storeId: "S-1", name: "Cabang Bandung", address: "Bandung", phone: "082")

        #expect(vm.errorMessage == nil)
        #expect(mockRepo.dummyStore.branches.count == initialBranchCount + 1)
        #expect(mockRepo.dummyStore.branches.last?.name == "Cabang Bandung")
    }

    @Test("Fungsi: createNewBranch() - Skenario Gagal Kolom Kosong")
    func testCreateNewBranchFailureEmpty() async {
        let mockRepo = MockStoreRepository()
        let vm = SettingsViewModel(storeProtocol: mockRepo)
        
        let initialBranchCount = mockRepo.dummyStore.branches.count

        await vm.createNewBranch(storeId: "S-1", name: "", address: "Bandung", phone: "082")

        #expect(vm.errorMessage == "Nama dan alamat cabang wajib diisi.")
        #expect(mockRepo.dummyStore.branches.count == initialBranchCount)
    }
}
