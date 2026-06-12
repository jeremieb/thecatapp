//
//  APIError.swift
//  The Cat
//
//  Created by Jeremie Berduck on 11/6/26.
//

import Foundation

enum APIError: Error, Equatable {
    case invalidURL
    case unauthorized
    case serverError(Int)
    case decodingError
    case unknown
}
