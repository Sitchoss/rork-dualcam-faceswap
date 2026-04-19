import SwiftUI
import WebKit
import UIKit
import AVFoundation

struct DualCamView: View {
    @Environment(AppState.self) private var appState
    @State private var showGallery = false
    @State private var saveToast: String?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                DualCamWebView(
                    onCapture: { item in
                        appState.galleryItems.insert(item, at: 0)
                    },
                    onSaveRequest: { item in
                        PhotoSaver.save(data: item.data, mime: item.mime) { ok in
                            toast(ok ? "Saved to Photos" : "Couldn't save")
                        }
                    },
                    inventory: appState.cameraInventory,
                    activeCameraID: appState.activeBrowserCameraID,
                    onActiveChanged: { id in
                        appState.activeBrowserCameraID = id
                    }
                )
                .ignoresSafeArea(edges: .bottom)

                if !appState.galleryItems.isEmpty {
                    Button {
                        showGallery = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("Gallery · \(appState.galleryItems.count)")
                                .font(.subheadline.weight(.semibold))
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: .capsule)
                        .overlay(Capsule().stroke(.white.opacity(0.15)))
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("DualCam")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .top) {
                if let t = saveToast {
                    Text(t)
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: .capsule)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .sheet(isPresented: $showGallery) {
                GallerySheet()
                    .presentationDetents([.large])
                    .presentationContentInteraction(.scrolls)
            }
            .onAppear {
                if appState.cameraInventory.isEmpty {
                    appState.cameraInventory = CameraInventory.discoverAll()
                }
                if appState.activeBrowserCameraID == nil {
                    appState.activeBrowserCameraID = appState.cameraInventory.first?.id
                }
            }
        }
    }

    private func toast(_ s: String) {
        withAnimation(.spring) { saveToast = s }
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation { saveToast = nil }
        }
    }
}

struct GallerySheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var saveMessage: String?

    private let cols = [GridItem(.adaptive(minimum: 140), spacing: 10)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: cols, spacing: 10) {
                    ForEach(appState.galleryItems) { item in
                        GalleryCell(item: item) {
                            PhotoSaver.save(data: item.data, mime: item.mime) { ok in
                                withAnimation { saveMessage = ok ? "Saved" : "Failed" }
                                Task {
                                    try? await Task.sleep(for: .seconds(1.5))
                                    withAnimation { saveMessage = nil }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Captures")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
            }
            .overlay(alignment: .top) {
                if let m = saveMessage {
                    Text(m)
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: .capsule)
                        .padding(.top, 8)
                }
            }
        }
    }
}

private struct GalleryCell: View {
    let item: GalleryItem
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                Color.black
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        if item.mime.hasPrefix("image"), let img = UIImage(data: item.data) {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .allowsHitTesting(false)
                        } else {
                            Image(systemName: "video.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .clipShape(.rect(cornerRadius: 14))

                VStack {
                    HStack {
                        Text(item.kind.rawValue)
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6).padding(.vertical, 3)
                            .background(.black.opacity(0.5), in: .capsule)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: onSave) {
                            Image(systemName: "square.and.arrow.down.fill")
                                .font(.footnote.bold())
                                .padding(8)
                                .background(.ultraThinMaterial, in: .circle)
                        }
                    }
                }
                .padding(6)
            }
        }
    }
}
