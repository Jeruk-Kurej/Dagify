//
//  AuthView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 31/05/26.
//

//
//  AuthView.swift
//  Dagify
//
//  Revisi: Menggunakan Color.swift bawaan proyek (DRY Principle)
//

import SwiftUI

struct AuthView: View {
    var viewModel: AuthViewModel

    @State private var showAuthForm = false
    @State private var isLoginMode = true

    @State private var email = ""
    @State private var password = ""
    @State private var storeName = ""
    @State private var branchName = ""

    var body: some View {
        ZStack {
            // 1. ANIMATED FLUID BACKGROUND (Pakai warna tema Anda)
            FluidBackgroundView()

            // 2. KONTEN UTAMA
            if !showAuthForm {
                WelcomeScreen(showAuthForm: $showAuthForm)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(
                                with: .scale(scale: 0.9)
                            ),
                            removal: .opacity.combined(with: .scale(scale: 1.1))
                        )
                    )
            } else {
                GlassAuthForm(
                    viewModel: viewModel,
                    isLoginMode: $isLoginMode,
                    email: $email,
                    password: $password,
                    storeName: $storeName,
                    branchName: $branchName,
                    showAuthForm: $showAuthForm
                )
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom).combined(
                            with: .opacity
                        ),
                        removal: .opacity
                    )
                )
            }
        }
        .environment(\.colorScheme, .dark)
        .animation(
            .spring(response: 0.7, dampingFraction: 0.8),
            value: showAuthForm
        )
    }
}

// MARK: - 1. Tampilan Welcome
struct WelcomeScreen: View {
    @Binding var showAuthForm: Bool

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundColor(.white)
                .symbolEffect(.pulse, options: .repeating)
                .padding(.bottom, 20)

            Text("Dagify")
                .font(.system(size: 56, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("Business Management")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))

            Spacer()

            Button(action: {
                withAnimation { showAuthForm = true }
            }) {
                HStack(spacing: 12) {
                    Text("Mulai Kelola Bisnis")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                        .font(.headline)
                }
                .foregroundColor(.themeTextPrimary)  // Teks hitam/gelap
                .padding(.horizontal, 32)
                .padding(.vertical, 18)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            .padding(.bottom, 60)
        }
    }
}

// MARK: - 2. Tampilan Form Minimalis (Glassmorphism)
struct GlassAuthForm: View {
    var viewModel: AuthViewModel
    @Binding var isLoginMode: Bool
    @Binding var email: String
    @Binding var password: String
    @Binding var storeName: String
    @Binding var branchName: String
    @Binding var showAuthForm: Bool

    var body: some View {
        VStack {
            HStack {
                Button(action: { withAnimation { showAuthForm = false } }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.bold())
                        .foregroundColor(.white.opacity(0.8))
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)

            Spacer()

            VStack(spacing: 24) {
                Text(isLoginMode ? "Masuk Sistem" : "Buat Akun")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 16) {
                    MinimalField(
                        icon: "envelope.fill",
                        placeholder: "Alamat Email",
                        text: $email
                    )
                    .keyboardType(.emailAddress)

                    MinimalSecureField(
                        icon: "lock.fill",
                        placeholder: "Kata Sandi",
                        text: $password
                    )

                    if !isLoginMode {
                        MinimalField(
                            icon: "building.2.fill",
                            placeholder: "Nama Toko (Cth: Kenangan)",
                            text: $storeName
                        )
                        MinimalField(
                            icon: "storefront.fill",
                            placeholder: "Cabang (Cth: Pusat)",
                            text: $branchName
                        )
                    }
                }
                .animation(.easeInOut, value: isLoginMode)

                if let err = viewModel.errorMessage {
                    Text(err)
                        .font(.caption)
                        .foregroundColor(.themeDestructive)  // Memakai warna error dari Color.swift
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: handleAuthAction) {
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView().tint(.themeTextPrimary)
                        } else {
                            Text(isLoginMode ? "Lanjutkan" : "Daftar Sekarang")
                                .font(.headline)
                        }
                    }
                    .foregroundColor(.themeTextPrimary)  // Teks gelap
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.top, 8)

                Button(action: { withAnimation { isLoginMode.toggle() } }) {
                    Text(
                        isLoginMode
                            ? "Belum punya akun? **Daftar**"
                            : "Sudah punya akun? **Masuk**"
                    )
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
    }

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

// MARK: - 3. Komponen Form Transparan
struct MinimalField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon).foregroundColor(.white.opacity(0.6)).frame(
                width: 20
            )
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .autocapitalization(.none)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct MinimalSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon).foregroundColor(.white.opacity(0.6)).frame(
                width: 20
            )
            SecureField(placeholder, text: $text)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 4. Background Animasi Terintegrasi dengan Color.swift
struct FluidBackgroundView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background dasar pakai tema gelap Dagify
            Color.themeTextPrimary.ignoresSafeArea()

            // Bola Cahaya 1 (Primary Dagify)
            Circle()
                .fill(Color.themePrimary.opacity(0.7))
                .frame(width: 300, height: 300)
                .blur(radius: 90)
                .offset(
                    x: isAnimating ? 150 : -150,
                    y: isAnimating ? -200 : 100
                )

            // Bola Cahaya 2 (Ungu untuk estetik mix mesh gradient sesuai referensi video Anda)
            Circle()
                .fill(Color.purple.opacity(0.7))
                .frame(width: 350, height: 350)
                .blur(radius: 120)
                .offset(
                    x: isAnimating ? -150 : 150,
                    y: isAnimating ? 200 : -150
                )

            // Bola Cahaya 3 (Highlight Dagify)
            Circle()
                .fill(Color.themeHighlight.opacity(0.6))
                .frame(width: 250, height: 250)
                .blur(radius: 100)
                .offset(x: isAnimating ? 50 : -200, y: isAnimating ? -50 : 250)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                .easeInOut(duration: 6).repeatForever(autoreverses: true)
            ) {
                isAnimating.toggle()
            }
        }
    }
}
