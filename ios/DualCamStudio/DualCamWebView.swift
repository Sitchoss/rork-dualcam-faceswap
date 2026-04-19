import SwiftUI
import WebKit
import AVFoundation
import UIKit

struct DualCamWebView: UIViewRepresentable {
    let onCapture: (GalleryItem) -> Void
    let onSaveRequest: (GalleryItem) -> Void
    let inventory: [CameraDescriptor]
    let activeCameraID: String?
    let onActiveChanged: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onCapture: onCapture,
            onSaveRequest: onSaveRequest,
            onActiveChanged: onActiveChanged
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsPictureInPictureMediaPlayback = false
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        let controller = WKUserContentController()
        controller.add(context.coordinator, name: "capture")
        controller.add(context.coordinator, name: "save")
        controller.add(context.coordinator, name: "share")
        controller.add(context.coordinator, name: "openNativeCamera")
        controller.add(context.coordinator, name: "activeCameraChanged")

        let seed = Self.inventoryScript(inventory: inventory, activeID: activeCameraID)
        let userScript = WKUserScript(source: seed, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        controller.addUserScript(userScript)

        config.userContentController = controller

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView

        if let url = Bundle.main.url(forResource: "dualcam", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            webView.loadHTMLString(Self.inlineHTML, baseURL: nil)
        }

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.appBecameActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let js = Self.syncScript(inventory: inventory, activeID: activeCameraID)
        uiView.evaluateJavaScript(js, completionHandler: nil)
        context.coordinator.currentActiveID = activeCameraID
        context.coordinator.currentInventory = inventory
    }

    static let inlineHTML: String = DualCamHTML.page

    private static func inventoryJSON(_ inventory: [CameraDescriptor]) -> String {
        let arr: [[String: Any]] = inventory.map { d in
            var dict: [String: Any] = [
                "id": d.id,
                "name": d.localizedName,
                "position": d.position,
                "deviceType": d.deviceType,
                "isVirtual": d.isVirtual,
                "fov": Double(d.fieldOfView)
            ]
            if let r = d.videoDefault {
                dict["videoDefault"] = ["w": r.width, "h": r.height, "fps": r.frameRate ?? 0]
            }
            if let r = d.photoDefault {
                dict["photoDefault"] = ["w": r.width, "h": r.height]
            }
            if let r = d.webDefaultWhenVideoOnly {
                dict["webVideoOnly"] = ["w": r.width, "h": r.height, "fps": r.frameRate ?? 0]
            }
            if let r = d.webDefaultWhenWidthOnly {
                dict["webWidthOnly"] = ["w": r.width, "h": r.height, "fps": r.frameRate ?? 0]
            }
            if let r = d.webDefaultWhenHeightOnly {
                dict["webHeightOnly"] = ["w": r.width, "h": r.height, "fps": r.frameRate ?? 0]
            }
            return dict
        }
        let data = (try? JSONSerialization.data(withJSONObject: arr, options: [])) ?? Data("[]".utf8)
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    static func inventoryScript(inventory: [CameraDescriptor], activeID: String?) -> String {
        let json = inventoryJSON(inventory)
        let active = activeID.map { "'\($0)'" } ?? "null"
        return "window.__DUALCAM_CAMERAS = \(json); window.__DUALCAM_ACTIVE_ID = \(active);"
    }

    static func syncScript(inventory: [CameraDescriptor], activeID: String?) -> String {
        let json = inventoryJSON(inventory)
        let active = activeID.map { "'\($0)'" } ?? "null"
        return "if (window.dualcamSetInventory) { window.dualcamSetInventory(\(json), \(active)); } else { window.__DUALCAM_CAMERAS = \(json); window.__DUALCAM_ACTIVE_ID = \(active); }"
    }

    @MainActor
    final class Coordinator: NSObject, WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        weak var webView: WKWebView?
        let onCapture: (GalleryItem) -> Void
        let onSaveRequest: (GalleryItem) -> Void
        let onActiveChanged: (String) -> Void
        var currentActiveID: String?
        var currentInventory: [CameraDescriptor] = []
        private var pendingCameraMode: String = "photo"
        private var pendingCameraPosition: String = "Back"

        init(
            onCapture: @escaping (GalleryItem) -> Void,
            onSaveRequest: @escaping (GalleryItem) -> Void,
            onActiveChanged: @escaping (String) -> Void
        ) {
            self.onCapture = onCapture
            self.onSaveRequest = onSaveRequest
            self.onActiveChanged = onActiveChanged
        }

        nonisolated func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            let name = message.name
            let body = message.body
            Task { @MainActor in
                self.handleMessage(name: name, body: body)
            }
        }

