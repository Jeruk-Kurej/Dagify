import Foundation
import SwiftUI
import UIKit // ✅ Wajib untuk memanggil UIGraphicsPDFRenderer & UIHostingController

@MainActor
class PDFGeneratorService {
    
    // Fitur Baru: Pagination (Multi-Halaman) Otomatis dengan UIKit Bridge
    static func generateCashflowReport(
        monthYear: String,
        records: [FinancialRecord],
        totalIncome: Double,
        totalExpense: Double,
        filename: String
    ) -> URL? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(filename).pdf")
        let pdfBounds = CGRect(x: 0, y: 0, width: 595, height: 842) // Standar Kertas A4
        
        // ✅ SOLUSI ENTERPRISE: Menggunakan UIGraphicsPDFRenderer (100x lebih stabil dari ImageRenderer)
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: pdfBounds, format: format)
        
        // Batasi 12 baris per halaman agar tidak meluber
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
                    .environment(\.colorScheme, .light) // Paksa mode terang
                    
                    // ✅ BUNGKUS KE UIKIT: Paksa sistem merender UI ke dalam layer memori fisik
                    let hostingController = UIHostingController(rootView: pageView)
                    hostingController.view.frame = pdfBounds
                    hostingController.view.backgroundColor = .white
                    
                    // Paksa kalkulasi ukuran sebelum memotret layer
                    hostingController.view.setNeedsLayout()
                    hostingController.view.layoutIfNeeded()
                    
                    // Lukis UI ke dalam kanvas PDF
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
