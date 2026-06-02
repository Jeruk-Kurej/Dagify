import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: CashflowViewModel
    var branchId: String

    @State private var type: TransactionType = .expense
    @State private var transactionDate: Date = Date() // ✅ KALENDER WAKTU
    @State private var notes: String = ""
    @State private var amountString: String = ""
    
    @State private var hasAttemptedSave = false // ✅ TRIGGER VALIDASI SOPAN

    var isAmountValid: Bool {
        let clean = amountString.replacingOccurrences(of: ",", with: ".")
        return Double(clean) != nil && (Double(clean) ?? 0) > 0
    }
    
    var validationMessage: String? {
        if hasAttemptedSave && amountString.isEmpty {
            return "Nominal wajib diisi."
        } else if !amountString.isEmpty && !isAmountValid {
            return "Format angka tidak valid."
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Detail Transaksi")) {
                    // 1. Jenis
                    Picker("Jenis Transaksi", selection: $type) {
                        Text("Pengeluaran").tag(TransactionType.expense)
                        Text("Pemasukan").tag(TransactionType.income)
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 8)
                    
                    // 2. Tanggal Transaksi
                    DatePicker("Waktu Transaksi", selection: $transactionDate)
                    
                    // 3. Catatan
                    TextField("Catatan (Opsional)", text: $notes)

                    // 4. Nominal (Tergabung dengan error text di bawahnya)
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Nominal (Rp)", text: $amountString)
                            .keyboardType(.decimalPad)
                            .onChange(of: amountString) { oldValue, newValue in
                                let filtered = newValue.filter { "0123456789.,".contains($0) }
                                if filtered != newValue {
                                    amountString = filtered
                                }
                            }
                        
                        if let msg = validationMessage {
                            Text(msg)
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    }
                }

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
                        // ✅ JIKA KOSONG: Munculkan pesan error (Jangan kunci tombol secara buta)
                        if amountString.isEmpty || !isAmountValid {
                            withAnimation { hasAttemptedSave = true }
                        } else {
                            // ✅ JIKA VALID: Eksekusi penyimpanan
                            Task {
                                let cleanString = amountString.replacingOccurrences(of: ",", with: ".")
                                if let amount = Double(cleanString) {
                                    await viewModel.addTransaction(
                                        branchId: branchId,
                                        amount: amount,
                                        type: type,
                                        category: .none,
                                        notes: notes.isEmpty ? (type == .income ? "Pemasukan Manual" : "Pengeluaran Manual") : notes,
                                        date: transactionDate // ✅ Kirim tanggal pilihan
                                    )
                                    dismiss()
                                }
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }
}
