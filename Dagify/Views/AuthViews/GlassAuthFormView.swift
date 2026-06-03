//
//  GlassAuthFormView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 03/06/26.
//

import SwiftUI

struct GlassAuthFormView: View {
    // MARK: - Properties & Bindings
    var viewModel: AuthViewModel
    
    @Binding var isLoginMode: Bool
    @Binding var email: String
    @Binding var password: String
    @Binding var storeName: String
    @Binding var branchName: String
    @Binding var showAuthForm: Bool
    
    var body: some View {
        VStack {
            // MARK: - Header (Back Button)
            HStack {
                Button(action: { withAnimation { showAuthForm = false } }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Kembali")
                            .font(.system(size: 17))
                    }
                    .foregroundColor(Color(hex: "#00A3A3"))
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            
            Spacer()
            
            // MARK: - Input Form Container
            VStack(spacing: 24) {
                Text(isLoginMode ? "Masuk Sistem" : "Buat Akun")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#00A3A3"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 16) {
                    MinimalField(
                        icon: "envelope",
                        placeholder: "Alamat Email",
                        hint: "email",
                        text: $email
                    )
                    .keyboardType(.emailAddress)
                    
                    MinimalSecureField(
                        icon: "lock",
                        placeholder: "Kata Sandi",
                        hint: "password",
                        text: $password
                    )
                    
                    if !isLoginMode {
                        MinimalField(
                            icon: "building.2",
                            placeholder: "Nama Toko",
                            hint: "Toko Cth: Kopi Kenangan",
                            text: $storeName
                        )
                        MinimalField(
                            icon: "storefront",
                            placeholder: "Cabang",
                            hint: "Cabang Cth: Pusat",
                            text: $branchName
                        )
                    }
                }
                .animation(.easeInOut, value: isLoginMode)
                
                // MARK: - Error Handling
                if let err = viewModel.errorMessage {
                    Text(err)
                        .font(.caption)
                        .foregroundColor(Color(hex: "#EF4444"))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // MARK: - Actions
                Button(action: handleAuthAction) {
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(isLoginMode ? "Lanjutkan" : "Daftar Sekarang")
                                .font(.headline)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#00A3A3"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color(hex: "#00A3A3").opacity(0.6), radius: 8, x: 0, y: 0)
                }
                .padding(.top, 8)
                
                Button(action: { withAnimation { isLoginMode.toggle() } }) {
                    Text(isLoginMode ? "Belum punya akun? **Daftar**" : "Sudah punya akun? **Masuk**")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
    
    // MARK: - Methods
    private func handleAuthAction() {
        Task {
            if isLoginMode {
                await viewModel.login(email: email, password: password)
            } else {
                await viewModel.register(
                    email: email,
                    password: password,
                    storeName: storeName,
                    branchName: branchName
                )
            }
        }
    }
}

#Preview {
    GlassAuthFormView(
        viewModel: AuthViewModel(authProtocol: MockAuthRepository()),
        isLoginMode: .constant(true),
        email: .constant(""),
        password: .constant(""),
        storeName: .constant(""),
        branchName: .constant(""),
        showAuthForm: .constant(true)
    )
}
