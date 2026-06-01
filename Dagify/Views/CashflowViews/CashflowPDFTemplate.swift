//
//  CashflowPDFTemplate.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 31/05/26.
//

import SwiftUI

struct CashflowPDFTemplate: View {
    let totalIncome: Double; let totalExpense: Double; let netProfit: Double; let branchId: String
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Laporan Dagify").font(.largeTitle).bold()
            Text("Cabang: \(branchId) | Dicetak: \(Date().formatted())").foregroundColor(.gray)
            Divider()
            HStack { Text("Pemasukan:"); Spacer(); Text("Rp \(totalIncome, specifier: "%.0f")").foregroundColor(.green) }
            HStack { Text("Pengeluaran:"); Spacer(); Text("Rp \(totalExpense, specifier: "%.0f")").foregroundColor(.red) }
            Divider()
            HStack { Text("Laba Bersih:"); Spacer(); Text("Rp \(netProfit, specifier: "%.0f")").bold() }
        }.padding().frame(width: 595, height: 842).background(Color.white)
    }
}
#Preview {
//    CashflowPDFTemplate()
}
