import SwiftUI
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoginMode = true
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func authenticate(using authViewModel: AuthViewModel) async {
        // Validation
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter an email address."
            return
        }
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email address."
            return
        }
        guard !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your password."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            if isLoginMode {
                try await authViewModel.login(email: email, password: password)
            } else {
                try await authViewModel.signUp(email: email, password: password)
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func toggleMode() {
        isLoginMode.toggle()
        errorMessage = nil
    }
}
