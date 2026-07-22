import Foundation

struct MatchItem: Decodable, Identifiable, Hashable {
    var id: String { title }
    let title: String
    let detail: String
}

struct TailorResult: Decodable {
    let alignmentScore: Int
    let matched: [MatchItem]
    let gaps: [MatchItem]
    let tailoredResume: String
}
