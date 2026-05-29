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
    static func renderViewToPDF<V: View>(view: V, filename: String) -> URL? {
        let renderer = ImageRenderer(content: view)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(filename).pdf")
    
        renderer.render { size, context in
            var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            guard let pdf = CGContext(tempURL as CFURL, mediaBox: &box, nil) else { return }
            
            pdf.beginPDFPage(nil)
            context(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
        }
        
        return tempURL
    }
}
