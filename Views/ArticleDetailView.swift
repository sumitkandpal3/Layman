import SwiftUI

struct ArticleDetailView: View {
    @Environment(\.dismiss) var dismiss
    let article: Article
    var displayTitle: String? = nil   // rewritten layman-style headline from NewsViewModel
    @StateObject private var bookmarkVM = BookmarkViewModel()
    @State private var showChatbot = false
    @State private var currentPage = 0
    
    var contentChunks: [String] {
        let text = article.description ?? "No summary provided by the source."
        return text.chunksOfSentences(2)
    }
    
    var body: some View {
        ZStack {
            // Warm off-white background matching screenshot
            Color(red: 0.973, green: 0.961, blue: 0.945).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Custom Header Bar
                HStack(spacing: 20) {
                    Button(action: {
                        Haptics.shared.play(.light)
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(white: 0.45))
                            .frame(width: 40, height: 40)
                            .background(Color(red: 0.918, green: 0.906, blue: 0.894))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Link
                    Button(action: {
                        Haptics.shared.play(.light)
                        UIPasteboard.general.string = article.url
                    }) {
                        Image(systemName: "link")
                            .font(.system(size: 19, weight: .medium))
                            .foregroundColor(Color(white: 0.60))
                    }
                    
                    // Bookmark
                    Button(action: {
                        Haptics.shared.play(.rigid)
                        bookmarkVM.toggleBookmark(article: article)
                    }) {
                        Image(systemName: bookmarkVM.isSaved ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 19, weight: .medium))
                            .foregroundColor(bookmarkVM.isSaved ? Color(red: 0.816, green: 0.388, blue: 0.184) : Color(white: 0.60))
                    }
                    
                    // Share (Native iOS 16 Hook)
                    if let url = URL(string: article.url) {
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 19, weight: .medium))
                                .foregroundColor(Color(white: 0.60))
                        }
                    } else {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 19, weight: .medium))
                            .foregroundColor(Color(white: 0.60))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // 1. Headline — show rewritten title if available
                        Text(displayTitle ?? article.title)
                            .font(.system(size: 22, weight: .bold, design: .default))
                            .foregroundColor(Color(red: 0.118, green: 0.098, blue: 0.086))
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 20)
                        
                        // 2. Bounded Image (Full width, explicitly capped)
                        if let imgString = article.image, let url = URL(string: imgString) {
                            GeometryReader { geo in
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geo.size.width, height: 220)
                                            .clipped()
                                    } else {
                                        Color(white: 0.88)
                                            .frame(width: geo.size.width, height: 220)
                                    }
                                }
                            }
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .padding(.horizontal, 20)
                        } else {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(white: 0.88))
                                .frame(height: 220)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 20)
                        }
                        
                        // 3. Horizontal Swipes (Exactly 6 Lines per card limit)
                        let chunksToRender = Array(contentChunks.prefix(3))
                        if !chunksToRender.isEmpty {
                            VStack(spacing: 10) {
                                TabView(selection: $currentPage) {
                                    ForEach(0..<chunksToRender.count, id: \.self) { index in
                                        let chunk = chunksToRender[index]
                                        Text(chunk)
                                            .font(.system(size: 16, weight: .regular, design: .rounded))
                                            .foregroundColor(Color(red: 0.38, green: 0.35, blue: 0.33))
                                            .lineSpacing(6)
                                            .lineLimit(nil)
                                            .minimumScaleFactor(0.9)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .topLeading)
                                            .padding(22)
                                            .frame(height: 190)
                                            .background(Color.white.opacity(0.9))
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                                            .padding(.horizontal, 20)
                                            .tag(index)
                                    }
                                }
                                .tabViewStyle(.page(indexDisplayMode: .never))
                                .frame(height: 200)

                                HStack(spacing: 6) {
                                    ForEach(0..<chunksToRender.count, id: \.self) { i in
                                        if i == currentPage {
                                            Capsule()
                                                .fill(Color(red: 0.816, green: 0.388, blue: 0.184))
                                                .frame(width: 20, height: 6)
                                        } else {
                                            Circle()
                                                .fill(Color(white: 0.78))
                                                .frame(width: 6, height: 6)
                                        }
                                    }
                                }
                                .animation(.spring(response: 0.3), value: currentPage)
                            }
                        }
                        
                        Spacer(minLength: 120) // Provide floating action button safety bounds below
                    }
                    .padding(.top, 10)
                }
            }
            
            // Fixed Bottom Button Overlay
            VStack {
                Spacer()
                
                Button(action: {
                    showChatbot = true // Activate AI
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Ask Layman")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(red: 0.816, green: 0.388, blue: 0.184))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showChatbot) {
            ChatView(article: article)
                .presentationDetents([.fraction(0.85), .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            setupAppearance()
        }
        .task {
            await bookmarkVM.checkInitialState(articleUrl: article.url)
        }
    }
    
    private func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(red: 0.816, green: 0.388, blue: 0.184, alpha: 1.0)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
}
