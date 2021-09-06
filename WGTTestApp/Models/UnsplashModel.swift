import Foundation

struct UnsplashData: Codable {
    let results: [Result]
}

struct Result: Codable {
    let id: String
    let urls: Urls
}

struct Urls: Codable {
    let raw, full, regular, small: String
    let thumb: String
}
