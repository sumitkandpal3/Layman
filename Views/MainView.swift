import SwiftUI
import Combine

struct MainView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isInitializing {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading...")
                        .font(.theme.bodyText)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.theme.background.ignoresSafeArea())
            } else if authViewModel.isAuthenticated {
                RootTabView()
            } else {
                NavigationStack {
                    WelcomeView()
                }
            }
        }
        .environmentObject(authViewModel)
        .task {
            if authViewModel.isInitializing {
                await authViewModel.checkSession()
            }
        }
    }
}

#Preview {
    MainView()
}
