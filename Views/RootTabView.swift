import SwiftUI

struct RootTabView: View {
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                HomeView()
            }
            .tag(0)
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            NavigationStack {
                SavedView()
            }
            .tag(1)
            .tabItem {
                Image(systemName: "bookmark")
                Text("Saved")
            }
                
            NavigationStack {
                ProfileView()
            }
            .tag(2)
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
        }
        .tint(Color.theme.accentOrange)
        .onChange(of: selection) { _ in
            Haptics.shared.play(.light)
        }
    }
}

#Preview {
    RootTabView()
}
