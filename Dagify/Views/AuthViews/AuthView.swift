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
            FluidBackgroundView()

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

struct WelcomeScreen: View {
    @Binding var showAuthForm: Bool

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image("Dagify_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.bottom, 20)
                .shadow(
                    color: Color.black.opacity(0.3),
                    radius: 10,
                    x: 0,
                    y: 10
                )

            Text("Dagify")
                .font(.system(size: 56, weight: .heavy, design: .rounded))
                .foregroundColor(.black)

            Text("Business Management")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Color.gray)

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
                .foregroundColor(Color(hex: "#111827"))
                .padding(.horizontal, 32)
                .padding(.vertical, 18)
                .background(Color(hex: "#FFFFFF"))
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            .padding(.bottom, 60)
        }
    }
}

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
                // Button Back sesuai standar HIG Apple terbaru berwarna Hijau (#00A3A3)
                Button(action: { withAnimation { showAuthForm = false } }) {

                    Image(systemName: "chevron.left")

                        .font(.title3.bold())

                        .foregroundColor(Color(hex: "#00A3A3"))

                        .padding(12)

                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)

            Spacer()

            // Container Form (Kotak Tembus Pandang)
            VStack(spacing: 24) {
                // Judul Berwarna Hijau
                Text(isLoginMode ? "Masuk Sistem" : "Buat Akun")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#00A3A3"))
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 16) {
                    // 🔥 Memberikan argumen 'hint' berupa teks samar/default bawaan di dalam kotak field
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
                    .shadow(
                        color: Color(hex: "#00A3A3").opacity(0.6),
                        radius: 8,
                        x: 0,
                        y: 0
                    )
                }
                .padding(.top, 8)

                Button(action: { withAnimation { isLoginMode.toggle() } }) {
                    Text(
                        isLoginMode
                            ? "Belum punya akun? **Daftar**"
                            : "Sudah punya akun? **Masuk**"
                    )
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: 24)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal, 24)

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
