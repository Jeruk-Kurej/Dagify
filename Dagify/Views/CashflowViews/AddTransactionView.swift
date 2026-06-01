import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss

    // ✅ MVVM: Menggunakan nama parameter 'viewModel' dan menerima 'branchId'
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

                    TextField("Catatan (Cth: Bayar Listrik)", text: $notes)
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
                            if let amount = Double(amountString) {
                                // Eksekusi dengan mengirimkan branchId juga
                                await viewModel.addTransaction(
                                    branchId: branchId,
                                    amount: amount,
                                    type: type,
                                    category: .none,
                                    notes: notes
                                )
                                dismiss()
                            }
                        }
                    }
                    .disabled(
                        amountString.isEmpty || notes.isEmpty
                            || viewModel.isLoading
                    )
                }
            }
        }
    }
}
