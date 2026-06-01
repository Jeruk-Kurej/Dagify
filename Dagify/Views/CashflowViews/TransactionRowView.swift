import SwiftUI

struct TransactionRowView: View {
    var record: FinancialRecord

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        record.type == .income
                            ? Color.themeSuccess.opacity(0.15)
                            : Color.themeWarning.opacity(0.15)
                    )
                    .frame(width: 44, height: 44)

                Image(
                    systemName: record.type == .income
                        ? "arrow.down.left" : "arrow.up.right"
                )
                .foregroundColor(
                    record.type == .income ? .themeSuccess : .themeWarning
                )
                .font(.headline)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(record.notes.isEmpty ? "Transaksi Kasir" : record.notes)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.themeTextPrimary)

                Text(record.timestamp, style: .date)
                    .font(.caption)
                    .foregroundColor(.themeTextSecondary)
            }

            Spacer()

            Text(
                String(
                    format: "%@Rp %.0f",
                    record.type == .income ? "+" : "-",
                    record.amount
                )
            )
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(
                record.type == .income ? .themeSuccess : .themeTextPrimary
            )
        }
        .padding(.vertical, 8)
    }
}
