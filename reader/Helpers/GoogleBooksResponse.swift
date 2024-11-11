import SwiftUI

struct GoogleBooksResponse: Codable {
    let items: [BookItem]
}

struct BookItem: Codable {
    let volumeInfo: VolumeInfo
}

struct IndustryIdentifier: Codable {
    let type: String
    let identifier: String
}

struct VolumeInfo: Codable {
    let title: String
    let authors: [String]?
    let publishedDate: String
    let description: String?
    let publisher: String?
    let categories: [String]?
    let industryIdentifiers: [IndustryIdentifier]?
    let subtitle: String?
    let series: String?
}
