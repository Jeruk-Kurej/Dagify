import SwiftUI

struct MinimalSecureField: View {
    var icon: String
    var placeholder: String
    /// Stores the placeholder text for the password field
    @Binding var text: String
    @State private var isVisible: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(placeholder)
                .font(.subheadline)
                .foregroundColor(Color.gray)
            
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "#00A3A3"))
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: 24)
                
                if isVisible {
                    TextField(hint, text: $text)
                        .foregroundColor(Color.gray)
                        .textInputAutocapitalization(.never)
                } else {
                    SecureField(hint, text: $text)
                        .foregroundColor(Color.gray)
                }
                
                Button(action: {
                    isVisible.toggle()
                }) {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .foregroundColor(Color.gray)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#00A3A3"), lineWidth: 1.5)
                    .shadow(color: Color(hex: "#00A3A3").opacity(0.6), radius: 5, x: 0, y: 0)
            )
        }
}

}

#Preview {
    MinimalSecureField(icon: "lock.fill", placeholder: "Password", text: .constant(""))
}
