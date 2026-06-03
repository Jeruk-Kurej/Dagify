import SwiftUI

struct CustomerDetailSheetView: View {
    var customer: Customer
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Informasi Pelanggan")) {
                    LabeledContent("Nama", value: customer.name)
                    LabeledContent("No. Handphone", value: customer.phoneNumber)
                    LabeledContent("Total Pembelanjaan", value: customer.totalSpent.toRupiah())
                    LabeledContent("Status", value: customer.isLoyal ? "Pelanggan Setia (Loyal)" : "Reguler")
                }
                
                Section(header: Text("Riwayat Transaksi & Kunjungan")) {
                    if customer.visitHistory.isEmpty {
                        Text("Belum ada riwayat belanja.")
                            .foregroundColor(.gray)
                    } else {
                        // Mengurutkan dari transaksi paling baru (atas) ke paling lama (bawah)
                        ForEach(customer.visitHistory.sorted(by: >), id: \.self) { date in
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "#00A3A3").opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "bag.fill")
                                        .foregroundColor(Color(hex: "#00A3A3"))
                                        .font(.title3)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Transaksi Kasir")
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(hex: "#111827"))
                                    
                                    // Menampilkan Hari, Tanggal, dan Jam belanja
                                    Text(date.formatted(date: .complete, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "#6B7280"))
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(hex: "#F9FAFB"))
            .navigationTitle("Detail Riwayat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    CustomerDetailSheetView(customer: Customer(
        id: "1",
        storeId: "S-1",
        branchId: "B-1",
        name: "Budi",
        phoneNumber: "081234567890",
        totalSpent: 150000,
        visitHistory: [Date(), Date().addingTimeInterval(-86400)]
    ))
}
