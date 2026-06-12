//
//  BreedListViewModel.swift
//  The Cat
//
//  Created by Jeremie Berduck on 11/6/26.
//

import Observation

@Observable
@MainActor
final class BreedListViewModel {
    private(set) var breeds: [Breed] = []
    private(set) var isLoading = false
    private(set) var isRefreshing = false
    private(set) var errorMessage: String? = nil

    private let apiClient: APIClientProtocol
    private var currentPage = 0
    private(set) var hasMorePages = true

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func loadBreeds() async {
        guard !isLoading, hasMorePages else { return }
        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await apiClient.fetchBreeds(page: currentPage)
            breeds.append(contentsOf: fetched)
            hasMorePages = fetched.count == 12
            currentPage += 1
        } catch let error as APIError {
            errorMessage = message(for: error)
        } catch {
            errorMessage = "An unexpected error occurred."
        }

        isLoading = false
    }

    func refresh() async {
        isRefreshing = true
        breeds = []
        currentPage = 0
        hasMorePages = true
        await loadBreeds()
        isRefreshing = false
    }

    private func message(for error: APIError) -> String {
        switch error {
        case .unauthorized:       return "Invalid API key. Please check your configuration."
        case .serverError(let c): return "Server error (\(c)). Please try again."
        case .decodingError:      return "Failed to parse server response."
        case .invalidURL:         return "Invalid request URL."
        case .unknown:            return "An unexpected error occurred."
        }
    }
}
