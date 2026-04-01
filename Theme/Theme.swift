import SwiftUI

// MARK: - Colors
extension Color {
    static let theme = LaymanThemeColors()
}

struct LaymanThemeColors {
    // Primary Gradient: Peach to Orange
    let peach = Color(red: 1.0, green: 0.85, blue: 0.72)
    let accentOrange = Color.orange
    
    var primaryGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [peach, accentOrange]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Background: Warm beige/cream
    let background = Color(red: 0.98, green: 0.96, blue: 0.93)
    
    // Text: Dark gray/black
    let textInfo = Color(white: 0.15)
}

// MARK: - Typography
extension Font {
    static let theme = LaymanThemeFonts()
}

struct LaymanThemeFonts {
    let title = Font.system(.title, design: .rounded).bold()
    let subtitle = Font.system(.title3, design: .rounded).weight(.semibold)
    let bodyText = Font.system(.body, design: .rounded)
}

// MARK: - Components (View Modifiers)

/// Rounded Cards Modifier (16-20 radius)
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white) // Cards are usually white to pop against beige bg
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
    }
}

/// Pill Shape Button Style
struct PillButtonStyle: ButtonStyle {
    var isFilled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font.theme.subtitle)
            .foregroundColor(isFilled ? .white : Color.theme.textInfo)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .background(
                Group {
                    if isFilled {
                        Color.theme.primaryGradient
                    } else {
                        Color.clear
                    }
                }
            )
            .clipShape(Capsule())
            .shadow(color: isFilled ? Color.theme.accentOrange.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - View Extensions for convenience
extension View {
    /// Applies the standard card styling (rounded corners, white background, soft shadow)
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
    
    /// Applies the standard soft shadow from the design system
    func softShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Interactions & Physics

class Haptics {
    static let shared = Haptics()
    private init() {}
    
    func play(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

/// A standard bouncing button interaction for rigid containers
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Animated shimmer placeholder for async content loads (e.g. images)
struct ShimmerView: View {
    @State private var phase: CGFloat = -1.0
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(white: 0.88), location: 0),
                            .init(color: Color(white: 0.93), location: 0.4 + phase * 0.3),
                            .init(color: Color(white: 0.88), location: 1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: w)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                phase = 1.0
            }
        }
    }
}
