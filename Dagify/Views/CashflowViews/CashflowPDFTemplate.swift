import SwiftUI

struct CashflowPDFTemplate: View {
    var monthYear: String
    var records: [FinancialRecord]
    var totalIncome: Double
    var totalExpense: Double
    
    var page: Int
    var totalPages: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Kop Surat
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Laporan Mutasi Arus Kas")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundColor(.black)
                    Text("Periode: \(monthYear)")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                Spacer()
                /// Apply official logo in PDF header
                Image("Dagify_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }
            .padding(.bottom, 10)
            
            Divider()
            
            if page == 1 {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Total Debit (Masuk)")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(totalIncome.toRupiah())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#10B981"))
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Total Kredit (Keluar)")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(totalExpense.toRupiah())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#EF4444"))
                    }
                }
                .padding(.vertical, 8)
            }
            
            Text(
                page == 1
                    ? "Rincian Transaksi Bulanan"
                    : "Lanjutan Transaksi (Hal \(page))"
            )
            .font(.title3)
            .fontWeight(.bold)
            .padding(.top, 10)
            .foregroundColor(.black)
            
            VStack(spacing: 8) {
                HStack(alignment: .center) {
                    Text("Tanggal").font(.caption).bold().frame(width: 80, alignment: .leading)
                    Text("Keterangan").font(.caption).bold().frame(maxWidth: .infinity, alignment: .leading)
                    Text("Masuk (Rp)").font(.caption).bold().frame(width: 100, alignment: .trailing)
                    Text("Keluar (Rp)").font(.caption).bold().frame(width: 100, alignment: .trailing)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
                .background(Color(hex: "#F3F4F6"))
                .foregroundColor(.black)
                
                Divider()
                
                if records.isEmpty {
                    Text("Tidak ada mutasi di bulan ini.")
                        .foregroundColor(.gray)
                        .italic()
                        .padding(.top, 20)
                } else {
                    ForEach(records, id: \.id) { record in
                        HStack(alignment: .top) {
                            Text(record.timestamp.formatted(date: .numeric, time: .omitted))
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .frame(width: 80, alignment: .leading)
                            
                            Text(record.notes.isEmpty ? "Sistem Otomatis" : record.notes)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            
                            Text(record.type == .income ? record.amount.toRupiah() : "-")
                                .font(.caption)
                                .foregroundColor(record.type == .income ? Color(hex: "#10B981") : .black)
                                .frame(width: 100, alignment: .trailing)
                            
                            Text(record.type == .expense ? record.amount.toRupiah() : "-")
                                .font(.caption)
                                .foregroundColor(record.type == .expense ? Color(hex: "#EF4444") : .black)
                                .frame(width: 100, alignment: .trailing)
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                        
                        Divider()
                    }
                }
            }
            
            Spacer(minLength: 0)
            
            HStack {
                Text("Halaman \(page) dari \(totalPages)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("Sistem Rekapitulasi Dagify")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(40)
        .frame(width: 595, height: 842, alignment: .top)
        .background(Color.white)
    }
}

#Preview {
    CashflowPDFTemplate(records: [], totalIncome: 0, totalExpense: 0, monthYear: "Januari 2026", page: 1, totalPages: 1)
}
