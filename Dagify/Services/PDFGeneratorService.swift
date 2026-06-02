import Foundation
import SwiftUI
import UIKit // Wajib untuk mengakses UIWindow & Render Engine

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
        let renderer = UIGraphicsPDFRenderer(bounds: pdfBounds, format: format)
        
        let itemsPerPage = 12
        let totalPages = max(1, Int(ceil(Double(records.count) / Double(itemsPerPage))))
        
        do {
            try renderer.writePDF(to: tempURL) { context in
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
                    
                    let hostingController = UIHostingController(rootView: pageView)
                    hostingController.view.frame = pdfBounds
                    
                    // ✅ HIG & SOLID FIX: Memaksa mesin grafis iOS merender UI secara sinkron
                    // dengan menempelkannya ke Window transparan rahasia.
                    let tempWindow = UIWindow(frame: pdfBounds)
                    tempWindow.isHidden = false
                    tempWindow.layer.opacity = 0 // Tembus pandang agar tidak berkedip di layar user
                    tempWindow.rootViewController = hostingController
                    
                    hostingController.view.setNeedsLayout()
                    hostingController.view.layoutIfNeeded()
                    
                    hostingController.view.layer.render(in: context.cgContext)
                }
            }
            return tempURL
        } catch {
            print("Gagal membuat PDF: \(error.localizedDescription)")
            return nil
        }
    }
}
