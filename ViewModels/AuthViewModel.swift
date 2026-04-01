import SwiftUI
import Combine
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userEmail: String = ""
    @Published var isAuthenticated = false
    @Published var isInitializing = true
    @Published var globalError: String?

    private let supabaseService: SupabaseService

    init(supabaseService: SupabaseService? = nil) {
        self.supabaseService = supabaseService ?? SupabaseService()
    }

    func checkSession() async {
        isInitializing = true
        do {
            let session = try await supabaseService.restoreSession()
            self.userEmail = session.user.email ?? ""
            self.isAuthenticated = true
        } catch {
            self.isAuthenticated = false
        }
        isInitializing = false
    }

    func login(email: String, password: String) async throws {
        let session = try await supabaseService.login(email: email, password: password)
        self.userEmail = session.user.email ?? email
        self.isAuthenticated = true
    }

    func signUp(email: String, password: String) async throws {
        _ = try await supabaseService.signUp(email: email, password: password)
        self.userEmail = email
        self.isAuthenticated = true
    }

    func logout() async {
        do {
            try await supabaseService.logout()
            self.isAuthenticated = false
        } catch {
            self.globalError = error.localizedDescription
        }
    }
}
