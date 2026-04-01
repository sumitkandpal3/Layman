import SwiftUI

struct WelcomeView: View {
    @State private var navigateToLogin = false
    
    let textDark    = Color(red: 0.13, green: 0.11, blue: 0.10)
    let accentTerra = Color(red: 0.816, green: 0.388, blue: 0.184)
    let buttonTerra = Color(red: 0.780, green: 0.380, blue: 0.200)
    
    var body: some View {
        ZStack {
            // Background: radial warm peach — bright edges, near-white soft center
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.98, green: 0.95, blue: 0.90), location: 0.0),  // soft white center
                    .init(color: Color(red: 0.95, green: 0.80, blue: 0.68), location: 0.55), // warm peach mid
                    .init(color: Color(red: 0.91, green: 0.67, blue: 0.52), location: 1.0),  // deep peach edge
                ]),
                center: .center,
                startRadius: 10,
                endRadius: 420
            )
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
