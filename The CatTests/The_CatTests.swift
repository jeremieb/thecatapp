//
//  The_CatTests.swift
//  The CatTests
//
//  Created by Jeremie Berduck on 11/6/26.
//

import Foundation
import Testing
@testable import The_Cat

// MARK: - Mock

final class MockAPIClient: APIClientProtocol, @unchecked Sendable {
    var result: Result<[Breed], Error>
    private(set) var callCount = 0

    init(result: Result<[Breed], Error> = .success([])) {
        self.result = result
    }

    func fetchBreeds(page: Int) async throws -> [Breed] {
        callCount += 1
        return try result.get()
    }
}

// MARK: - Helpers

private func makeBreeds(count: Int) -> [Breed] {
    (0..<count).map { i in
        Breed(id: "id-\(i)", name: "Breed \(i)", temperament: "Calm",
              origin: "Egypt", lifeSpan: "12 - 15", description: nil, referenceImageId: nil)
    }
}

// MARK: - Tests

@Suite("BreedListViewModel") @MainActor
struct BreedListViewModelTests {

    // MARK: Happy Path

    @Test func loadBreeds_success_populatesBreeds() async {
        let mock = MockAPIClient(result: .success(makeBreeds(count: 12)))
        let sut = BreedListViewModel(apiClient: mock)

        await sut.loadBreeds()

        #expect(sut.breeds.count == 12)
    }

    @Test func loadBreeds_success_setsLoadingFalse() async {
        let mock = MockAPIClient(result: .success(makeBreeds(count: 3)))
        let sut = BreedListViewModel(apiClient: mock)

        await sut.loadBreeds()

        #expect(!sut.isLoading)
    }

    // MARK: Failure Scenarios

    @Test func loadBreeds_networkError_setsErrorMessage() async {
        let mock = MockAPIClient(result: .failure(URLError(.notConnectedToInternet)))
        let sut = BreedListViewModel(apiClient: mock)

        await sut.loadBreeds()

        #expect(sut.breeds.isEmpty)
        #expect(sut.errorMessage != nil)
        #expect(!sut.isLoading)
    }

    @Test func loadBreeds_serverError_setsErrorMessage() async {
        let mock = MockAPIClient(result: .failure(APIError.serverError(500)))
        let sut = BreedListViewModel(apiClient: mock)

        await sut.loadBreeds()

        #expect(sut.errorMessage != nil)
    }

    @Test func loadBreeds_timeout_setsErrorMessage() async {
        let mock = MockAPIClient(result: .failure(URLError(.timedOut)))
        let sut = BreedListViewModel(apiClient: mock)

        await sut.loadBreeds()

        #expect(sut.breeds.isEmpty)
        #expect(sut.errorMessage != nil)
    }

    @Test func loadBreeds_decodingError_setsErrorMessage() async {
        let mock = MockAPIClient(result: .failure(APIError.decodingError))
        let sut = BreedListViewModel(apiClient: mock)

        await sut.loadBreeds()

        #expect(sut.errorMessage != nil)
    }

    @Test func loadBreeds_unauthorized_setsErrorMessage() async {
        let mock = MockAPIClient(result: .failure(APIError.unauthorized))
        let sut = BreedListViewModel(apiClient: mock)

        await sut.loadBreeds()

        #expect(sut.errorMessage?.contains("API key") == true)
    }

    @Test func loadBreeds_emptyResponse_showsEmptyState() async {
        let mock = MockAPIClient(result: .success([]))
        let sut = BreedListViewModel(apiClient: mock)

        await sut.loadBreeds()

        #expect(sut.breeds.isEmpty)
        #expect(sut.errorMessage == nil)
        #expect(!sut.hasMorePages)
    }

    // MARK: Retry / Resilience

    @Test func refresh_afterFailure_succeeds() async {
        let mock = MockAPIClient(result: .failure(APIError.unknown))
        let sut = BreedListViewModel(apiClient: mock)
        await sut.loadBreeds()

        mock.result = .success(makeBreeds(count: 5))
        await sut.refresh()

        #expect(sut.breeds.count == 5)
        #expect(sut.errorMessage == nil)
    }

    @Test func loadBreeds_paginates_appendsBreeds() async {
        let mock = MockAPIClient(result: .success(makeBreeds(count: 12)))
        let sut = BreedListViewModel(apiClient: mock)

        await sut.loadBreeds()
        await sut.loadBreeds()

        #expect(sut.breeds.count == 24)
        #expect(mock.callCount == 2)
    }

    @Test func loadBreeds_stopsWhenPageNotFull() async {
        let mock = MockAPIClient(result: .success(makeBreeds(count: 5)))
        let sut = BreedListViewModel(apiClient: mock)

        await sut.loadBreeds()
        await sut.loadBreeds() // guard: hasMorePages == false, no second fetch

        #expect(!sut.hasMorePages)
        #expect(mock.callCount == 1)
        #expect(sut.breeds.count == 5)
    }
}
