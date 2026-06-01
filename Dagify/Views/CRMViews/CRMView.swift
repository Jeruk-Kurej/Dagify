import SwiftUI

struct CRMView: View {
    // ✅ MVVM: Sesuai injeksi MainAppView
    var viewModel: CRMViewModel
    let storeId: String

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Kotak Ringkasan Persentase
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Persentase Loyalitas")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#6B7280"))
                            Text(
                                String(
                                    format: "%.1f%%",
                                    viewModel.loyalCustomerPercentage
                                )
                            )
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#00A3A3"))
                        }
                        Spacer()
                        Image(systemName: "heart.fill")
                            .font(.largeTitle)
                            .foregroundColor(Color(hex: "#EF4444").opacity(0.8))
                    }
                    .padding()
                    .background(Color(hex: "#FFFFFF"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(
                        color: Color.black.opacity(0.04),
                        radius: 5,
                        x: 0,
                        y: 2
                    )
                    .padding(.horizontal)
                    .padding(.top)

                    // Daftar Member
                    VStack(alignment: .leading) {
                        Text("Daftar Member")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#111827"))
                            .padding(.horizontal)

                        if viewModel.isLoading && viewModel.customers.isEmpty {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if viewModel.customers.isEmpty {
                            ContentUnavailableView(
                                "Belum Ada Member",
                                systemImage: "person.crop.circle.badge.plus"
                            )
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.customers, id: \.id) {
                                    customer in
                                    CustomerCardView(customer: customer)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color(hex: "#F9FAFB").ignoresSafeArea())
            .navigationTitle("Pelanggan (CRM)")
            .onAppear {
                Task { await viewModel.loadCustomers(storeId: storeId) }
            }
            .refreshable {
                await viewModel.loadCustomers(storeId: storeId)
            }
        }
    }
}

#Preview {
    let previewViewModel: CRMViewModel = {
        let mockRepo = MockCRMRepository()
        let date = Date()

        mockRepo.customers = [
            Customer(
                id: "1",
                name: "Bryan Setiawan",
                phoneNumber: "0812",
                totalSpent: 450000,
                visitHistory: [date, date, date, date, date]
            ),  // Loyal
            Customer(
                id: "2",
                name: "Hanzelius",
                phoneNumber: "0898",
                totalSpent: 25000,
                visitHistory: [date]
            ),
        ]

        return CRMViewModel(crmProtocol: mockRepo)
    }()

    CRMView(viewModel: previewViewModel, storeId: "S-1")
}
