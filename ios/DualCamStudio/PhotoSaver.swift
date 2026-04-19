import Foundation
import UIKit
import Photos

@MainActor
enum PhotoSaver {
    static func save(image: UIImage, completion: @escaping (Bool) -> Void) {
        requestAuth { granted in
            guard granted else { completion(false); return }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { ok, _ in
                DispatchQueue.main.async { completion(ok) }
            }
        }
    }

    static func save(videoAt url: URL, completion: @escaping (Bool) -> Void) {
        requestAuth { granted in
            guard granted else { completion(false); return }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            } completionHandler: { ok, _ in
                DispatchQueue.main.async { completion(ok) }
            }
        }
    }

    static func save(data: Data, mime: String, completion: @escaping (Bool) -> Void) {
        if mime.hasPrefix("image") {
            if let img = UIImage(data: data) {
                save(image: img, completion: completion)
            } else {
                completion(false)
            }
        } else if mime.hasPrefix("video") {
            let ext = mime.contains("mp4") ? "mp4" : (mime.contains("quicktime") ? "mov" : "mp4")
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("vid-\(UUID().uuidString).\(ext)")
            do {
                try data.write(to: url)
                save(videoAt: url, completion: completion)
            } catch {
                completion(false)
            }
        } else {
            completion(false)
        }
    }

    private static func requestAuth(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        if status == .authorized || status == .limited {
            completion(true)
        } else {
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { s in
                DispatchQueue.main.async {
                    completion(s == .authorized || s == .limited)
                }
            }
        }
    }
}
