//
//  MinimalSecureField.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 31/05/26.
//

import SwiftUI

struct MinimalSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon).foregroundColor(.white.opacity(0.6)).frame(
                width: 20
            )
            SecureField(placeholder, text: $text)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
