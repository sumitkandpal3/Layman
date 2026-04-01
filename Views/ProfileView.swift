import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Aesthetic mapping aligned with Layman Theme constants
    let bgWarmWhite = Color(red: 0.995, green: 0.985, blue: 0.965)
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            HStack {
                Text("Profile")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color.theme.textInfo)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 24)
            
            // User Meta Info Card
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 72))
                    .foregroundColor(Color.theme.accentOrange.opacity(0.8))
                
                VStack(spacing: 6) {
                    Text("Layman Member")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color.theme.textInfo)
                    
                    Text(authViewModel.userEmail.isEmpty ? "user@example.com" : authViewModel.userEmail)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 36)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Sign Out Hook natively triggering Auth routing boundary
            Button(action: {
                Task {
                    await authViewModel.logout()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18, weight: .bold))
                    Text("Sign Out")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0.92, green: 0.34, blue: 0.34)) // Semantic Destructive Red
                .clipShape(Capsule())
                .shadow(color: Color.red.opacity(0.2), radius: 10, x: 0, y: 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(bgWarmWhite.ignoresSafeArea())
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
