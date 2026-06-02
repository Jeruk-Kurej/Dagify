import SwiftUI

struct ProductAnalyticsView: View {
    var viewModel: ProductAnalyticsViewModel
    let branchId: String

    var body: some View {
        // ✅ NavigationStack dihapus agar tidak double
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.isLoading {
                    ProgressView("Mengolah algoritma data...")
                        .frame(maxWidth: .infinity, minHeight: 300)
                } else if viewModel.orders.isEmpty {
                    ContentUnavailableView(
                        "Belum Ada Data",
                        systemImage: "chart.pie",
                        description: Text(
                            "Lakukan transaksi di Kasir terlebih dahulu."
                        )
                    )
                } else {
                    // Section: Best Sellers
                    AnalyticSection(
                        title: "Paling Laris (Best Seller)",
                        icon: "flame.fill",
                        iconColor: Color(hex: "#F59E0B")
                    ) {
                        ForEach(
                            Array(viewModel.bestSellers.prefix(3).enumerated()),
                            id: \.element.productName
                        ) { index, item in
                            AnalyticRow(
                                rank: index + 1,
                                name: item.productName,
                                detail: "\(item.quantitySold) Terjual",
                                highlightColor: Color(hex: "#00A3A3")
                            )
                        }
                    }

                    // Section: Margin Tertinggi
                    AnalyticSection(
                        title: "Margin Tertinggi",
                        icon: "arrow.up.right.circle.fill",
                        iconColor: Color(hex: "#10B981")
                    ) {
                        ForEach(
                            Array(
                                viewModel.mostProfitableProducts.prefix(3)
                                    .enumerated()
                            ),
                            id: \.element.productName
                        ) { index, item in
                            AnalyticRow(
                                rank: index + 1,
                                name: item.productName,
                                detail:
                                    "Untung Rp \(String(format: "%.0f", item.profitMargin))",
                                highlightColor: Color(hex: "#10B981")
                            )
                        }
                    }

                    // Section: Kurang Laris
                    AnalyticSection(
                        title: "Perlu Evaluasi",
                        icon: "arrow.down.right.circle.fill",
                        iconColor: Color(hex: "#EF4444")
                    ) {
                        ForEach(
                            Array(
                                viewModel.leastPopular.prefix(3).enumerated()
                            ),
                            id: \.element.productName
                        ) { index, item in
                            AnalyticRow(
                                rank: index + 1,
                                name: item.productName,
                                detail: "Hanya \(item.quantitySold) Terjual",
                                highlightColor: Color(hex: "#EF4444")
                            )
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(hex: "#F9FAFB").ignoresSafeArea())
        .navigationTitle("Analitik Menu")
        .onAppear {
            Task { await viewModel.loadAnalyticsData(branchId: branchId) }
        }
        .refreshable { await viewModel.loadAnalyticsData(branchId: branchId) }
    }
}

// MARK: - SUB-KOMPONEN (Ini yang sebelumnya terpotong!)
struct AnalyticSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: Content

    init(
        title: String,
        icon: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.title3)
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#111827"))
            }
            .padding(.horizontal)

            VStack(spacing: 0) {
                content
            }
            .background(Color(hex: "#FFFFFF"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
}

struct AnalyticRow: View {
    let rank: Int
    let name: String
    let detail: String
    let highlightColor: Color

    var body: some View {
        HStack(spacing: 16) {
            Text("#\(rank)")
                .font(.headline)
                .foregroundColor(Color(hex: "#6B7280"))
                .frame(width: 30, alignment: .leading)

            Text(name)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#111827"))

            Spacer()

            Text(detail)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(highlightColor)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)

        // Garis pemisah antar item
        Divider().background(Color(hex: "#E5E7EB")).padding(.leading, 60)
    }
}

// MARK: - PREVIEW DENGAN TRIK CLOSURE AMAN
#Preview {
    let previewViewModel: ProductAnalyticsViewModel = {
        let mockOp = MockOperationalRepository()
        let p1 = Product(
            id: "1",
            name: "Ayam Goreng Spesial",
            price: 25000,
            recipe: []
        )
        mockOp.dummyOrders = [
            Order(
                branchId: "B-1",
                customerId: nil,
                items: [OrderItem(product: p1, quantity: 45)],
                totalAmount: 0,
                timestamp: Date()
            )
        ]
        return ProductAnalyticsViewModel(operationalProtocol: mockOp)
    }()

    NavigationStack {
        ProductAnalyticsView(viewModel: previewViewModel, branchId: "B-1")
    }
}
