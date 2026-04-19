import SwiftUI
import Observation

@Observable
final class AppState {
    var swapHistory: [SwapResult] = []
    var galleryItems: [GalleryItem] = []
    var cameraInventory: [CameraDescriptor] = []
    var activeBrowserCameraID: String?
    var selectedTab: RootTab = .swap
}

enum RootTab: Hashable {
    case swap, dualcam, devices
}

struct SwapResult: Identifiable, Hashable {
    let id: UUID = UUID()
    let sourceData: Data
    let targetData: Data
    let resultData: Data
    let createdAt: Date = Date()
}

struct GalleryItem: Identifiable, Hashable {
    let id: UUID = UUID()
    let kind: Kind
    let data: Data
    let mime: String
    let createdAt: Date = Date()

    enum Kind: String {
        case frontVideo = "Front Video"
        case backPhoto = "Back Photo"
        case backVideo = "Back Video"
        case testCapture = "Test Capture"
    }
}
