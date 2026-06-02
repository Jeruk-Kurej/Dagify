import SwiftUI
import Charts // ✅ WAJIB UNTUK GRAFIK

struct CRMView: View {
    var viewModel: CRMViewModel
    let storeId: String
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Metrik Retensi
                    HStack(spacing: 16) {
                        FinancialBox(title: "Total Pelanggan", amount: Double(viewModel.customers.count), color: Color(hex: "#00A3A3"), icon: "person.3.fill", isCurrency: false)
                        FinancialBox(title: "Pelanggan Setia (Loyal)", amount: Double(viewModel.loyalCustomers.count), color: Color(hex: "#F59E0B"), icon: "star.circle.fill", isCurrency: false)
                    }.padding(.horizontal)

                    // ✅ GRAFIK SEGMENTASI WAKTU (REQUIREMENT C)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Grafik Jam Sibuk Kunjungan")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#111827"))
                        
                        VStack {
                            if viewModel.peakHoursData.isEmpty {
                                Text("Belum ada data kunjungan yang cukup.").foregroundColor(.gray).padding()
                            } else {
                                Chart(viewModel.peakHoursData) { item in
                                    BarMark(
                                        x: .value("Jam", item.label),
                                        y: .value("Total Kunjungan", item.count)
                                    )
                                    .foregroundStyle(Color(hex: "#00A3A3").gradient)
                                    .cornerRadius(4)
                                }
                                .frame(height: 200)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
                    }.padding(.horizontal)

                    // Daftar Profil Pelanggan
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Direktori Pelanggan")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#111827"))
                        
                        if viewModel.isLoading {
                            ProgressView().frame(maxWidth: .infinity).padding()
                        } else if viewModel.customers.isEmpty {
                            ContentUnavailableView("CRM Kosong", systemImage: "person.crop.circle.badge.questionmark", description: Text("Catat nomor HP pelanggan di layar Kasir."))
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.customers, id: \.id) { customer in
                                    CustomerCardView(customer: customer)
                                }
                            }
                        }
                    }.padding(.horizontal)
                }.padding(.vertical)
            }
            .background(Color(hex: "#F9FAFB"))
            .navigationTitle("CRM")
            .onAppear { Task { await viewModel.loadCustomers(storeId: storeId) } }
            .refreshable { await viewModel.loadCustomers(storeId: storeId) }
        }
    }
}
