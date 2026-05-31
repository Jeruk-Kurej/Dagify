//
//  DagifyApp.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 25/05/26.
//


import SwiftUI
import FirebaseCore
import SwiftData

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
