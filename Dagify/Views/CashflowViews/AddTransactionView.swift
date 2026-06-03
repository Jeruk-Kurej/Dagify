import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: CashflowViewModel
    var branchId: String
    
    // ✅ PARAMETER OPSIONAL UNTUK EDIT
    var recordToEdit: FinancialRecord? = nil
    
    @State private var type: TransactionType = .expense
    @State private var transactionDate: Date = Date()
    @State private var notes: String = ""
    @State private var amountString: String = ""
    @State private var hasAttemptedSave = false

    var isAmountValid: Bool {
        let clean = amountString.replacingOccurrences(of: ",", with: ".")
        return Double(clean) != nil && (Double(clean) ?? 0) > 0
    }
    
    var validationMessage: String? {
        if hasAttemptedSave && amountString.isEmpty { return "Nominal wajib diisi." }
        else if !amountString.isEmpty && !isAmountValid { return "Format angka tidak valid." }
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
                    
                    DatePicker("Waktu Transaksi", selection: $transactionDate, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                    TextField("Catatan (Opsional)", text: $notes)

                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Nominal (Rp)", text: $amountString)
                            .keyboardType(.decimalPad)
                            .onChange(of: amountString) { oldValue, newValue in
                                let filtered = newValue.filter { "0123456789.,".contains($0) }
                                if filtered != newValue { amountString = filtered }
                            }
                        
                        if let msg = validationMessage {
                            Text(msg).font(.caption2).foregroundColor(.red)
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Section { Text(errorMessage).foregroundColor(.red).font(.footnote) }
                }
            }
            .navigationTitle(recordToEdit == nil ? "Catat Kas" : "Edit Transaksi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Batal") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        if amountString.isEmpty || !isAmountValid {
                            withAnimation { hasAttemptedSave = true }
                        } else {
                            Task {
                                let cleanString = amountString.replacingOccurrences(of: ",", with: ".")
                                if let amount = Double(cleanString) {
                                    if let edit = recordToEdit {
                                        // ✅ JALANKAN LOGIKA EDIT
                                        var updated = edit
                                        updated.amount = amount
                                        updated.type = type
                                        updated.notes = notes.isEmpty ? (type == .income ? "Pemasukan Manual" : "Pengeluaran Manual") : notes
                                        updated.timestamp = transactionDate
                                        await viewModel.updateTransaction(updated)
                                    } else {
                                        // JALANKAN LOGIKA TAMBAH BARU
                                        await viewModel.addTransaction(branchId: branchId, amount: amount, type: type, category: .none, notes: notes.isEmpty ? (type == .income ? "Pemasukan Manual" : "Pengeluaran Manual") : notes, date: transactionDate)
                                    }
                                    dismiss()
                                }
                            }
                        }
                    }.disabled(viewModel.isLoading)
                }
            }
            .onAppear {
                // ✅ ISI NILAI DEFAULT JIKA DALAM MODE EDIT
                if let edit = recordToEdit {
                    type = edit.type
                    transactionDate = edit.timestamp
                    notes = (edit.notes == "Pemasukan" || edit.notes == "Pengeluaran") ? "" : edit.notes
                    amountString = String(format: "%.0f", edit.amount)
                }
            }
        }
    }
}
