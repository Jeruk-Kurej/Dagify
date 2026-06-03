import SwiftUI

struct MinimalField: View {
    var icon: String
    var placeholder: String
    /// Stores the placeholder text inside the input box
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label atas berwarna gray opacity 0.6 sesuai permintaan sebelumnya
            Text(placeholder)
                .font(.subheadline)
                .foregroundColor(Color.gray)

            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "#00A3A3"))
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: 24)
                
                TextField(hint, text: $text)
                    .foregroundColor(Color.gray)
                    .textInputAutocapitalization(.never)
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
    MinimalField(icon: "envelope.fill", placeholder: "Email", text: .constant(""))
}
