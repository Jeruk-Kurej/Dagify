//
//  ContentView.swift
//  DagifyMacOS
//
//  Created by Bryan Carlie Lukito Setiawan on 10/06/26.
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
                MacMainAppView(storeId: user.storeId, authViewModel: authViewModel)
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
