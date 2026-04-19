import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState
        ZStack {
            AppBackground().ignoresSafeArea()

            TabView(selection: $state.selectedTab) {
                SwapView()
                    .tabItem {
                        Label("Swap", systemImage: "wand.and.stars")
                    }
                    .tag(RootTab.swap)

                DualCamView()
                    .tabItem {
                        Label("DualCam", systemImage: "camera.on.rectangle.fill")
                    }
                    .tag(RootTab.dualcam)

                DevicesView()
                    .tabItem {
                        Label("Devices", systemImage: "camera.metering.matrix")
                    }
                    .tag(RootTab.devices)
            }
        }
    }
}

struct AppBackground: View {
    @State private var phase: CGFloat = 0

    @ViewBuilder
    private var meshLayer: some View {
        let p0: SIMD2<Float> = [0, 0]
        let p1: SIMD2<Float> = [0.5, Float(phase) * 0.1]
        let p2: SIMD2<Float> = [1, 0]
        let p3: SIMD2<Float> = [-Float(phase) * 0.05, 0.5]
        let p4: SIMD2<Float> = [0.5 + Float(phase) * 0.1, 0.5]
        let p5: SIMD2<Float> = [1, 0.5]
        let p6: SIMD2<Float> = [0, 1]
        let p7: SIMD2<Float> = [0.5, 1]
        let p8: SIMD2<Float> = [1, 1]
        let c: [Color] = [
            Color(red: 0.06, green: 0.05, blue: 0.25),
            Color(red: 0.35, green: 0.10, blue: 0.55),
            Color(red: 0.05, green: 0.08, blue: 0.28),
            Color(red: 0.55, green: 0.15, blue: 0.55),
            Color(red: 0.20, green: 0.05, blue: 0.45),
            Color(red: 0.08, green: 0.07, blue: 0.22),
            Color(red: 0.04, green: 0.03, blue: 0.15),
            Color(red: 0.25, green: 0.05, blue: 0.40),
            Color(red: 0.05, green: 0.05, blue: 0.20)
        ]
        if #available(iOS 18.0, *) {
            MeshGradient(
                width: 3, height: 3,
                points: [p0, p1, p2, p3, p4, p5, p6, p7, p8],
                colors: c
            )
            .opacity(0.9)
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.06, blue: 0.18),
                    Color(red: 0.10, green: 0.03, blue: 0.22),
                    Color(red: 0.20, green: 0.04, blue: 0.28)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            meshLayer
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                phase = 1
            }
        }
    }
}
