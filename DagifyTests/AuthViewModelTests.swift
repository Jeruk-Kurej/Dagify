import Foundation
import Testing

@testable import Dagify

@Suite("Auth ViewModel Tests")
@MainActor
struct AuthViewModelTests {

    @Test("Skenario 1: Login Sukses")
    func testLoginSuccess() async {
        let mockRepo = MockAuthRepository()
        let vm = AuthViewModel(authProtocol: mockRepo)

        await vm.login(email: "owner@dagify.com", password: "password123")

        #expect(vm.isAuthenticated == true)
        #expect(vm.errorMessage == nil)
    }

    @Test("Skenario 2: Registrasi Gagal Karena Kolom Kosong (Unhappy Path)")
    func testRegisterFailWithEmptyFields() async {
        let mockRepo = MockAuthRepository()
        let vm = AuthViewModel(authProtocol: mockRepo)

        // Sengaja mengosongkan storeName untuk memicu error
        await vm.register(
            email: "owner@dagify.com",
            password: "123",
            storeName: "",
            branchName: "Pusat"
        )

        #expect(
            vm.isAuthenticated == false,
            "Sistem kebobolan, akun berhasil dibuat padahal data tidak lengkap!"
        )
        #expect(
            vm.errorMessage == "Semua kolom pendaftaran wajib diisi.",
            "Pesan error tidak sesuai ekspektasi."
        )
    }

    @Test("Skenario 3: Logout Sukses")
    func testLogoutSuccess() async {
        let mockRepo = MockAuthRepository()
        let vm = AuthViewModel(authProtocol: mockRepo)

        await vm.login(email: "test@dagify.com", password: "password123")
        vm.logout()

        #expect(vm.isAuthenticated == false)
        #expect(vm.currentUser == nil)
    }
}
