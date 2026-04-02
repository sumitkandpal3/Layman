import SwiftUI
import Combine

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack(spacing: 32) {

            // Header
            VStack(spacing: 10) {
                Text("Layman")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundColor(Color.theme.textPrimary)

                Text(viewModel.isLoginMode ? "Welcome back, friend" : "Create a new account")
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundColor(Color.theme.textSecondary)
            }
            .padding(.top, 60)

            // Error Message
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundColor(Color.theme.destructive)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Input Fields
            VStack(spacing: 16) {
                TextField("Email address", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.system(size: 16, design: .default))
                    .foregroundColor(Color.theme.textPrimary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(Color.theme.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                SecureField("Password", text: $viewModel.password)
                    .font(.system(size: 16, design: .default))
                    .foregroundColor(Color.theme.textPrimary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(Color.theme.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)

            // Action Button
            Button(action: {
                Haptics.shared.play(.medium)
                Task {
                    await viewModel.authenticate(using: authViewModel)
                }
            }) {
                Text(viewModel.isLoginMode ? "Log In" : "Sign Up")
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.theme.accentOrange)
                    .clipShape(Capsule())
            }
            .disabled(viewModel.isLoading)
            .opacity(viewModel.isLoading ? 0.7 : 1.0)
            .padding(.horizontal, 24)
            .padding(.top, 4)

            // Loading Indicator
            if viewModel.isLoading {
                ProgressView()
                    .tint(Color.theme.accentOrange)
            }

            Spacer()

            // Mode Toggle
            Button(action: {
                withAnimation {
                    viewModel.toggleMode()
                }
            }) {
                Text(viewModel.isLoginMode ? "Don't have an account? Sign up" : "Already have an account? Log in")
                    .font(.system(size: 15, weight: .medium, design: .default))
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
