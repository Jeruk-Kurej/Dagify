import SwiftUI
import Charts

struct CRMView: View {
    var viewModel: CRMViewModel
    let storeId: String
    
    @State private var activeSheet: CRMSheetType? = nil
    
    // 🔥 STATE BARU: Untuk melacak pelanggan mana yang sedang diklik
    @State private var selectedCustomer: Customer? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 16) {
                        Button(action: { activeSheet = .total }) {
                            FinancialBox(title: "Total Pelanggan", amount: Double(viewModel.customers.count), color: Color(hex: "#00A3A3"), icon: "person.3.fill", isCurrency: false)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: { activeSheet = .loyal }) {
                            FinancialBox(title: "Pelanggan Setia (Loyal)", amount: Double(viewModel.loyalCustomers.count), color: Color(hex: "#F59E0B"), icon: "star.circle.fill", isCurrency: false)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }.padding(.horizontal)
                    
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
                                    
                                    // 🔥 UBAH: Bungkus Card dengan Button agar bisa ditekan
                                    Button(action: {
                                        selectedCustomer = customer
                                    }) {
                                        CustomerCardView(customer: customer)
                                    }
                                    .buttonStyle(PlainButtonStyle()) // Menghapus efek biru bawaan list/button
                                    
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
            .sheet(item: $activeSheet) { sheetType in
                CRMDashboardSheetView(viewModel: viewModel, sheetType: sheetType)
                    .presentationDetents([.medium, .large])
            }
            // 🔥 TAMBAHAN: Memunculkan Pop Up Riwayat Pelanggan saat box diklik
            .sheet(item: $selectedCustomer) { customer in
                CustomerDetailSheetView(customer: customer)
                    .presentationDetents([.fraction(0.7), .large]) // Pop-up bisa 70% atau ditarik Full Screen
            }
        }
    }
}

struct CRMDashboardSheetView: View {
    var viewModel: CRMViewModel
    var sheetType: CRMSheetType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                let unknownCount = viewModel.customers.filter { $0.branchId == nil || $0.branchId == "" }.count
                let unknownLoyalCount = viewModel.customers.filter { ($0.branchId == nil || $0.branchId == "") && $0.isLoyal }.count
                
                Section(header: Text("Rincian per Cabang")) {
                    ForEach(viewModel.storeBranches, id: \.id) { branch in
                        HStack {
                            Text(branch.name)
                                .font(.body)
                                .foregroundColor(Color(hex: "#111827"))
                            Spacer()
                            Text("\(viewModel.getCustomerCount(for: branch.id, isLoyalOnly: sheetType == .loyal)) Orang")
                                .font(.headline)
                                .foregroundColor(sheetType == .total ? Color(hex: "#00A3A3") : Color(hex: "#F59E0B"))
                        }
                    }
                    
                    if sheetType == .total ? (unknownCount > 0) : (unknownLoyalCount > 0) {
                        HStack {
                            Text("Tidak Diketahui (Data Lama)")
                                .font(.body)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(sheetType == .total ? unknownCount : unknownLoyalCount) Orang")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.white)
            .navigationTitle(sheetType == .total ? "Total Pelanggan" : "Pelanggan Setia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") { dismiss() }
                }
            }
        }
    }
}

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
            .background(Color(hex: "#F9FAFB")) // Background abu-abu muda ala Dagify
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
    let mockCRM = MockCRMRepository()
    let mockOp = MockOperationalRepository()
    mockOp.dummyStore = Store(id: "S-1", name: "Dagify Test Store", branches: [Branch(id: "B-1", name: "Pusat", address: "")])
    mockCRM.customers = [
        Customer(id: "1", storeId: "S-1", branchId: "B-1", name: "Budi", phoneNumber: "081", totalSpent: 100000, visitHistory: [Date()]),
        Customer(id: "2", storeId: "S-1", branchId: "B-1", name: "Susi", phoneNumber: "082", totalSpent: 200000, visitHistory: [Date(), Date(), Date(), Date(), Date()])
    ]
    return CRMView(viewModel: CRMViewModel(crmProtocol: mockCRM, storeProtocol: mockOp), storeId: "S-1")
}
