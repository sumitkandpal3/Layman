import SwiftUI

struct WelcomeView: View {
    @State private var navigateToLogin = false
    
    // Dynamic colors from theme
    private var textDark: Color    { Color.theme.textPrimary }
    private var accentTerra: Color { Color.theme.accentOrange }
    private var buttonTerra: Color { Color.theme.accentOrange }
    
    // Dynamic Gradient for Welcome screen
    private var welcomeGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(stops: [
                .init(color: Color.theme.background, location: 0.0),
                .init(color: Color.theme.accentOrange.opacity(0.15), location: 0.55),
                .init(color: Color.theme.accentOrange.opacity(0.35), location: 1.0),
            ]),
            center: .center,
            startRadius: 10,
            endRadius: 420
        )
    }
    
    var body: some View {
        ZStack {
            // Background: radial warm peach — bright edges, near-white soft center
            welcomeGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ── "Layman" title ──────────────────────────────
                Text("Layman")
                    .font(.system(size: 36, weight: .bold, design: .default))
                    .foregroundColor(textDark)
                    .padding(.top, 24)
                
                Spacer()
                
                // ── Centre tagline ───────────────────────────────
                VStack(alignment: .center, spacing: 0) {
                    Text("Business,")
                        .foregroundColor(textDark)
                    Text("tech & startups")
                        .foregroundColor(textDark)
                    Text("made simple")
                        .foregroundColor(accentTerra)
                }
                .font(.system(size: 40, weight: .bold, design: .default))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 28)
                .offset(y: -40) // sits in upper half visually
                
                Spacer()
                
                // ── Swipe-to-start pill ──────────────────────────
                SwipeToStartButton(action: {
                    navigateToLogin = true
                }, buttonColor: buttonTerra)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToLogin) {
            LoginView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

// MARK: - Swipe To Start Component
struct SwipeToStartButton: View {
    let action: () -> Void
    let buttonColor: Color
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // Background pill
                Capsule()
                    .fill(buttonColor)
                
                // "Swipe to get started" label — centered
                Text("Swipe to get started")
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundColor(.white.opacity(0.92))
                
                // Draggable white circle on the LEFT
                HStack {
                    Circle()
                        .fill(Color.white)
                        .overlay(
                            Image(systemName: "chevron.right.2")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(buttonColor)
                        )
                        .frame(width: geometry.size.height - 10, height: geometry.size.height - 10)
                        .padding(5)
                        .offset(x: offset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let maxDrag = geometry.size.width - geometry.size.height
                                    if value.translation.width > 0 && value.translation.width < maxDrag {
                                        offset = value.translation.width
                                    } else if value.translation.width >= maxDrag {
                                        offset = maxDrag
                                    }
                                }
                                .onEnded { value in
                                    let maxDrag = geometry.size.width - geometry.size.height
                                    if offset > maxDrag * 0.70 {
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            offset = maxDrag
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            action()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                offset = 0
                                            }
                                        }
                                    } else {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                            offset = 0
                                        }
                                    }
                                }
                        )
                    Spacer()
                }
            }
        }
        .frame(height: 62)
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
    }
}
