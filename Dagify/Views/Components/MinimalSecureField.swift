import SwiftUI

struct MinimalSecureField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.8))
                .font(.system(size: 18, weight: .medium))

            SecureField("", text: $text)
                .foregroundColor(.white)
                .overlay(
                    Text(text.isEmpty ? placeholder : "")
                        .foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .leading),
                    alignment: .leading
                )
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
