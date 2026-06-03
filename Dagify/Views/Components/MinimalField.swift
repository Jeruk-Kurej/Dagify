import SwiftUI

struct MinimalField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#F9FAFB").opacity(0.8))
                .font(.system(size: 18, weight: .medium))
                .frame(width: 24) // ✅ FIX: Kunci lebar ikon agar teks di kanannya SELALU sejajar rata kiri
            
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Color(hex: "#F9FAFB").opacity(0.5))
                }
                TextField("", text: $text)
                    .foregroundColor(Color(hex: "#F9FAFB"))
                    .textInputAutocapitalization(.never) // ✅ Mencegah huruf kapital otomatis di email
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(Color(hex: "#F9FAFB").opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#F9FAFB").opacity(0.2), lineWidth: 1)
        )
    }
}
