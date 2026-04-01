import SwiftUI

struct SavedView: View {
    @StateObject private var viewModel = SavedViewModel()
    @State private var isSearching = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                // Top Custom Header transitioning identically
                HStack(alignment: .center) {
                    if isSearching {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("Search saved...", text: $viewModel.searchText)
                                .font(.system(size: 16, design: .rounded))
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                            
                            if !viewModel.searchText.isEmpty {
                                Button(action: { viewModel.searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color.gray.opacity(0.8))
                                }
                            }
                        }
                        .padding(12)
                        .background(Color(white: 0.95))
                        .clipShape(Capsule())
                        .transition(.opacity.combined(with: .offset(x: 20)))
                        
                        Button("Cancel") {
                            withAnimation(.spring()) {
                                viewModel.searchText = ""
                                isSearching = false
                            }
                        }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.816, green: 0.388, blue: 0.184))
                        .padding(.leading, 4)
                        
                    } else {
                        Text("Saved")
                            .font(.system(size: 28, weight: .bold, design: .default))
                            .foregroundColor(Color(red: 0.118, green: 0.098, blue: 0.086))
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                isSearching = true
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.30))
                                .frame(width: 38, height: 38)
                                .background(Color(red: 0.918, green: 0.906, blue: 0.894))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Content Loaders & Lists
                if viewModel.isLoading && viewModel.savedArticles.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 60)
                } else if viewModel.savedArticles.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No saved articles yet.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 100)
                } else {
                    LazyVStack(spacing: 16) {
                        if viewModel.filteredArticles.isEmpty && !viewModel.searchText.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("No matches found")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        } else {
                            ForEach(viewModel.filteredArticles) { savedArticle in
                                let targetArticle = savedArticle.asArticle
                                
                                NavigationLink(destination: ArticleDetailView(article: targetArticle)) {
                                    SavedArticleRowCard(article: targetArticle)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .background(Color(red: 0.973, green: 0.961, blue: 0.945).ignoresSafeArea())
        .onAppear {
            Task {
                await viewModel.fetchSaved()
            }
        }
    }
}

// MARK: - Saved Article Row Card
// Separate component so it doesn't conflict with HomeView's ArticleRowCard
private struct SavedArticleRowCard: View {
    let article: Article
    @State private var appeared = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Thumbnail — hard-coded frame BEFORE AsyncImage loads to prevent layout shift
            Group {
                if let imgUrlString = article.image, let url = URL(string: imgUrlString) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 78, height: 78)
                                .clipped()
                        } else {
                            Color(red: 0.87, green: 0.82, blue: 0.76)
                                .frame(width: 78, height: 78)
                        }
                    }
                } else {
                    Color(red: 0.87, green: 0.82, blue: 0.76)
                        .frame(width: 78, height: 78)
                }
            }
            .frame(width: 78, height: 78)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Title
            Text(article.formattedTitle)
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundColor(Color(red: 0.118, green: 0.098, blue: 0.086))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(12)
        .background(Color(red: 0.933, green: 0.906, blue: 0.875))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.35)) {
                appeared = true
            }
        }
    }
}

#Preview {
    SavedView()
}