        private func handleMessage(name: String, body: Any) {
            switch name {
            case "capture":
                guard let dict = body as? [String: Any],
                      let b64 = dict["data"] as? String,
                      let mime = dict["mime"] as? String,
                      let kindRaw = dict["kind"] as? String,
                      let data = Data(base64Encoded: b64) else { return }
                let kind: GalleryItem.Kind = {
                    switch kindRaw {
                    case "front-video": .frontVideo
                    case "back-photo": .backPhoto
                    case "back-video": .backVideo
                    default: .testCapture
                    }
                }()
                onCapture(GalleryItem(kind: kind, data: data, mime: mime))
            case "save":
                guard let dict = body as? [String: Any],
                      let b64 = dict["data"] as? String,
                      let mime = dict["mime"] as? String,
                      let data = Data(base64Encoded: b64) else { return }
                onSaveRequest(GalleryItem(kind: .testCapture, data: data, mime: mime))
            case "share":
                guard let dict = body as? [String: Any],
                      let b64 = dict["data"] as? String,
                      let mime = dict["mime"] as? String,
                      let data = Data(base64Encoded: b64) else { return }
                let filename = (dict["filename"] as? String) ?? defaultFilename(for: mime)
                presentShareSheet(data: data, filename: filename)
            case "openNativeCamera":
                let dict = body as? [String: Any]
                let mode = dict?["mode"] as? String ?? "photo"
                let position = dict?["position"] as? String ?? "Back"
                pendingCameraMode = mode
                pendingCameraPosition = position
                presentNativeCamera(mode: mode, position: position)
            case "activeCameraChanged":
                if let id = (body as? [String: Any])?["id"] as? String {
                    onActiveChanged(id)
                }
            default: break
            }
        }

        @objc func appBecameActive() {
            webView?.evaluateJavaScript("window.dualcamOnReturn && window.dualcamOnReturn();", completionHandler: nil)
        }

        private func presentNativeCamera(mode: String, position: String = "Back") {
            #if targetEnvironment(simulator)
            webView?.evaluateJavaScript("window.dualcamOnCameraUnavailable && window.dualcamOnCameraUnavailable();")
            return
            #else
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                webView?.evaluateJavaScript("window.dualcamOnCameraUnavailable && window.dualcamOnCameraUnavailable();")
                return
            }
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.cameraDevice = position == "Front" ? .front : .rear
            picker.delegate = self
            if mode == "video" {
                picker.mediaTypes = ["public.movie"]
                picker.cameraCaptureMode = .video
                picker.videoQuality = .typeHigh
            } else {
                picker.mediaTypes = ["public.image"]
                picker.cameraCaptureMode = .photo
            }
            webView?.evaluateJavaScript("window.dualcamOnNativeWillOpen && window.dualcamOnNativeWillOpen();")
            topVC()?.present(picker, animated: true)
            #endif
        }

        private func topVC() -> UIViewController? {
            UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
                .first?.topMost()
        }

        nonisolated func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            Task { @MainActor in
                picker.dismiss(animated: true)
                self.webView?.evaluateJavaScript("window.dualcamOnReturn && window.dualcamOnReturn();")
            }
        }

        nonisolated func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            Task { @MainActor in
                let mode = self.pendingCameraMode
                picker.dismiss(animated: true)
                if mode == "video", let url = info[.mediaURL] as? URL, let data = try? Data(contentsOf: url) {
                    let b64 = data.base64EncodedString()
                    self.onCapture(GalleryItem(kind: .backVideo, data: data, mime: "video/mp4"))
                    let js = "window.dualcamOnNativeResult && window.dualcamOnNativeResult({kind:'back-video', mime:'video/mp4', data:'\(b64)'});"
                    self.webView?.evaluateJavaScript(js)
                } else if let img = info[.originalImage] as? UIImage, let data = img.jpegData(compressionQuality: 0.9) {
                    let b64 = data.base64EncodedString()
                    self.onCapture(GalleryItem(kind: .backPhoto, data: data, mime: "image/jpeg"))
                    let js = "window.dualcamOnNativeResult && window.dualcamOnNativeResult({kind:'back-photo', mime:'image/jpeg', data:'\(b64)'});"
                    self.webView?.evaluateJavaScript(js)
                } else {
                    self.webView?.evaluateJavaScript("window.dualcamOnReturn && window.dualcamOnReturn();")
                }
            }
        }

        nonisolated func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
            decisionHandler(.grant)
        }

        private func defaultFilename(for mime: String) -> String {
            let stamp = Int(Date().timeIntervalSince1970)
            if mime.contains("json") { return "kysee-\(stamp).json" }
            if mime.contains("pdf") { return "kysee-\(stamp).pdf" }
            if mime.contains("png") { return "kysee-\(stamp).png" }
            if mime.contains("jpeg") || mime.contains("jpg") { return "kysee-\(stamp).jpg" }
            if mime.contains("mp4") { return "kysee-\(stamp).mp4" }
            return "kysee-\(stamp).bin"
        }

        private func presentShareSheet(data: Data, filename: String) {
            let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            do {
                try data.write(to: tmp, options: .atomic)
            } catch {
                return
            }
            let av = UIActivityViewController(activityItems: [tmp], applicationActivities: nil)
            if let pop = av.popoverPresentationController, let wv = webView {
                pop.sourceView = wv
                pop.sourceRect = CGRect(x: wv.bounds.midX, y: wv.bounds.midY, width: 1, height: 1)
                pop.permittedArrowDirections = []
            }
            topVC()?.present(av, animated: true)
        }
    }
}

private extension UIViewController {
    func topMost() -> UIViewController {
        if let p = presentedViewController { return p.topMost() }
        if let nav = self as? UINavigationController, let v = nav.visibleViewController { return v.topMost() }
        if let tab = self as? UITabBarController, let v = tab.selectedViewController { return v.topMost() }
        return self
    }
}

private extension UIWindowScene {
    var keyWindow: UIWindow? { windows.first { $0.isKeyWindow } ?? windows.first }
}
