import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss

    // ✅ MVVM SOLID: Menggunakan properti viewModel hasil injeksi luar
    var viewModel: CashflowViewModel
    var branchId: String

    @State private var amountString: String = ""
    @State private var type: TransactionType = .expense
    @State private var notes: String = ""

    // ✅ LOGIKA VALIDASI REAL-TIME
    var isAmountValid: Bool {
        let clean = amountString.replacingOccurrences(of: ",", with: ".")
        return Double(clean) != nil && (Double(clean) ?? 0) > 0
    }
    
    var validationMessage: String? {
        if amountString.isEmpty {
            return "Nominal wajib diisi."
        } else if !isAmountValid {
            return "Format angka tidak valid."
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Detail Transaksi")) {
                    Picker("Jenis Transaksi", selection: $type) {
                        Text("Pengeluaran").tag(TransactionType.expense)
                        Text("Pemasukan").tag(TransactionType.income)
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 8)

                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Nominal (Rp)", text: $amountString)
                            .keyboardType(.decimalPad) // Menampilkan keyboard angka + simbol desimal
                            // ✅ UX MAGIC: Memaksa membuang huruf asing secara instan
                            .onChange(of: amountString) { oldValue, newValue in
                                let filtered = newValue.filter { "0123456789.,".contains($0) }
                                if filtered != newValue {
                                    amountString = filtered
                                }
                            }
                        
                        // ✅ PERINGATAN VISUAL YANG JELAS BAGI USER
                        if let msg = validationMessage {
                            Text(msg)
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    }

                    // Petunjuk placeholder menjadi opsional
                    TextField("Catatan (Opsional)", text: $notes)
                }

                // Error dari Firebase (jika ada)
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Catat Kas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        Task {
                            // Sanitasi input string dari koma/titik agar konversi Double aman
                            let cleanString = amountString.replacingOccurrences(of: ",", with: ".")
                            if let amount = Double(cleanString) {
                                await viewModel.addTransaction(
                                    branchId: branchId,
                                    amount: amount,
                                    type: type,
                                    category: .none,
                                    // Jika catatan kosong, beri penamaan default otomatis
                                    notes: notes.isEmpty ? (type == .income ? "Pemasukan Manual" : "Pengeluaran Manual") : notes
                                )
                                dismiss()
                            }
                        }
                    }
                    // ✅ UX: Tombol simpan DITOLAK (mati) selama peringatan merah masih ada
                    .disabled(!isAmountValid || viewModel.isLoading)
                }
            }
        }
    }
}
