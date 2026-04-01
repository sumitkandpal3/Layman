import SwiftUI

struct ChatView: View {
    let article: Article
    @StateObject private var viewModel: ChatViewModel
    @State private var inputText: String = ""
    @FocusState private var isFocused: Bool
    
    init(article: Article) {
        self.article = article
        _viewModel = StateObject(wrappedValue: ChatViewModel(article: article))
    }
    
    // Theme dynamic colors
    private var bgColor: Color        { Color.theme.background }
    private var botBubble: Color      { Color.theme.cardBackground }
    private var userBubble: Color     { Color.theme.secondaryBackground }
    private var orangeAccent: Color   { Color.theme.accentOrange }
    private var suggestionPill: Color { Color.theme.suggestionPill }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        ForEach(viewModel.messages) { message in
                            if message.isUser {
                                UserMessageBubble(text: message.content, bubbleColor: userBubble, orangeAccent: orangeAccent)
                                    .id(message.id)
                            } else {
                                BotMessageBubble(text: message.content, bubbleColor: botBubble, orangeAccent: orangeAccent)
                                    .id(message.id)
                            }
                        }
                        
                        if viewModel.isTyping {
                            HStack {
                                Circle()
                                    .fill(orangeAccent)
                                    .frame(width: 32, height: 32)
                                    .overlay(Image(systemName: "sparkles").foregroundColor(.white).font(.system(size: 14, weight: .bold)))
                                
                                Text("Thinking...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .padding(.leading, 8)
                            }
                            .padding(.horizontal, 20)
                            .id("typing")
                        }
                        
                        // Show suggestions instantly (only when user hasn't typed anything yet)
                        if viewModel.messages.count == 1 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Question Suggestions:")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.gray)
                                    .padding(.top, 12)
                                    .padding(.bottom, 4)
                                
                                if viewModel.isSuggestionsLoading {
                                    ProgressView()
                                        .padding(.leading, 10)
                                        .padding(.top, 4)
                                } else {
                                    ForEach(viewModel.suggestions, id: \.self) { suggestion in
                                        Button(action: {
                                            Haptics.shared.play(.light)
                                            viewModel.sendMessage(suggestion)
                                        }) {
                                            Text(suggestion)
                                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 14)
                                                .background(suggestionPill)
                                                .clipShape(Capsule())
                                        }
                                        .transition(.scale(scale: 0.85).combined(with: .opacity))
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            .id("suggestions")
                            .task {
                                await viewModel.loadSuggestions()
                            }
                        }
                        
                        Spacer().frame(height: 10).id("bottom")
                    }
                    .padding(.vertical, 24)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                .onChange(of: isFocused) { focused in
                    if focused {
                        withAnimation {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
            }
            
            // Fixed Input Bar
            HStack(spacing: 14) {
                TextField("Type your question...", text: $inputText)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(Color.theme.textPrimary)
                    .focused($isFocused)
                    .submitLabel(.send)
                    .onSubmit {
                        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        Haptics.shared.play(.medium)
                        viewModel.sendMessage(inputText)
                        inputText = ""
                    }
                
                Image(systemName: "mic")
                    .font(.system(size: 18))
                    .foregroundColor(Color(white: 0.55))
                
                Button(action: {
                    guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    Haptics.shared.play(.medium)
                    viewModel.sendMessage(inputText)
                    inputText = ""
                }) {
                    Circle()
                        .fill(orangeAccent)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .offset(x: -1, y: 1)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.theme.secondaryBackground)
            .clipShape(Capsule())
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 8)
        }
        .background(bgColor.ignoresSafeArea())
    }
}

// MARK: - Subcomponents

struct BotMessageBubble: View {
    let text: String
    let bubbleColor: Color
    let orangeAccent: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Bot Avatar — solid orange circle with sparkles
            Circle()
                .fill(orangeAccent)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "sparkles")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                )
            
            Text(text)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(Color.theme.textPrimary)
                .lineSpacing(4)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(bubbleColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Spacer(minLength: 40)
        }
        .padding(.horizontal, 20)
    }
}

struct UserMessageBubble: View {
    let text: String
    let bubbleColor: Color
    let orangeAccent: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Spacer(minLength: 40)
            
            Text(text)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(Color.theme.textPrimary)
                .lineSpacing(4)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(bubbleColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Circle()
                .fill(Color.theme.cardBackground)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(orangeAccent)
                        .font(.system(size: 14))
                )
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ChatView(article: Article(id: "1", title: "Apple enters AI market", description: "Apple is building new models.", image: nil, url: "https://apple.com"))
}
