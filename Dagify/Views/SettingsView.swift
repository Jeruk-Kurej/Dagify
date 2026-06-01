import SwiftUI

struct SettingsView: View {
    var authViewModel: AuthViewModel
    let storeId: String
    let branchId: String

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "storefront.fill")
                            .foregroundColor(Color(hex: "#00A3A3"))
                            .font(.title2)
                            .frame(width: 40)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Informasi Toko")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#111827"))
                            Text("Store ID: \(storeId)")
                                .font(.caption)
                                .foregroundColor(Color(hex: "#6B7280"))
                            Text("Branch ID: \(branchId)")
                                .font(.caption)
                                .foregroundColor(Color(hex: "#6B7280"))
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section {
                    Button(action: {
                        authViewModel.logout()
                    }) {
                        HStack {
                            Spacer()
                            Text("Keluar (Logout)")
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#EF4444"))  // Destructive Red
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Pengaturan")
            .listStyle(.insetGrouped)
            .background(Color(hex: "#F9FAFB").ignoresSafeArea())
            .scrollContentBackground(.hidden)
        }
    }
}
