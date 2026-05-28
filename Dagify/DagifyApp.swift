//
//  DagifyApp.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 25/05/26.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct DagifyApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: OfflineOrderModel.self)
    }
}
