import Foundation

struct NewsData: Codable {
    let articles: [Articles]
}

struct Articles: Codable {
    let source: Sources
    let title: String
    let urlToImage: String?
    let publishedAt: String
    let url: String
}

struct Sources: Codable {
    let name: String
}
