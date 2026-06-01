import SwiftUI

struct CashflowPDFTemplate: View {
    var monthYear: String
    var records: [FinancialRecord]
    var totalIncome: Double
    var totalExpense: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Kop Surat
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Laporan Arus Kas")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundColor(.black)
                    Text("Periode: \(monthYear)")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "#00A3A3"))
            }
            .padding(.bottom, 20)
            
            Divider()
            
            // Ringkasan Keuangan
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Pemasukan")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text(String(format: "Rp %.0f", totalIncome))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#10B981"))
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Total Pengeluaran")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text(String(format: "Rp %.0f", totalExpense))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#EF4444"))
                }
            }
            .padding(.vertical, 16)
            
            Divider()
            
            // Tabel Transaksi
            Text("Rincian Transaksi")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 10)
            
            VStack(spacing: 12) {
                ForEach(records, id: \.id) { record in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(record.notes.isEmpty ? "Transaksi Kasir" : record.notes)
                                .font(.body)
                                .fontWeight(.medium)
                            Text(record.timestamp, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text(String(format: "%@Rp %.0f", record.type == .income ? "+" : "-", record.amount))
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(record.type == .income ? Color(hex: "#10B981") : Color(hex: "#EF4444"))
                    }
                    Divider()
                }
            }
            
            Spacer()
            
            // Footer
            HStack {
                Spacer()
                Text("Dihasilkan secara otomatis oleh Dagify")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .padding(40)
        // Ukuran kertas A4 standar pada 72 DPI
        .frame(width: 595, height: 842)
        .background(Color.white)
    }
}
