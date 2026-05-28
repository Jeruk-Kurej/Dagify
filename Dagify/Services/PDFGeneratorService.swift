//
//  PDFGeneratorService.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Foundation
import PDFKit

class PDFGeneratorService {
    
    static func generateMonthlyReport(monthYear: String, records: [FinancialRecord], totalIncome: Double, totalExpense: Double) -> URL? {
        let format = UIGraphicsPDFRendererFormat()
        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let bounds = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds, format: format)
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Laporan_Dagify_\(monthYear).pdf")
        
        do {
            try renderer.writePDF(to: tempURL) { context in
                context.beginPage()
                
                let title = "Laporan Keuangan: \(monthYear)"
                let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 24)]
                title.draw(at: CGPoint(x: 50, y: 50), withAttributes: titleAttributes)
                
                let netProfit = totalIncome - totalExpense
                let summaryText = "Pemasukan: Rp\(totalIncome)\nPengeluaran: Rp\(totalExpense)\nLaba Bersih: Rp\(netProfit)"
                let summaryAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14)]
                summaryText.draw(at: CGPoint(x: 50, y: 100), withAttributes: summaryAttributes)
                
                var currentY: CGFloat = 180
                let tableHeader = "Daftar Transaksi:"
                tableHeader.draw(at: CGPoint(x: 50, y: currentY), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
                currentY += 30
                
                for record in records {
                    let typeSign = record.type == .income ? "+" : "-"
                    let rowText = "\(record.timestamp.formatted(date: .numeric, time: .shortened)) | \(record.notes) | \(typeSign) Rp\(record.amount)"
                    
                    rowText.draw(at: CGPoint(x: 50, y: currentY), withAttributes: summaryAttributes)
                    currentY += 20
                    
                    if currentY > pageHeight - 50 {
                        context.beginPage()
                        currentY = 50
                    }
                }
            }
            return tempURL 
        } catch {
            print("Gagal membuat PDF: \(error)")
            return nil
        }
    }
}
