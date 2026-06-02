import Foundation
import SwiftUI
import PDFKit

@MainActor
class PDFGeneratorService {
    
    // Fitur Baru: Pagination (Multi-Halaman) Otomatis
    static func generateCashflowReport(
        monthYear: String,
        records: [FinancialRecord],
        totalIncome: Double,
        totalExpense: Double,
        filename: String
    ) -> URL? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(filename).pdf")
        var box = CGRect(x: 0, y: 0, width: 595, height: 842) // Standar A4
        
        guard let pdf = CGContext(tempURL as CFURL, mediaBox: &box, nil) else { return nil }
        
        // Batasi 12 baris per halaman agar tidak meluber
        let itemsPerPage = 12
        let totalPages = max(1, Int(ceil(Double(records.count) / Double(itemsPerPage))))
        
        for pageIndex in 0..<totalPages {
            let start = pageIndex * itemsPerPage
            let end = min(start + itemsPerPage, records.count)
            let pageRecords = Array(records[start..<end])
            
            let pageView = CashflowPDFTemplate(
                monthYear: monthYear,
                records: pageRecords,
                totalIncome: totalIncome,
                totalExpense: totalExpense,
                page: pageIndex + 1,
                totalPages: totalPages
            )
            
            let renderer = ImageRenderer(content: pageView)
            renderer.proposedSize = .init(width: 595, height: 842)
            
            pdf.beginPDFPage(nil)
            // Memaksa background menjadi putih solid
            pdf.setFillColor(UIColor.white.cgColor)
            pdf.fill(box)
            
            renderer.render { size, context in
                context(pdf)
            }
            pdf.endPDFPage()
        }
        
        pdf.closePDF()
        return tempURL
    }
}
