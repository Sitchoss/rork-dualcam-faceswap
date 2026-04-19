import Foundation
import UIKit

nonisolated enum FaceSwapError: LocalizedError {
    case invalidResponse
    case decodingFailed
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "The server returned an invalid response."
        case .decodingFailed: "Couldn't read the swapped image."
        case .serverError(let m): m
        }
    }
}

nonisolated enum FaceSwapService {
    static func swap(source: Data, target: Data) async throws -> UIImage {
        let url = URL(string: "https://toolkit.rork.com/images/edit/")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let sourceB64 = "data:image/jpeg;base64," + source.base64EncodedString()
        let targetB64 = "data:image/jpeg;base64," + target.base64EncodedString()

        let body: [String: Any] = [
            "prompt": "Perform a photorealistic face swap. Take the face from the FIRST image and seamlessly place it onto the person in the SECOND image. Preserve the target image's lighting, skin tone blending at the edges, pose, hair, body, background, and composition. Match the target's lighting direction and color temperature on the swapped face. Output should look like a natural photograph of the target scene with the source person's face.",
            "images": [
                ["type": "image", "image": sourceB64],
                ["type": "image", "image": targetB64]
            ],
            "aspectRatio": "1:1"
        ]

        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw FaceSwapError.invalidResponse }

        guard (200..<300).contains(http.statusCode) else {
            let text = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            throw FaceSwapError.serverError(text)
        }

        struct ImageObj: Decodable { let base64Data: String; let mimeType: String }
        struct Response: Decodable { let image: ImageObj }

        let decoded = try JSONDecoder().decode(Response.self, from: data)
        guard let raw = Data(base64Encoded: decoded.image.base64Data),
              let img = UIImage(data: raw) else {
            throw FaceSwapError.decodingFailed
        }
        return img
    }
}
