import Foundation
import SwiftUI
import UIKit

@MainActor
class PDFGeneratorService {
    
    static func generateCashflowReport(
        monthYear: String,
        records: [FinancialRecord],
        totalIncome: Double,
        totalExpense: Double,
        filename: String
    ) -> URL? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(filename).pdf")
        let pdfBounds = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 Presisi
        
        let format = UIGraphicsPDFRendererFormat()
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pdfBounds, format: format)
        
        let itemsPerPage = 12
        let totalPages = max(1, Int(ceil(Double(records.count) / Double(itemsPerPage))))
        
        do {
            try pdfRenderer.writePDF(to: tempURL) { context in
                for pageIndex in 0..<totalPages {
                    context.beginPage()
                    
                    let start = pageIndex * itemsPerPage
                    let end = min(start + itemsPerPage, records.count)
                    let pageRecords = records.isEmpty ? [] : Array(records[start..<end])
                    
                    let pageView = CashflowPDFTemplate(
                        monthYear: monthYear,
                        records: pageRecords,
                        totalIncome: totalIncome,
                        totalExpense: totalExpense,
                        page: pageIndex + 1,
                        totalPages: totalPages
                    )
                    .environment(\.colorScheme, .light)
                    .frame(width: 595, height: 842)
                    .background(Color.white)
                    
                    let renderer = ImageRenderer(content: pageView)
                    renderer.proposedSize = .init(width: 595, height: 842)
                    
                    if let uiImage = renderer.uiImage {
                        uiImage.draw(in: pdfBounds)
                    }
                }
            }
            return tempURL
        } catch {
            print("Gagal membuat PDF: \(error.localizedDescription)")
            return nil
        }
    }
}
