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
                            insertion: .opacity.combined(with: .scale(scale: 0.9)),
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
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    )
                )
            }
        }
        .environment(\.colorScheme, .dark)
        .animation(.spring(response: 0.7, dampingFraction: 0.8), value: showAuthForm)
    }
}

struct WelcomeScreen: View {
    @Binding var showAuthForm: Bool
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            // ✅ UPDATE: Menggunakan Logo Resmi Dagify
            Image("Dagify_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.bottom, 20)
                // Memberikan sedikit bayangan agar menonjol di atas background gelap
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10)
            
            Text("Dagify")
                .font(.system(size: 56, weight: .heavy, design: .rounded))
                .foregroundColor(Color(hex: "#F9FAFB"))
            
            Text("Business Management")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Color(hex: "#F9FAFB").opacity(0.8))
            
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
                Button(action: { withAnimation { showAuthForm = false } }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.bold())
                        .foregroundColor(Color(hex: "#F9FAFB").opacity(0.8))
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
                    .foregroundColor(Color(hex: "#F9FAFB"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 16) {
                    MinimalField(icon: "envelope.fill", placeholder: "Alamat Email", text: $email)
                        .keyboardType(.emailAddress)
                    MinimalSecureField(icon: "lock.fill", placeholder: "Kata Sandi", text: $password)
                    
                    if !isLoginMode {
                        MinimalField(icon: "building.2.fill", placeholder: "Nama Toko (Cth: Kenangan)", text: $storeName)
                        MinimalField(icon: "storefront.fill", placeholder: "Cabang (Cth: Pusat)", text: $branchName)
                    }
                }
                .animation(.easeInOut, value: isLoginMode)
                
                if let err = viewModel.errorMessage {
                    Text(err)
                        .font(.caption)
                        .foregroundColor(Color(hex: "#EF4444"))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button(action: handleAuthAction) {
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView().tint(Color(hex: "#111827"))
                        } else {
                            Text(isLoginMode ? "Lanjutkan" : "Daftar Sekarang")
                                .font(.headline)
                        }
                    }
                    .foregroundColor(Color(hex: "#111827"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#FFFFFF"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.top, 8)
                
                Button(action: { withAnimation { isLoginMode.toggle() } }) {
                    Text(isLoginMode ? "Belum punya akun? **Daftar**" : "Sudah punya akun? **Masuk**")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#F9FAFB").opacity(0.8))
                }
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .shadow(color: Color.black.opacity(0.3), radius: 30, x: 0, y: 15)
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
                await viewModel.register(email: email, password: password, storeName: storeName, branchName: branchName)
            }
        }
    }
}
