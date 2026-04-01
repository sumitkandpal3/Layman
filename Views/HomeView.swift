import SwiftUI
import Combine

struct HomeView: View {
    @StateObject private var viewModel = NewsViewModel()
    @State private var isSearching = false
    @State private var selectedCarouselPage = 0
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                // Top Header transitioning to Search Bar
                HStack {
                    if isSearching {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color.theme.textSecondary)
                            
                            TextField("Search articles...", text: $viewModel.searchText)
                                .font(.system(size: 16, design: .default))
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                            
                            if !viewModel.searchText.isEmpty {
                                Button(action: { viewModel.searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color.theme.textSecondary.opacity(0.8))
                                }
                            }
                        }
                        .padding(12)
                        .background(Color.theme.secondaryBackground)
                        .clipShape(Capsule())
                        .transition(.opacity.combined(with: .offset(x: 20)))
                        
                        Button("Cancel") {
                            withAnimation(.spring()) {
                                Haptics.shared.play(.light)
                                viewModel.searchText = ""
                                isSearching = false
                            }
                        }
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(Color.theme.accentOrange)
                        .padding(.leading, 4)
                        
                    } else {
                        Text("Layman")
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundColor(Color.theme.textPrimary)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                Haptics.shared.play(.light)
                                isSearching = true
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color.theme.textSecondary)
                                .frame(width: 38, height: 38)
                                .background(Color.theme.secondaryBackground)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                if viewModel.isLoading && viewModel.featuredArticles.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 60)
                } else if isSearching {
                    // Search Mode Canvas
                    LazyVStack(spacing: 16) {
                        let activeResults = viewModel.searchText.isEmpty ? viewModel.todaysPicks : viewModel.searchResults
                        
                        if activeResults.isEmpty && !viewModel.searchText.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("No matches found")
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 80)
                        } else {
                            ForEach(activeResults) { article in
                                NavigationLink(destination: ArticleDetailView(
                                    article: article,
                                    displayTitle: viewModel.rewrittenTitles[article.id]
                                )) {
                                    ArticleRowCard(
                                        article: article,
                                        displayTitle: viewModel.rewrittenTitles[article.id]
                                    )
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                } else {
                    // Featured Carousel
                    if !viewModel.featuredArticles.isEmpty {
                        GeometryReader { geo in
                            TabView(selection: $selectedCarouselPage) {
                                ForEach(Array(viewModel.featuredArticles.enumerated()), id: \.offset) { index, article in
                                    NavigationLink(destination: ArticleDetailView(
                                        article: article,
                                        displayTitle: viewModel.rewrittenTitles[article.id]
                                    )) {
                                        FeaturedArticleCard(
                                            article: article,
                                            displayTitle: viewModel.rewrittenTitles[article.id]
                                        )
                                        .frame(width: geo.size.width - 40, height: 220)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(color: Color.theme.shadow, radius: 10, x: 0, y: 5)
                                    }
                                    .buttonStyle(ScaleButtonStyle())
                                    .tag(index)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .frame(width: geo.size.width, height: 220)
                        }
                        .frame(height: 220)

                        // Custom dots — sit cleanly BELOW the card
                        HStack(spacing: 6) {
                            ForEach(0..<viewModel.featuredArticles.count, id: \.self) { i in
                                Capsule()
                                    .fill(i == selectedCarouselPage
                                          ? Color.theme.accentOrange
                                          : Color.theme.accentOrange.opacity(0.25)
                                    )
                                    .frame(width: i == selectedCarouselPage ? 20 : 6, height: 6)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedCarouselPage)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 6)
                    }
                    
                    // Today's Picks Header
                    HStack {
                        Text("Today's Picks")
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(Color.theme.textPrimary)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Text("View All")
                                .font(.system(size: 14, weight: .semibold, design: .default))
                                .foregroundColor(Color.theme.accentOrange)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    
                    // List of articles
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.todaysPicks) { article in
                            NavigationLink(destination: ArticleDetailView(
                                article: article,
                                displayTitle: viewModel.rewrittenTitles[article.id]
                            )) {
                                ArticleRowCard(
                                    article: article,
                                    displayTitle: viewModel.rewrittenTitles[article.id]
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .background(Color.theme.background.ignoresSafeArea())
        .onAppear {
            setupAppearance()
            if viewModel.featuredArticles.isEmpty {
                Task {
                    await viewModel.fetchNews()
                }
            }
        }
    }
    
    private func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.theme.accentOrange)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.theme.accentOrange.opacity(0.25))
    }
}

// MARK: - Subcomponents

struct FeaturedArticleCard: View {
    let article: Article
    var displayTitle: String? = nil

    private var headline: String {
        displayTitle ?? article.title
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                // Background image pinned to exact card dimensions
                Group {
                    if let imgUrlString = article.image, let url = URL(string: imgUrlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .clipped()
                            case .failure:
                                cardGradient
                                    .frame(width: geo.size.width, height: geo.size.height)
                            default:
                                ShimmerView()
                                    .frame(width: geo.size.width, height: geo.size.height)
                            }
                        }
                    } else {
                        cardGradient
                            .frame(width: geo.size.width, height: geo.size.height)
                    }
                }

                // Bottom gradient overlay
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black.opacity(0.80), location: 0.0),
                        .init(color: .black.opacity(0.30), location: 0.55),
                        .init(color: .clear,               location: 1.0),
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(width: geo.size.width, height: 120)

                // Headline text
                Text(headline)
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 18)
                    .id(headline)
                    .animation(.easeInOut(duration: 0.3), value: headline)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var cardGradient: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color.theme.accentOrange, location: 0),
                .init(color: Color.theme.accentOrange.opacity(0.8), location: 1),
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct ArticleRowCard: View {
    let article: Article
    var displayTitle: String? = nil
    @State private var appeared = false
    
    private var visibleTitle: String {
        displayTitle ?? article.formattedTitle
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Thumbnail — hard fixed frame, no GeometryReader
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
                            ShimmerView()
                                .frame(width: 78, height: 78)
                        }
                    }
                } else {
                    Color.theme.secondaryBackground
                        .frame(width: 78, height: 78)
                }
            }
            .frame(width: 78, height: 78)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Title text — no lineLimit, grows freely
            Text(visibleTitle)
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundColor(Color.theme.textPrimary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .id(visibleTitle)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.25), value: visibleTitle)
        }
        .padding(12)
        .background(Color.theme.cardBackground)
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
    HomeView()
}
