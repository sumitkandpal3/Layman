import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var animateStreak = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            HStack {
                Text("Profile")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(Color.theme.textPrimary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 24)
            
            // User Meta Info Card
            VStack(spacing: 20) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.theme.accentOrange.opacity(0.12))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color.theme.accentOrange.opacity(0.9))
                }
                
                VStack(spacing: 8) {
                    Text("Layman Member")
                        .font(.system(size: 22, weight: .bold, design: .default))
                        .foregroundColor(Color.theme.textPrimary)
                    
                    Text(authViewModel.userEmail.isEmpty ? "user@example.com" : authViewModel.userEmail)
                        .font(.system(size: 15, weight: .medium, design: .default))
                        .foregroundColor(Color.theme.textSecondary)
                    
                    let streak = StreakService.shared.getStreak()
                    if streak > 0 {
                        HStack(spacing: 6) {
                            Text("🔥")
                            Text("Streak:")
                                .font(.system(size: 14, weight: .semibold, design: .default))
                                .foregroundColor(Color.theme.textSecondary)
                            Text("\(streak) Days")
                                .font(.system(size: 14, weight: .bold, design: .default))
                                .foregroundColor(Color.theme.accentOrange)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.theme.secondaryBackground)
                        .clipShape(Capsule())
                        .padding(.top, 6)
                        .scaleEffect(animateStreak ? 1.0 : 0.8)
                        .opacity(animateStreak ? 1.0 : 0.0)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 36)
            .background(Color.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.theme.shadow, radius: 10, x: 0, y: 4)
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Sign Out Button
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
                        .font(.system(size: 17, weight: .semibold, design: .default))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.theme.destructive)
                .clipShape(Capsule())
                .shadow(color: Color.theme.destructive.opacity(0.25), radius: 10, x: 0, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.theme.background.ignoresSafeArea())
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
