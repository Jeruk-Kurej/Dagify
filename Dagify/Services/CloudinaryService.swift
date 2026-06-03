//
//  CloudinaryService.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 03/06/26.
//

import Foundation
import CryptoKit

protocol CloudStorageProtocol {
    func uploadImage(imageData: Data) async throws -> String
}

/// Concrete implementation of CloudStorageProtocol using Cloudinary API.
class CloudinaryService: CloudStorageProtocol {
    
    // MARK: - Properties
    private let cloudName = "dahvinw2b"
    private let apiKey = "755343447871684"
    private let apiSecret = "-3aaoHbU4ACu2L9Ba703dfWpkHM"
    
    // MARK: - Methods
    func uploadImage(imageData: Data) async throws -> String {
        let urlString = "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        let timestamp = String(Int(Date().timeIntervalSince1970))
        
        // Generate SHA-1 Signature for secure authentication
        let stringToSign = "timestamp=\(timestamp)\(apiSecret)"
        let signatureData = Insecure.SHA1.hash(data: Data(stringToSign.utf8))
        let signature = signatureData.compactMap { String(format: "%02x", $0) }.joined()
        
        let base64Image = "data:image/jpeg;base64," + imageData.base64EncodedString()
        let body: [String: Any] = [
            "file": base64Image,
            "api_key": apiKey,
            "timestamp": timestamp,
            "signature": signature
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let secureUrl = json?["secure_url"] as? String else {
            throw URLError(.cannotParseResponse)
        }
        
        return secureUrl
    }
}
