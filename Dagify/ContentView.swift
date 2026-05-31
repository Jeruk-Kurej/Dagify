//
//  ContentView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 25/05/26.
//

import SwiftUI

struct ContentView: View {
    @State private var authViewModel = AuthViewModel(authProtocol: FirebaseAuthService())
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated, let user = authViewModel.currentUser {
                MainAppView(storeId: user.storeId, branchId: "B-1", authViewModel: authViewModel)
                
            } else {
                VStack(spacing: 24) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.themePrimary)
                    
                    Text("Dagify")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.themeTextPrimary)
                    
                    VStack(spacing: 16) {
                        TextField("Alamat Email", text: $email)
                            .padding()
                            .background(Color.themeBgSecondary)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.themeBorder, lineWidth: 1))
                            .autocapitalization(.none)
                        
                        SecureField("Kata Sandi", text: $password)
                            .padding()
                            .background(Color.themeBgSecondary)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.themeBorder, lineWidth: 1))
                    }
                    .padding(.horizontal, 32)
                    
                    if authViewModel.isLoading {
                        ProgressView()
                    } else {
                        Button(action: {
                            Task { await authViewModel.login(email: email, password: password) }
                        }) {
                            Text("Masuk ke Sistem")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.themePrimary)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 32)
                    }
                    
                    if let err = authViewModel.errorMessage {
                        Text(err).foregroundColor(.themeDestructive).font(.caption).padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.themeBgMain.edgesIgnoringSafeArea(.all))
            }
        }
    }
}


#Preview {
    //ContentView()
}
