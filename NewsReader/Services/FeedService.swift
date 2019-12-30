//
//  FeedService.swift
//  NewsReader
//
//  Created by Aleksei Chupriienko on 12/6/19.
//  Copyright © 2019 Aleksei Chupriienko. All rights reserved.
//

import Foundation

struct FeedService {
    
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    
    func getFeeds(searchPhrase: String, completion: @escaping (([FeedItem]) -> Void)) {
        guard let strignUrl = "https://cloud.feedly.com/v3/search/feeds/?query=\(searchPhrase)&count=20".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed), let url = URL(string: strignUrl) else { return }
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let response = response as? HTTPURLResponse, let data = data else { return }
            switch response.statusCode {
            case 200:
                let decoder = JSONDecoder()
                do {
                    let feeds = try decoder.decode(FeedResponse.self, from: data)
                    completion(feeds.results)
                } catch {
                    print(error.localizedDescription)
                    
                }
            default: fatalError()
            }
        }
        .resume()
    }
}




