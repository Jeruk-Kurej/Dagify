//
//  CashflowPDFTemplate.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 31/05/26.
//

import SwiftUI

struct CashflowPDFTemplate: View {
    let branchId: String; let totalIncome: Double; let totalExpense: Double; let netProfit: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Laporan Keuangan Dagify").font(.system(size: 32, weight: .heavy, design: .rounded)).foregroundColor(.dagifyTextPrimary)
            Text("Cabang: \(branchId) | Dicetak: \(Date().formatted(date: .abbreviated, time: .standard))").font(.subheadline).foregroundColor(.dagifyTextSec)
            Divider().background(Color.dagifyBorder)
            HStack { Text("Total Pemasukan").font(.title3); Spacer(); Text("Rp \(totalIncome, specifier: "%.0f")").font(.title3).bold().foregroundColor(.dagifySuccess) }
            HStack { Text("Total Pengeluaran").font(.title3); Spacer(); Text("Rp \(totalExpense, specifier: "%.0f")").font(.title3).bold().foregroundColor(.dagifyDestructive) }
            Divider().background(Color.dagifyBorder)
            HStack { Text("Laba Bersih").font(.title2).bold(); Spacer(); Text("Rp \(netProfit, specifier: "%.0f")").font(.title).bold().foregroundColor(netProfit >= 0 ? .dagifyPrimary : .dagifyDestructive) }
            Spacer()
        }.padding(40).frame(width: 600, height: 800).background(Color.dagifySecBG)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController { UIActivityViewController(activityItems: activityItems, applicationActivities: nil) }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
//    CashflowPDFTemplate()
}
