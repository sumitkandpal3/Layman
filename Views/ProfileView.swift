import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var animateStreak = false
    
    // Using semantic background from Theme
    private var bgWarmWhite: Color { Color.theme.background }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header: Consistent breathing room with Auth screen
            HStack {
                Text("Profile")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color.theme.textPrimary)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            .padding(.bottom, 24)
            
            // User Meta Info Card: Design Match with Auth Cards
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.theme.accentOrange.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color.theme.accentOrange.opacity(0.9))
                }
                
                VStack(spacing: 8) {
                    Text("Layman Member")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color.theme.textPrimary)
                    
                    Text(authViewModel.userEmail.isEmpty ? "user@example.com" : authViewModel.userEmail)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color.theme.textSecondary)
                    
                    let streak = StreakService.shared.getStreak()
                    if streak > 0 {
                        HStack(spacing: 8) {
                            Text("🔥")
                            Text("Streak:")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.theme.textSecondary)
                            Text("\(streak) Days")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(Color.theme.accentOrange)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.theme.secondaryBackground)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                        .scaleEffect(animateStreak ? 1.0 : 0.8)
                        .opacity(animateStreak ? 1.0 : 0.0)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(Color.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .softShadow()
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Sign Out Hook natively triggering Auth routing boundary
            Button(action: {
                Haptics.shared.play(.medium)
                Task {
                    await authViewModel.logout()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Sign Out")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.theme.destructive) // Semantic Destructive Red
                .clipShape(Capsule())
                .shadow(color: Color.theme.destructive.opacity(0.2), radius: 10, x: 0, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(bgWarmWhite.ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
                animateStreak = true
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
