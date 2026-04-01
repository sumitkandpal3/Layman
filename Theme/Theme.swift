import SwiftUI

// MARK: - Colors
extension Color {
    static let theme = LaymanThemeColors()
}

struct LaymanThemeColors {
    // Primary Gradient: Peach to Orange
    let peach = Color(red: 1.0, green: 0.85, blue: 0.72)
    let accentOrange = Color(red: 0.816, green: 0.388, blue: 0.184)
    
    var primaryGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [peach, accentOrange]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Background: Warm beige/cream in Light, Near Black in Dark
    var background: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark 
                ? UIColor(white: 0.07, alpha: 1.0) 
                : UIColor(red: 0.973, green: 0.961, blue: 0.945, alpha: 1.0)
        })
    }
    
    // Card Background: Lighter beige in Light, Dark Gray in Dark
    var cardBackground: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark 
                ? UIColor(white: 0.12, alpha: 1.0) 
                : UIColor(red: 0.933, green: 0.906, blue: 0.875, alpha: 1.0)
        })
    }
    
    // Secondary Card Background (e.g. search bars)
    var secondaryBackground: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark 
                ? UIColor(white: 0.18, alpha: 1.0) 
                : UIColor(red: 0.918, green: 0.906, blue: 0.894, alpha: 1.0)
        })
    }
    
    // Text Primary: Dark brown in Light, White in Dark
    var textPrimary: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark 
                ? .white 
                : UIColor(red: 0.118, green: 0.098, blue: 0.086, alpha: 1.0)
        })
    }
    
    // Text Secondary: Muted gray/brown
    var textSecondary: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark 
                ? .lightGray 
                : UIColor(red: 0.4, green: 0.35, blue: 0.30, alpha: 1.0)
        })
    }
    
    // Suggestion Pill background
    var suggestionPill: Color {
        Color(UIColor { traitCollection in 
            return traitCollection.userInterfaceStyle == .dark 
                ? UIColor(red: 0.52, green: 0.22, blue: 0.10, alpha: 1.0) 
                : UIColor(red: 0.620, green: 0.275, blue: 0.133, alpha: 1.0)
        })
    }
    
    // Destructive Red: Vivid red in Light, Bright red in Dark
    var destructive: Color {
        Color(UIColor { traitCollection in 
            return traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 1.0)
                : UIColor(red: 0.92, green: 0.34, blue: 0.34, alpha: 1.0)
        })
    }
    
    // Shadow Color: Subtle black in Light, Slightly more transparent in Dark
    var shadow: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark 
                ? UIColor.black.withAlphaComponent(0.3) 
                : UIColor.black.withAlphaComponent(0.05)
        })
    }
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
            .background(Color.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.theme.shadow, radius: 10, x: 0, y: 5)
    }
}

/// Pill Shape Button Style
struct PillButtonStyle: ButtonStyle {
    var isFilled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font.theme.subtitle)
            .foregroundColor(isFilled ? .white : Color.theme.textPrimary)
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
        self.shadow(color: Color.theme.shadow, radius: 10, x: 0, y: 5)
    }
    
    /// Standard styling for input fields (text fields, secure fields)
    func themeField() -> some View {
        self.padding()
            .background(Color.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .softShadow()
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
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
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
            let shimmerBase = Color(UIColor { traitCollection in 
                return traitCollection.userInterfaceStyle == .dark ? UIColor(white: 0.15, alpha: 1.0) : UIColor(white: 0.88, alpha: 1.0)
            })
            let shimmerHighlight = Color(UIColor { traitCollection in 
                return traitCollection.userInterfaceStyle == .dark ? UIColor(white: 0.22, alpha: 1.0) : UIColor(white: 0.93, alpha: 1.0)
            })
            
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: shimmerBase, location: 0),
                            .init(color: shimmerHighlight, location: 0.4 + phase * 0.3),
                            .init(color: shimmerBase, location: 1)
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
