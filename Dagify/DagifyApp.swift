//
//  DagifyApp.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 25/05/26.
//


import SwiftUI
import FirebaseCore
import SwiftData

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct DagifyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            #if targetEnvironment(macCatalyst)
                .frame(minWidth: 900, minHeight: 600)
            #endif
        }
        .modelContainer(for: OfflineOrderModel.self)
        #if targetEnvironment(macCatalyst)
        .windowResizability(.contentMinSize)
        #endif
    }
}
