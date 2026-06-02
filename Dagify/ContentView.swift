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
                // ✅ HANYA MENGIRIMKAN STORE ID
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
