//
//  AuthView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 31/05/26.
//

import SwiftUI

struct AuthView: View {
    var viewModel: AuthViewModel
    @State private var isLoginMode = true

    @State private var email = ""
    @State private var password = ""
    @State private var storeName = ""
    @State private var branchName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.pie.bubble.fill")
                            .font(.system(size: 64)).foregroundColor(
                                .themePrimary
                            )
                        Text("Dagify Platform").font(.title2).bold()
                            .foregroundColor(.themeTextPrimary)
                        Text("Sistem POS & Analisis Keuangan UMKM").font(
                            .caption
                        ).foregroundColor(.themeTextSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center).padding(
                        .vertical
                    )
                }
                .listRowBackground(Color.clear)

                Section(header: Text("Akses Masuk Keamanan")) {
                    TextField("Alamat Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    SecureField("Kata Sandi", text: $password)
                }

                // Form input tambahan jika dalam mode pendaftaran (Register)
                if !isLoginMode {
                    Section(header: Text("Registrasi Badan Usaha / Toko")) {
                        TextField("Nama Usaha Utama", text: $storeName)
                        TextField("Nama Cabang Toko", text: $branchName)
                    }
                }

                if let err = viewModel.errorMessage {
                    Section {
                        Text(err).font(.caption).foregroundColor(
                            .themeDestructive
                        )
                    }
                }

                Section {
                    Button(action: {
                        Task {
                            if isLoginMode {
                                await viewModel.login(
                                    email: email,
                                    password: password
                                )
                            } else {
                                await viewModel.register(
                                    email: email,
                                    password: password,
                                    storeName: storeName,
                                    branchName: branchName
                                )
                            }
                        }
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text(
                                    isLoginMode
                                        ? "Masuk ke Akun" : "Daftar Toko Baru"
                                ).bold()
                            }
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.themePrimary).foregroundColor(
                        .white
                    ).disabled(viewModel.isLoading)
                }

                Section {
                    Button(action: { withAnimation { isLoginMode.toggle() } }) {
                        Text(
                            isLoginMode
                                ? "Belum punya toko? Daftarkan Usaha Anda"
                                : "Sudah terdaftar? Kembali ke Halaman Login"
                        )
                        .font(.callout).frame(
                            maxWidth: .infinity,
                            alignment: .center
                        )
                    }
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle(
                isLoginMode ? "Selamat Datang" : "Buat Akun Dagify"
            )
        }
    }
}
