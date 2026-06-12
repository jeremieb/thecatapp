//
//  CatAPIClient.swift
//  The Cat
//
//  Created by Jeremie Berduck on 11/6/26.
//

import Foundation

struct CatAPIClient: APIClientProtocol {
    private let session: URLSession
    private let apiKey: String
    private let baseURL = "https://api.thecatapi.com/v1"
    private let pageLimit = 12

    init(session: URLSession = .shared, apiKey: String = Configuration.catAPIKey) {
        self.session = session
        self.apiKey = apiKey
    }

    func fetchBreeds(page: Int) async throws -> [Breed] {
        guard var components = URLComponents(string: "\(baseURL)/breeds") else {
            throw APIError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(pageLimit)")
        ]
        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw APIError.unauthorized
        default:
            throw APIError.serverError(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode([Breed].self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
}
