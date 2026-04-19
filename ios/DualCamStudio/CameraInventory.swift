import Foundation
import AVFoundation
import UIKit

nonisolated struct CameraDescriptor: Identifiable, Hashable, Sendable {
    let id: String
    let localizedName: String
    let position: String
    let deviceType: String
    let deviceTypeSymbol: String
    let photoDefault: Resolution?
    let videoDefault: Resolution?
    let webDefaultWhenVideoOnly: Resolution?
    let webDefaultWhenHeightOnly: Resolution?
    let webDefaultWhenWidthOnly: Resolution?
    let supportedFormats: [FormatInfo]
    let minISO: Float
    let maxISO: Float
    let hasFlash: Bool
    let hasTorch: Bool
    let isVirtual: Bool
    let fieldOfView: Float

    nonisolated struct Resolution: Hashable, Sendable {
        let width: Int
        let height: Int
        let frameRate: Double?

        var display: String {
            if let fps = frameRate {
                return "\(width)×\(height) @ \(Int(fps))fps"
            }
            return "\(width)×\(height)"
        }
    }

    nonisolated struct FormatInfo: Hashable, Identifiable, Sendable {
        let id: String
        let dimensions: Resolution
        let maxFrameRate: Double
        let minFrameRate: Double
        let pixelFormat: String
        let isBinned: Bool
        let isHDR: Bool
    }
}

@MainActor
enum CameraInventory {
    static func discoverAll() -> [CameraDescriptor] {
        let types: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera,
            .builtInUltraWideCamera,
            .builtInTelephotoCamera,
            .builtInDualCamera,
            .builtInDualWideCamera,
            .builtInTripleCamera,
            .builtInTrueDepthCamera,
            .builtInLiDARDepthCamera,
            .external,
            .continuityCamera
        ]

        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: types,
            mediaType: nil,
            position: .unspecified
        )

        return discovery.devices.map { describe($0) }
    }

    static func describe(_ device: AVCaptureDevice) -> CameraDescriptor {
        let positionString: String = switch device.position {
        case .back: "Back"
        case .front: "Front"
        case .unspecified: "External"
        @unknown default: "Unknown"
        }

        let (typeString, symbol, isVirtual) = typeInfo(device.deviceType)

        var formats: [CameraDescriptor.FormatInfo] = []
        for (i, format) in device.formats.enumerated() {
            let dim = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            let maxFPS = format.videoSupportedFrameRateRanges.map { $0.maxFrameRate }.max() ?? 0
            let minFPS = format.videoSupportedFrameRateRanges.map { $0.minFrameRate }.min() ?? 0
            let subType = CMFormatDescriptionGetMediaSubType(format.formatDescription)
            let subTypeString = fourCC(subType)
            formats.append(.init(
                id: "\(device.uniqueID)-\(i)",
                dimensions: .init(width: Int(dim.width), height: Int(dim.height), frameRate: maxFPS),
                maxFrameRate: maxFPS,
                minFrameRate: minFPS,
                pixelFormat: subTypeString,
                isBinned: format.isVideoBinned,
                isHDR: format.isVideoHDRSupported
            ))
        }

        let activeDim = CMVideoFormatDescriptionGetDimensions(device.activeFormat.formatDescription)
        let activeFPS = device.activeVideoMaxFrameDuration.timescale > 0
            ? Double(device.activeVideoMaxFrameDuration.timescale) / Double(device.activeVideoMaxFrameDuration.value)
            : 30.0

        let videoDefault = CameraDescriptor.Resolution(
            width: Int(activeDim.width),
            height: Int(activeDim.height),
            frameRate: activeFPS
        )

        let largestPhoto = formats.max { a, b in
            (a.dimensions.width * a.dimensions.height) < (b.dimensions.width * b.dimensions.height)
        }?.dimensions

        let webVideoOnly = closestTo(width: 640, height: 480, formats: formats) ?? videoDefault
        let webHeightOnly = closestTo(width: nil, height: 720, formats: formats) ?? videoDefault
        let webWidthOnly = closestTo(width: 1280, height: nil, formats: formats) ?? videoDefault

        let fov = device.activeFormat.videoFieldOfView

        return CameraDescriptor(
            id: device.uniqueID,
            localizedName: device.localizedName,
            position: positionString,
            deviceType: typeString,
            deviceTypeSymbol: symbol,
            photoDefault: largestPhoto,
            videoDefault: videoDefault,
            webDefaultWhenVideoOnly: webVideoOnly,
            webDefaultWhenHeightOnly: webHeightOnly,
            webDefaultWhenWidthOnly: webWidthOnly,
            supportedFormats: formats,
            minISO: device.activeFormat.minISO,
            maxISO: device.activeFormat.maxISO,
            hasFlash: device.hasFlash,
            hasTorch: device.hasTorch,
            isVirtual: isVirtual,
            fieldOfView: fov
        )
    }

    private static func closestTo(width: Int?, height: Int?, formats: [CameraDescriptor.FormatInfo]) -> CameraDescriptor.Resolution? {
        guard !formats.isEmpty else { return nil }
        let scored = formats.map { f -> (CameraDescriptor.FormatInfo, Double) in
            var score: Double = 0
            if let w = width { score += abs(Double(f.dimensions.width - w)) }
            if let h = height { score += abs(Double(f.dimensions.height - h)) }
            if width == nil && height == nil { score = -Double(f.dimensions.width * f.dimensions.height) }
            return (f, score)
        }
        guard let best = scored.min(by: { $0.1 < $1.1 }) else { return nil }
        return best.0.dimensions
    }

    private static func typeInfo(_ type: AVCaptureDevice.DeviceType) -> (String, String, Bool) {
        switch type {
        case .builtInWideAngleCamera: ("Wide Angle", "camera.fill", false)
        case .builtInUltraWideCamera: ("Ultra Wide", "camera.macro", false)
        case .builtInTelephotoCamera: ("Telephoto", "camera.aperture", false)
        case .builtInDualCamera: ("Dual", "camera.on.rectangle", true)
        case .builtInDualWideCamera: ("Dual Wide", "camera.on.rectangle.fill", true)
        case .builtInTripleCamera: ("Triple", "camera.metering.matrix", true)
        case .builtInTrueDepthCamera: ("TrueDepth", "faceid", false)
        case .builtInLiDARDepthCamera: ("LiDAR", "dot.radiowaves.left.and.right", false)
        case .external: ("External", "display", false)
        case .continuityCamera: ("Continuity", "iphone.gen3", false)
        default: ("Camera", "camera", false)
        }
    }

    private static func fourCC(_ code: FourCharCode) -> String {
        let chars: [Character] = [
            Character(UnicodeScalar(UInt8((code >> 24) & 0xFF))),
            Character(UnicodeScalar(UInt8((code >> 16) & 0xFF))),
            Character(UnicodeScalar(UInt8((code >> 8) & 0xFF))),
            Character(UnicodeScalar(UInt8(code & 0xFF)))
        ]
        return String(chars).trimmingCharacters(in: .whitespaces)
    }
}
