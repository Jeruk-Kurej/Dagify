//
//  ShareSheet.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 03/06/26.
//

import SwiftUI
import UIKit

// MARK: - Share Sheet Component
struct ShareSheet: UIViewControllerRepresentable {
    // MARK: - Properties
    /// The items (URLs, Strings, Images) to be shared
    var activityItems: [Any]
    /// Application-specific activities (custom share buttons), usually nil
    var applicationActivities: [UIActivity]? = nil

    // MARK: - Methods
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {
        // No updates needed for a static share sheet
    }
}
