import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss

    var viewModel: CashflowViewModel
    var branchId: String

    @State private var amountString: String = ""
    @State private var type: TransactionType = .expense
    @State private var notes: String = ""
    
    // ✅ Mencegah double-submission (klik ganda)
    @State private var isSaving: Bool = false

    // ✅ LOGIKA VALIDASI REAL-TIME YANG LEBIH JELAS
    var isAmountValid: Bool {
        let clean = amountString.replacingOccurrences(of: ",", with: ".")
        return (Double(clean) ?? 0) > 0
    }
    
    var validationMessage: String? {
        if amountString.isEmpty {
            return "Nominal wajib diisi."
        }
        let clean = amountString.replacingOccurrences(of: ",", with: ".")
        if Double(clean) == nil {
            return "Format angka tidak valid. Gunakan titik/koma dengan benar."
        } else if let val = Double(clean), val <= 0 {
            return "Nominal harus lebih besar dari 0."
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
                            .keyboardType(.decimalPad)
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

                    TextField("Catatan (Opsional)", text: $notes)
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
                        guard !isSaving else { return }
                        isSaving = true // Matikan tombol
                        
                        Task {
                            let cleanString = amountString.replacingOccurrences(of: ",", with: ".")
                            if let amount = Double(cleanString) {
                                await viewModel.addTransaction(
                                    branchId: branchId,
                                    amount: amount,
                                    type: type,
                                    category: .none,
                                    notes: notes.isEmpty ? (type == .income ? "Pemasukan Manual" : "Pengeluaran Manual") : notes
                                )
                                isSaving = false
                                dismiss()
                            } else {
                                isSaving = false
                            }
                        }
                    }
                    // ✅ UX: Tombol simpan DITOLAK selama merah, loading, atau sedang proses simpan
                    .disabled(!isAmountValid || viewModel.isLoading || isSaving)
                }
            }
        }
    }
}
