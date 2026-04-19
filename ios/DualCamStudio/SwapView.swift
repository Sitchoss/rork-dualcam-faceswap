import SwiftUI
import PhotosUI
import Photos

struct SwapView: View {
    @Environment(AppState.self) private var appState
    @State private var sourceItem: PhotosPickerItem?
    @State private var targetItem: PhotosPickerItem?
    @State private var sourceImage: UIImage?
    @State private var targetImage: UIImage?
    @State private var resultImage: UIImage?
    @State private var isSwapping = false
    @State private var errorMessage: String?
    @State private var compareX: CGFloat = 0.5
    @State private var saveToast: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    titleCard

                    if let result = resultImage {
                        comparePanel(result: result)
                        actionRow(result: result)
                    } else {
                        pickersRow
                        swapButton
                    }

                    if let err = errorMessage {
                        Text(err).font(.footnote).foregroundStyle(.red)
                    }

                    if !appState.swapHistory.isEmpty {
                        historySection
                    }
                }
                .padding()
                .padding(.bottom, 40)
            }
            .navigationTitle("Face Swap")
            .navigationBarTitleDisplayMode(.large)
            .overlay(alignment: .top) {
                if let toast = saveToast {
                    Text(toast)
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: .capsule)
                        .overlay(Capsule().stroke(.white.opacity(0.1)))
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .onChange(of: sourceItem) { _, new in loadImage(new) { sourceImage = $0 } }
        .onChange(of: targetItem) { _, new in loadImage(new) { targetImage = $0 } }
    }

    private var titleCard: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 56, height: 56)
                Image(systemName: "wand.and.stars")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("AI Face Swap").font(.title3.bold())
                Text("Pick two photos and we'll merge the source face onto the target.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 20))
    }

    private var pickersRow: some View {
        HStack(spacing: 12) {
            pickerSlot(title: "Source face", subtitle: "The face to use", image: sourceImage, binding: $sourceItem, symbol: "person.crop.circle")
            pickerSlot(title: "Target photo", subtitle: "Where it goes", image: targetImage, binding: $targetItem, symbol: "photo.on.rectangle")
        }
    }

    private func pickerSlot(title: String, subtitle: String, image: UIImage?, binding: Binding<PhotosPickerItem?>, symbol: String) -> some View {
        PhotosPicker(selection: binding, matching: .images) {
            ZStack {
                if let img = image {
                    Color.black
                        .overlay {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .allowsHitTesting(false)
                        }
                        .clipShape(.rect(cornerRadius: 20))
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.opacity(0.05))
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: symbol).font(.title)
                                Text(title).font(.headline)
                                Text(subtitle).font(.caption).foregroundStyle(.secondary)
                            }
                            .foregroundStyle(.white.opacity(0.8))
                        }
                        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6])).foregroundStyle(.white.opacity(0.2)))
                }
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
        }
    }

    private var swapButton: some View {
        Button {
            runSwap()
        } label: {
            HStack(spacing: 8) {
                if isSwapping { ProgressView().tint(.white) }
                Image(systemName: "sparkles")
                Text(isSwapping ? "Swapping…" : "Swap faces")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: (sourceImage != nil && targetImage != nil) ? [.pink, .purple] : [.gray.opacity(0.4), .gray.opacity(0.4)],
                    startPoint: .leading, endPoint: .trailing
                ),
                in: .rect(cornerRadius: 18)
            )
            .foregroundStyle(.white)
        }
        .disabled(sourceImage == nil || targetImage == nil || isSwapping)
        .sensoryFeedback(.impact, trigger: isSwapping)
    }

    private func comparePanel(result: UIImage) -> some View {
        GeometryReader { geo in
            ZStack {
                Color.black
                    .overlay {
                        if let t = targetImage {
                            Image(uiImage: t).resizable().aspectRatio(contentMode: .fill).allowsHitTesting(false)
                        }
                    }
                Image(uiImage: result)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
                    .mask(alignment: .leading) {
                        Rectangle().frame(width: geo.size.width * compareX)
                    }
                    .allowsHitTesting(false)

                Rectangle()
                    .fill(.white)
                    .frame(width: 2)
                    .position(x: geo.size.width * compareX, y: geo.size.height / 2)

                Circle()
                    .fill(.white)
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: "arrow.left.and.right")
                            .font(.footnote.bold())
                            .foregroundStyle(.black)
                    }
                    .position(x: geo.size.width * compareX, y: geo.size.height / 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { v in
                                compareX = max(0, min(1, v.location.x / geo.size.width))
                            }
                    )

                HStack {
                    label("BEFORE")
                    Spacer()
                    label("AFTER")
                }
                .padding(12)
            }
            .clipShape(.rect(cornerRadius: 20))
        }
        .frame(height: 420)
    }

    private func label(_ s: String) -> some View {
        Text(s)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(.black.opacity(0.5), in: .capsule)
            .foregroundStyle(.white)
    }

    private func actionRow(result: UIImage) -> some View {
        HStack(spacing: 10) {
            Button {
                save(image: result)
            } label: {
                Label("Save", systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.pink)

            ShareLink(item: Image(uiImage: result), preview: SharePreview("Face Swap", image: Image(uiImage: result))) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button(role: .destructive) {
                resultImage = nil
                sourceImage = nil
                targetImage = nil
                sourceItem = nil
                targetItem = nil
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.bordered)
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent swaps")
                .font(.headline)
                .padding(.horizontal, 4)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(appState.swapHistory) { s in
                        if let img = UIImage(data: s.resultData) {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 160)
                                .clipShape(.rect(cornerRadius: 14))
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 4)
        }
    }

    private func runSwap() {
        guard let src = sourceImage, let tgt = targetImage,
              let srcData = src.jpegData(compressionQuality: 0.85),
              let tgtData = tgt.jpegData(compressionQuality: 0.85) else { return }

        errorMessage = nil
        isSwapping = true

        Task {
            do {
                let result = try await FaceSwapService.swap(source: srcData, target: tgtData)
                if let resultData = result.jpegData(compressionQuality: 0.9) {
                    resultImage = result
                    let record = SwapResult(sourceData: srcData, targetData: tgtData, resultData: resultData)
                    appState.swapHistory.insert(record, at: 0)
                    compareX = 0.5
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isSwapping = false
        }
    }

    private func save(image: UIImage) {
        PhotoSaver.save(image: image) { ok in
            withAnimation(.spring) {
                saveToast = ok ? "Saved to Photos" : "Couldn't save"
            }
            Task {
                try? await Task.sleep(for: .seconds(2))
                withAnimation { saveToast = nil }
            }
        }
    }

    private func loadImage(_ item: PhotosPickerItem?, set: @escaping (UIImage) -> Void) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let img = UIImage(data: data) {
                set(img)
            }
        }
    }
}
