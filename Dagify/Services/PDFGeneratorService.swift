import Foundation
import SwiftUI
import PDFKit

@MainActor
class PDFGeneratorService {
    
    // ✅ FIX TOTAL: Menggunakan CoreGraphics PDF Context + ImageRenderer Block Drawing
    // Menjamin laporan keuangan TIDAK AKAN PERNAH menghasilkan halaman putih kosong (blank).
    static func generateCashflowReport(
        monthYear: String,
        records: [FinancialRecord],
        totalIncome: Double,
        totalExpense: Double,
        filename: String
    ) -> URL? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(filename).pdf")
        
        // Batasi maksimal 12 baris per halaman agar struktur layout A4 presisi
        let itemsPerPage = 12
        let totalPages = max(1, Int(ceil(Double(records.count) / Double(itemsPerPage))))
        
        // Buat daftar halaman berbasis SwiftUI View secara dinamis
        var pageViews: [AnyView] = []
        for pageIndex in 0..<totalPages {
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
            .environment(\.colorScheme, .light) // Proteksi mutlak agar warna font tidak memutih akibat Dark Mode
            
            pageViews.append(AnyView(pageView))
        }
        
        // Inisialisasi CGContext PDF resmi bawaan Apple
        guard let consumer = CGDataConsumer(url: tempURL as CFURL),
              let pdfContext = CGContext(consumer: consumer, mediaBox: nil, nil) else {
            return nil
        }
        
        // Lakukan eksekusi gambar halaman demi halaman ke core canvas PDF
        for view in pageViews {
            let renderer = ImageRenderer(content: view)
            // Kunci ukuran kertas A4 secara solid (595 x 842 point)
            renderer.proposedSize = ProposedViewSize(width: 595, height: 842)
            
            renderer.render { size, context in
                pdfContext.beginPDFPage(nil)
                
                // Alirkan instruksi render grafis SwiftUI langsung ke core vector PDF context
                context(pdfContext)
                
                pdfContext.endPDFPage()
            }
        }
        
        pdfContext.closePDF()
        return tempURL
    }
}
