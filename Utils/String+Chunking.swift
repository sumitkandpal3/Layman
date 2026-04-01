import Foundation

extension String {
    /// Splits a bulk block of text into chunks of specified sentence counts.
    func chunksOfSentences(_ count: Int) -> [String] {
        var sentences: [String] = []
        
        self.enumerateSubstrings(in: self.startIndex..<self.endIndex, options: .bySentences) { (substring, _, _, _) in
            if let sentence = substring?.trimmingCharacters(in: .whitespacesAndNewlines), !sentence.isEmpty {
                sentences.append(sentence)
            }
        }
        
        var chunks: [String] = []
        for i in stride(from: 0, to: sentences.count, by: count) {
            let endIndex = min(i + count, sentences.count)
            let chunk = sentences[i..<endIndex].joined(separator: " ")
            chunks.append(chunk)
        }
        
        if chunks.isEmpty {
            chunks = ["No description available for this article.", "Check the original link for more info."]
        }
        
        return chunks
    }
}
