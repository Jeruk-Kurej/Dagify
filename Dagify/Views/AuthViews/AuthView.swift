//
//  AuthView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 03/06/26.
//

import SwiftUI

struct AuthView: View {
    // MARK: - View Model & State
    var viewModel: AuthViewModel
    
    @State private var showAuthForm = false
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var storeName = ""
    @State private var branchName = ""
    
    var body: some View {
        ZStack {
            // Background Layer
            FluidBackgroundView()
            
            // Foreground Content
            if !showAuthForm {
                WelcomeScreenView(showAuthForm: $showAuthForm)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.9)),
                            removal: .opacity.combined(with: .scale(scale: 1.1))
                        )
                    )
            } else {
                GlassAuthFormView(
                    viewModel: viewModel,
                    isLoginMode: $isLoginMode,
                    email: $email,
                    password: $password,
                    storeName: $storeName,
                    branchName: $branchName,
                    showAuthForm: $showAuthForm
                )
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    )
                )
            }
        }
        .environment(\.colorScheme, .dark)
        .animation(.spring(response: 0.7, dampingFraction: 0.8), value: showAuthForm)
    }
}
