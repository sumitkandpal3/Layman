import SwiftUI
import Combine

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack(spacing: 32) {
            // Header: Centered layout to match Profile title design
            VStack(spacing: 12) {
                Text("Layman")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color.theme.textPrimary)
                
                Text(viewModel.isLoginMode ? "Welcome back, friend" : "Create a new account")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color.theme.textSecondary)
            }
            .padding(.top, 60)
            
            // Error Message
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.theme.destructive)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Input Fields: Using the centralized themeField()
            VStack(spacing: 18) {
                TextField("Email address", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .themeField()
                
                SecureField("Password", text: $viewModel.password)
                    .themeField()
            }
            .padding(.horizontal, 24)
            
            // Action Button
            Button(viewModel.isLoginMode ? "Log In" : "Sign Up") {
                Haptics.shared.play(.medium)
                Task {
                    await viewModel.authenticate(using: authViewModel)
                }
            }
            .buttonStyle(PillButtonStyle())
            .disabled(viewModel.isLoading)
            .opacity(viewModel.isLoading ? 0.7 : 1.0)
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            // Loading Indicator
            if viewModel.isLoading {
                ProgressView()
            }
            
            Spacer()
            
            // Mode Toggle
            Button(action: {
                withAnimation {
                    viewModel.toggleMode()
                }
            }) {
                Text(viewModel.isLoginMode ? "Don't have an account? Sign up" : "Already have an account? Log in")
                    .font(.theme.bodyText)
                    .fontWeight(.medium)
                    .foregroundColor(Color.theme.accentOrange)
            }
            .padding(.bottom, 20)
        }
        .background(Color.theme.background.ignoresSafeArea())
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
