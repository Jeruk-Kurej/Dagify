import Foundation
import Testing

@testable import Dagify

@Suite("Auth ViewModel Tests")
@MainActor
struct AuthViewModelTests {

    @Test("Fungsi: login() - Skenario Berhasil")
    func testLoginSuccess() async {
        let mockRepo = MockAuthRepository()
        let vm = AuthViewModel(authProtocol: mockRepo)

        await vm.login(email: "owner@dagify.com", password: "password123")

        #expect(vm.isAuthenticated == true)
        #expect(vm.errorMessage == nil)
    }

    @Test("Fungsi: login() - Skenario Gagal (Unhappy Path)")
    func testLoginFailure() async {
        let mockRepo = MockAuthRepository()
        mockRepo.shouldThrowError = true  // Memaksa error
        let vm = AuthViewModel(authProtocol: mockRepo)

        await vm.login(email: "salah@dagify.com", password: "123")

        #expect(vm.isAuthenticated == false)
        #expect(vm.errorMessage == "Gagal login: Periksa kembali kredensial Anda.")
    }

    @Test("Fungsi: register() - Skenario Berhasil")
    func testRegisterSuccess() async {
        let mockRepo = MockAuthRepository()
        let vm = AuthViewModel(authProtocol: mockRepo)

        await vm.register(
            email: "owner@dagify.com",
            password: "123",
            storeName: "Toko Budi",
            branchName: "Pusat"
        )

        #expect(vm.isAuthenticated == true)
        #expect(vm.errorMessage == nil)
    }

    @Test("Fungsi: register() - Skenario Gagal Kolom Kosong")
    func testRegisterFailureEmptyFields() async {
        let mockRepo = MockAuthRepository()
        let vm = AuthViewModel(authProtocol: mockRepo)

        await vm.register(
            email: "owner@dagify.com",
            password: "123",
            storeName: "",
            branchName: "Pusat"
        )

        #expect(vm.isAuthenticated == false)
        #expect(vm.errorMessage == "Semua kolom pendaftaran wajib diisi.")
    }

    @Test("Fungsi: logout() - Skenario Berhasil")
    func testLogoutSuccess() async {
        let mockRepo = MockAuthRepository()
        let vm = AuthViewModel(authProtocol: mockRepo)

        await vm.login(email: "test@dagify.com", password: "password123")  // Login dulu
        vm.logout()  // Act: Logout

        #expect(vm.isAuthenticated == false)
        #expect(vm.currentUser == nil)
    }
}
