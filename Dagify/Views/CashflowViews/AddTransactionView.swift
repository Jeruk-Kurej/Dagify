import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss

    // ✅ MVVM SOLID: Menggunakan properti viewModel hasil injeksi luar
    var viewModel: CashflowViewModel
    var branchId: String

    @State private var amountString: String = ""
    @State private var type: TransactionType = .expense
    @State private var notes: String = ""

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

                    TextField("Nominal (Rp)", text: $amountString)
                        .keyboardType(.numberPad)

                    // Mengubah petunjuk placeholder menjadi opsional
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
                        Task {
                            // Sanitasi input string dari koma/titik agar konversi Double selalu aman dan berhasil
                            let cleanString = amountString.filter { $0.isNumber || $0 == "." || $0 == "," }.replacingOccurrences(of: ",", with: ".")
                            if let amount = Double(cleanString) {
                                await viewModel.addTransaction(
                                    branchId: branchId,
                                    amount: amount,
                                    type: type,
                                    category: .none,
                                    // Jika catatan kosong, beri penamaan default otomatis sesuai tipe transaksi
                                    notes: notes.isEmpty ? (type == .income ? "Pemasukan Manual" : "Pengeluaran Manual") : notes
                                )
                                dismiss()
                            }
                        }
                    }
                    // ✅ FIX UX: Catatan tidak wajib diisi lagi, tombol akan langsung aktif saat nominal terisi!
                    .disabled(amountString.isEmpty || viewModel.isLoading)
                }
            }
        }
    }
}
