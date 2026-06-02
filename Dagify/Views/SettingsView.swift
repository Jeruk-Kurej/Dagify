import SwiftUI

struct SettingsView: View {
    var authViewModel: AuthViewModel
    let storeId: String
    @Binding var activeBranchId: String

    // ✅ KUNCI UTAMA: ViewModel diamankan di dalam @State agar
    // tidak hancur (amnesia) saat MainAppView melakukan re-render.
    @State private var viewModel: SettingsViewModel

    @State private var showingAddBranch = false
    @State private var newBranchName = ""
    @State private var newBranchAddress = ""

    // ✅ Custom Init (Dependency Injection) yang sangat SOLID
    init(
        authViewModel: AuthViewModel,
        storeProtocol: StoreProtocol,
        storeId: String,
        activeBranchId: Binding<String>
    ) {
        self.authViewModel = authViewModel
        self.storeId = storeId
        self._activeBranchId = activeBranchId
        // Inisialisasi awal sekali saja seumur hidup View ini
        self._viewModel = State(
            wrappedValue: SettingsViewModel(storeProtocol: storeProtocol)
        )
    }

    var body: some View {
        NavigationStack {
            List {
                // Section 1: Profil Toko
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#00A3A3").opacity(0.15))
                                .frame(width: 50, height: 50)
                            Image(systemName: "storefront.fill")
                                .font(.title2)
                                .foregroundColor(Color(hex: "#00A3A3"))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.currentStore?.name ?? "Memuat...")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#111827"))
                            Text("Store ID: \(storeId)")
                                .font(.caption)
                                .foregroundColor(Color(hex: "#6B7280"))
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Section 2: Manajemen Multi-Cabang
                Section {
                    if let store = viewModel.currentStore {
                        ForEach(store.branches, id: \.id) { branch in
                            let isActive = activeBranchId == branch.id

                            Button(action: {
                                // Jeda mikro agar animasi tombol selesai ditekan
                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + 0.15
                                ) {
                                    activeBranchId = branch.id
                                }
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(branch.name)
                                            .font(.body)
                                            .fontWeight(
                                                isActive ? .bold : .regular
                                            )
                                            .foregroundColor(
                                                isActive
                                                    ? Color(hex: "#9CA3AF")
                                                    : Color(hex: "#111827")
                                            )
                                        Text(branch.address)
                                            .font(.caption)
                                            .foregroundColor(
                                                Color(hex: "#9CA3AF")
                                            )
                                    }
                                    Spacer()

                                    if isActive {
                                        Text("Sedang Aktif")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(Color(hex: "#E5E7EB"))
                                            .foregroundColor(
                                                Color(hex: "#6B7280")
                                            )
                                            .clipShape(Capsule())
                                    } else {
                                        Text("Pilih")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(
                                                Color(hex: "#00A3A3")
                                            )
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                Color(hex: "#00A3A3").opacity(
                                                    0.1
                                                )
                                            )
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(isActive)
                            .listRowBackground(
                                isActive
                                    ? Color(hex: "#F3F4F6")
                                    : Color(hex: "#FFFFFF")
                            )
                        }
                    }

                    Button(action: { showingAddBranch = true }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView().padding(.trailing, 8)
                                Text("Memproses...").foregroundColor(
                                    Color(hex: "#6B7280")
                                )
                            } else {
                                Image(systemName: "plus.circle.fill")
                                Text("Buka Cabang Baru").fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(Color(hex: "#00A3A3"))
                    }
                    .disabled(viewModel.isLoading)

                    // Indikator jika Error Firebase terjadi
                    if let err = viewModel.errorMessage {
                        Text(err).font(.caption).foregroundColor(
                            Color(hex: "#EF4444")
                        )
                    }

                } header: {
                    Text("Daftar Cabang")
                } footer: {
                    Text(
                        "Pilih cabang untuk mengelola Dasbor, Kasir, Arus Kas, dan Gudang di lokasi tersebut secara real-time."
                    )
                }

                // Section 3: Logout
                Section {
                    Button(action: { authViewModel.logout() }) {
                        HStack {
                            Spacer()
                            Text("Keluar (Logout)")
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#EF4444"))
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Pengaturan")
            .listStyle(.insetGrouped)
            .background(Color(hex: "#F9FAFB").ignoresSafeArea())
            .scrollContentBackground(.hidden)
            .onAppear {
                Task { await viewModel.loadStore(storeId: storeId) }
            }
            .alert("Buka Cabang Baru", isPresented: $showingAddBranch) {
                TextField("Nama Cabang", text: $newBranchName)
                TextField("Alamat", text: $newBranchAddress)
                Button("Batal", role: .cancel) {
                    newBranchName = ""
                    newBranchAddress = ""
                }
                Button("Simpan") {
                    Task {
                        if let newBranch = await viewModel.createNewBranch(
                            storeId: storeId,
                            branchName: newBranchName,
                            branchAddress: newBranchAddress
                        ) {
                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + 0.2
                            ) {
                                activeBranchId = newBranch.id
                            }
                            newBranchName = ""
                            newBranchAddress = ""
                        }
                    }
                }
            } message: {
                Text("Masukkan detail cabang baru Anda.")
            }
        }
    }
}

#Preview {
    SettingsView(
        authViewModel: AuthViewModel(authProtocol: MockAuthRepository()),
        storeProtocol: MockOperationalRepository(),
        storeId: "S-1",
        activeBranchId: .constant("B-1")
    )
}
