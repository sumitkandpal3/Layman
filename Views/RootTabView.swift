import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            NavigationStack {
                SavedView()
            }
            .tabItem {
                Image(systemName: "bookmark")
                Text("Saved")
            }
                
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
        }
        .tint(Color.theme.accentOrange)
    }
}

#Preview {
    RootTabView()
}
