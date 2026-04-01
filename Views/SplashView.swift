import SwiftUI

struct SplashView: View {
    // Logo entrance
    @State private var logoScale: CGFloat    = 0.55
    @State private var logoOpacity: Double   = 0
    // Splash overlay exit
    @State private var splashOpacity: Double = 1.0
    @State private var logoExitScale: CGFloat = 1.0
    // Show destination
    @State private var showMain: Bool        = false

    // The app's warm cream — permanent base so there's NEVER a dark flash
    private let cream = Color(red: 0.973, green: 0.961, blue: 0.945)

    var body: some View {
        ZStack {
            // ── 1. Permanent warm base ────────────────────────────────────
            // Always rendered; prevents black/dark flash regardless of timing.
            cream.ignoresSafeArea()

            // ── 2. Splash gradient overlay ────────────────────────────────
            // Fades over the cream base. Because both are warm-toned the
            // dissolve looks like a natural lightening — no color pop.
            if !showMain {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0,  green: 0.90, blue: 0.78),   // warm peach
                        Color(red: 0.96, green: 0.68, blue: 0.40),   // rich orange
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .opacity(splashOpacity)

                // ── 3. Logo + wordmark ────────────────────────────────────
                VStack(spacing: 14) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                        .shadow(color: .black.opacity(0.18), radius: 22, x: 0, y: 10)

                    Text("Layman")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("News made simple.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.82))
                }
                .scaleEffect(logoExitScale)
                .opacity(logoOpacity)
            }

            // ── 4. Destination ───────────────────────────────────────────
            if showMain {
                MainView()
                    .transition(
                        .asymmetric(
                            insertion: .opacity.animation(.easeOut(duration: 0.45)),
                            removal:   .opacity.animation(.easeIn(duration: 0.2))
                        )
                    )
            }
        }
        .onAppear {
            // Phase A — logo springs up (0.1 s delay feels snappy)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.72).delay(0.1)) {
                logoScale   = 1.0
                logoOpacity = 1.0
            }

            // Phase B — after hold, shrink logo + dissolve gradient → cream shows through
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                withAnimation(.easeInOut(duration: 0.55)) {
                    splashOpacity = 0       // gradient dissolves → cream underneath
                    logoOpacity   = 0       // text+logo fade
                    logoExitScale = 1.06    // subtle scale-up on exit = feels premium
                }

                // Phase C — once cream is fully showing, crossfade to MainView
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation {
                        showMain = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
