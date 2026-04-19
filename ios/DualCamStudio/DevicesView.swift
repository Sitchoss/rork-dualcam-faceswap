import SwiftUI
import AVFoundation
import PhotosUI

struct DevicesView: View {
    @Environment(AppState.self) private var appState
    @State private var selected: CameraDescriptor?
    @State private var permission: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @State private var assignments: [String: Mode] = [:]
    @State private var launchToast: String?

    enum Mode: String { case photo = "Photo", video = "Video" }

    private var devices: [CameraDescriptor] { appState.cameraInventory }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header

                    if permission == .notDetermined {
                        permissionCard
                    } else if permission == .denied || permission == .restricted {
                        deniedCard
                    }

                    if devices.isEmpty {
                        emptyState
                    } else {
                        ForEach(devices) { d in
                            CameraCard(
                                device: d,
                                mode: assignments[d.id] ?? .photo,
                                onTap: { selected = d },
                                onModeChange: { assignments[d.id] = $0 },
                                onUseInBrowser: { useInBrowser(d) }
                            )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationTitle("Cameras")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(item: $selected) { d in
                CameraDetailSheet(device: d, mode: assignments[d.id] ?? .photo)
                    .presentationDetents([.large])
                    .presentationContentInteraction(.scrolls)
            }
            .overlay(alignment: .top) {
                if let t = launchToast {
                    Text(t)
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: .capsule)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .onAppear { refresh() }
    }

    private func useInBrowser(_ d: CameraDescriptor) {
        appState.activeBrowserCameraID = d.id
        appState.selectedTab = .dualcam
        withAnimation(.spring) { launchToast = "Using \(d.localizedName) in browser" }
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation { launchToast = nil }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(devices.count) cameras detected")
                .font(.headline)
                .foregroundStyle(.primary)
            Text("Tap any camera to view its full capabilities and assign it to Photo or Video capture.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 20))
    }

    private var permissionCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "lock.shield.fill")
                .font(.largeTitle)
                .foregroundStyle(.pink)
            Text("Camera access required")
                .font(.headline)
            Text("Grant camera access to inspect every camera on your device.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Grant access") {
                Task {
                    _ = await AVCaptureDevice.requestAccess(for: .video)
                    permission = AVCaptureDevice.authorizationStatus(for: .video)
                    refresh()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 20))
    }

    private var deniedCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.title)
                .foregroundStyle(.orange)
            Text("Camera access denied")
                .font(.headline)
            Text("Enable camera access in Settings to see live data.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            if let url = URL(string: UIApplication.openSettingsURLString) {
                Link("Open Settings", destination: url)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 20))
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.metering.matrix")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("No cameras detected")
                .font(.headline)
            Text("This happens on simulator. Install the app on a real device to see every physical camera.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 20))
    }

    private func refresh() {
        permission = AVCaptureDevice.authorizationStatus(for: .video)
        appState.cameraInventory = CameraInventory.discoverAll()
    }
}

private struct CameraCard: View {
    let device: CameraDescriptor
    let mode: DevicesView.Mode
    let onTap: () -> Void
    let onModeChange: (DevicesView.Mode) -> Void
    let onUseInBrowser: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.pink.opacity(0.6), .purple.opacity(0.6)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 48, height: 48)
                    Image(systemName: device.deviceTypeSymbol)
                        .font(.title3)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(device.localizedName)
                        .font(.headline)
                    HStack(spacing: 6) {
                        Chip(text: device.position)
                        Chip(text: device.deviceType)
                        if device.isVirtual { Chip(text: "Virtual", tint: .orange) }
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }

            Divider().overlay(.white.opacity(0.1))

            VStack(alignment: .leading, spacing: 8) {
                ResRow(label: "Photo default", value: device.photoDefault?.display ?? "—", symbol: "photo")
                ResRow(label: "Video default", value: device.videoDefault?.display ?? "—", symbol: "video")
                ResRow(label: "Web: video only", value: device.webDefaultWhenVideoOnly?.display ?? "—", symbol: "safari")
                ResRow(label: "Web: height only", value: device.webDefaultWhenHeightOnly?.display ?? "—", symbol: "arrow.up.and.down")
                ResRow(label: "Web: width only", value: device.webDefaultWhenWidthOnly?.display ?? "—", symbol: "arrow.left.and.right")
                ResRow(label: "Field of view", value: String(format: "%.1f°", device.fieldOfView), symbol: "viewfinder")
            }

            HStack {
                Text("Assigned mode")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Picker("", selection: Binding(
                    get: { mode },
                    set: { onModeChange($0) }
                )) {
                    Text("Photo").tag(DevicesView.Mode.photo)
                    Text("Video").tag(DevicesView.Mode.video)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
            }

            Button(action: onUseInBrowser) {
                HStack(spacing: 8) {
                    Image(systemName: "safari.fill")
                    Text("Use in Browser")
                        .font(.subheadline.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing),
                    in: .capsule
                )
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
        .contentShape(.rect(cornerRadius: 22))
        .onTapGesture { onTap() }
    }
}

