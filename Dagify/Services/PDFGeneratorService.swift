//
//  PDFGeneratorService.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Foundation
import SwiftUI
import PDFKit

@MainActor
class PDFGeneratorService {
    func generatePDF(for branchId: String, income: Double, expense: Double, profit: Double) -> URL? {
        let template = CashflowPDFTemplate(branchId: branchId, totalIncome: income, totalExpense: expense, netProfit: profit)
        let renderer = ImageRenderer(content: template)
        renderer.scale = UIScreen.main.scale
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Cashflow_\(branchId)_\(Date().timeIntervalSince1970).pdf")
        renderer.render { size, context in
            var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            pdf.beginPDFPage(nil); context(pdf); pdf.endPDFPage(); pdf.closePDF()
        }
        return url
    }
}
