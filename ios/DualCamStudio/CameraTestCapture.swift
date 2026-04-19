import Foundation
import AVFoundation
import UIKit

nonisolated enum CameraTestError: LocalizedError {
    case deviceNotFound
    case unsupported
    case captureFailed(String)

    var errorDescription: String? {
        switch self {
        case .deviceNotFound: "Camera not available on this device."
        case .unsupported: "This environment does not support live capture (e.g. simulator)."
        case .captureFailed(let m): m
        }
    }
}

nonisolated final class CameraTestCapture: NSObject, @unchecked Sendable {
    static func capture(deviceID: String) async throws -> UIImage {
        #if targetEnvironment(simulator)
        throw CameraTestError.unsupported
        #else
        guard let device = AVCaptureDevice(uniqueID: deviceID) else {
            throw CameraTestError.deviceNotFound
        }
        let helper = CameraTestCapture()
        return try await helper.capturePhoto(device: device)
        #endif
    }

    private let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var continuation: CheckedContinuation<UIImage, Error>?

    private func capturePhoto(device: AVCaptureDevice) async throws -> UIImage {
        try await withCheckedThrowingContinuation { cont in
            self.continuation = cont
            do {
                session.beginConfiguration()
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) { session.addInput(input) }
                if session.canAddOutput(output) { session.addOutput(output) }
                session.sessionPreset = .photo
                session.commitConfiguration()
                session.startRunning()

                let settings = AVCapturePhotoSettings()
                output.capturePhoto(with: settings, delegate: self)
            } catch {
                cont.resume(throwing: CameraTestError.captureFailed(error.localizedDescription))
                self.continuation = nil
            }
        }
    }
}

extension CameraTestCapture: @preconcurrency AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        defer {
            session.stopRunning()
            continuation = nil
        }
        if let error {
            continuation?.resume(throwing: CameraTestError.captureFailed(error.localizedDescription))
            return
        }
        guard let data = photo.fileDataRepresentation(), let img = UIImage(data: data) else {
            continuation?.resume(throwing: CameraTestError.captureFailed("No image data"))
            return
        }
        continuation?.resume(returning: img)
    }
}