private struct Chip: View {
    let text: String
    var tint: Color = .blue

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(tint.opacity(0.15), in: .capsule)
    }
}

private struct ResRow: View {
    let label: String
    let value: String
    let symbol: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 18)
            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.primary)
        }
    }
}

struct CameraDetailSheet: View {
    let device: CameraDescriptor
    let mode: DevicesView.Mode
    @Environment(\.dismiss) private var dismiss
    @State private var testResult: UIImage?
    @State private var isTesting: Bool = false
    @State private var testError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: device.deviceTypeSymbol)
                                .font(.title)
                                .foregroundStyle(.pink)
                            VStack(alignment: .leading) {
                                Text(device.localizedName).font(.title3.bold())
                                Text("\(device.position) · \(device.deviceType)")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))

                    if let img = testResult {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(.rect(cornerRadius: 16))
                    }

                    Button {
                        runTest()
                    } label: {
                        HStack {
                            if isTesting { ProgressView().tint(.white) }
                            Image(systemName: mode == .photo ? "camera.fill" : "video.fill")
                            Text(isTesting ? "Capturing…" : "Test \(mode.rawValue) capture")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing),
                            in: .rect(cornerRadius: 16)
                        )
                        .foregroundStyle(.white)
                    }
                    .disabled(isTesting)

                    if let err = testError {
                        Text(err).font(.footnote).foregroundStyle(.red)
                    }

                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader("Defaults")
                            KV("Photo default", device.photoDefault?.display ?? "—")
                            KV("Video default", device.videoDefault?.display ?? "—")
                            KV("Field of view", String(format: "%.1f°", device.fieldOfView))
                            KV("ISO range", "\(Int(device.minISO)) – \(Int(device.maxISO))")
                            KV("Flash", device.hasFlash ? "Yes" : "No")
                            KV("Torch", device.hasTorch ? "Yes" : "No")
                            KV("Virtual device", device.isVirtual ? "Yes" : "No")
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
                    }

                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader("Web default picks")
                            KV("video: true", device.webDefaultWhenVideoOnly?.display ?? "—")
                            KV("height only (720)", device.webDefaultWhenHeightOnly?.display ?? "—")
                            KV("width only (1280)", device.webDefaultWhenWidthOnly?.display ?? "—")
                            Text("These are the resolutions the phone would hand back to a website via getUserMedia when only the listed hint is given.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
                    }

                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader("\(device.supportedFormats.count) supported formats")
                            ForEach(device.supportedFormats) { f in
                                HStack {
                                    Text(f.dimensions.display)
                                        .font(.footnote.monospacedDigit())
                                    Spacer()
                                    Text(f.pixelFormat)
                                        .font(.caption.monospaced())
                                        .foregroundStyle(.secondary)
                                    if f.isHDR {
                                        Text("HDR")
                                            .font(.caption2.bold())
                                            .padding(.horizontal, 6).padding(.vertical, 2)
                                            .background(.orange.opacity(0.2), in: .capsule)
                                            .foregroundStyle(.orange)
                                    }
                                }
                                Divider().overlay(.white.opacity(0.05))
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
                    }
                }
                .padding()
            }
            .navigationTitle("Camera detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func runTest() {
        isTesting = true
        testError = nil
        Task {
            do {
                let image = try await CameraTestCapture.capture(deviceID: device.id)
                testResult = image
            } catch {
                testError = error.localizedDescription
            }
            isTesting = false
        }
    }
}

private struct SectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        Text(title)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
    }
}

private struct KV: View {
    let k: String
    let v: String
    init(_ k: String, _ v: String) { self.k = k; self.v = v }
    var body: some View {
        HStack {
            Text(k).font(.footnote).foregroundStyle(.secondary)
            Spacer()
            Text(v).font(.footnote.monospacedDigit())
        }
    }
}
