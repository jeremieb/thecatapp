//
//  APIClientProtocol.swift
//  The Cat
//
//  Created by Jeremie Berduck on 11/6/26.
//

import Foundation

protocol APIClientProtocol {
    func fetchBreeds(page: Int) async throws -> [Breed]
}
