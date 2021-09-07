import Foundation
import UIKit

struct APIUnsplash {
    let accessKey = "y6GBW3R-3Wmm_Uetd_BHLds5wWLAn39Ik7LjHqGnR_c"
    
    let searchURLString = "https://api.unsplash.com/search/photos"
    let requestURLString = "?perPage=30&query="
    
    func fetchPhotos(for request: String, compition: @escaping ([String]) -> () ) {
        guard let url = URL(string: searchURLString + requestURLString + request) else {
            return
        }
        var urlRequest:URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            do {
                if let data = data {
                    let collection = try JSONDecoder().decode(UnsplashData.self, from: data)
                    var imageURLArray : [String] = []
                    collection.results.forEach { result in
                        imageURLArray.append(result.urls.regular)
                    }
                    compition(imageURLArray)
                }
            } catch let error {
                print(error)
            }

        }.resume()
    }
}



