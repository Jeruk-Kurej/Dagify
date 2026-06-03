//
//  ContentView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 25/05/26.
//


import SwiftUI

struct ContentView: View {
    @State private var authViewModel = AuthViewModel(
        authProtocol: FirebaseAuthService()
    )

    var body: some View {
        Group {
            if authViewModel.isAuthenticated,
                let user = authViewModel.currentUser
            {
                /// Passing the Store ID for initialization
                MainAppView(storeId: user.storeId, authViewModel: authViewModel)
                    .transition(.opacity)
            } else {
                AuthView(viewModel: authViewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
    }
}

#Preview {
    ContentView()
}
