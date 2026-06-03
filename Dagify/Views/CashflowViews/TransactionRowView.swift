import SwiftUI

struct TransactionRowView: View {
    var record: FinancialRecord
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(record.type == .income ? Color(hex: "#10B981").opacity(0.15) : Color(hex: "#EF4444").opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: record.type == .income ? "arrow.down.left" : "arrow.up.right")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(record.type == .income ? Color(hex: "#10B981") : Color(hex: "#EF4444"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.notes.isEmpty ? (record.type == .income ? "Pemasukan" : "Pengeluaran") : record.notes)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#111827"))
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(record.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(Color(hex: "#6B7280"))
                    .lineLimit(1) // ✅ FIX: Memaksa tanggal dan waktu agar hanya 1 baris
                    .truncationMode(.tail) // ✅ FIX: Menjadi "..." jika terlalu panjang (misal layarnya kecil)
            }
            
            Spacer(minLength: 8)
            
            Text("\(record.type == .income ? "+" : "-") \(record.amount.toRupiah())")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(record.type == .income ? Color(hex: "#10B981") : Color(hex: "#EF4444"))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .layoutPriority(1)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
