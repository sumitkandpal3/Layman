import SwiftUI
import Combine

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Layman")
                    .font(.theme.title)
                    .foregroundColor(Color.theme.textInfo)
                
                Text(viewModel.isLoginMode ? "Welcome back" : "Create an account")
                    .font(.theme.subtitle)
                    .foregroundColor(.gray)
            }
            .padding(.top, 40)
            
            // Error Message
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.theme.bodyText)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Input Fields
            VStack(spacing: 16) {
                TextField("Email address", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .softShadow()
                
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .softShadow()
            }
            .padding(.horizontal, 24)
            
            // Action Button
            Button(viewModel.isLoginMode ? "Log In" : "Sign Up") {
                Task {
                    await viewModel.authenticate(using: authViewModel)
                }
            }
            .buttonStyle(PillButtonStyle())
            .disabled(viewModel.isLoading)
            .opacity(viewModel.isLoading ? 0.7 : 1.0)
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
