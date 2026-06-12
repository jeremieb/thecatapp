//
//  Breed.swift
//  The Cat
//
//  Created by Jeremie Berduck on 11/6/26.
//

import Foundation

struct Breed: Identifiable, Decodable, Equatable {
    let id: String
    let name: String
    let temperament: String
    let origin: String
    let lifeSpan: String
    let description: String?
    let referenceImageId: String?

    var imageURL: URL? {
        guard let refId = referenceImageId else { return nil }
        return URL(string: "https://cdn2.thecatapi.com/images/\(refId).jpg")
    }

    enum CodingKeys: String, CodingKey {
        case id, name, temperament, origin, description
        case lifeSpan = "life_span"
        case referenceImageId = "reference_image_id"
    }
}

extension Breed {
    static let preview = Breed(
        id: "abys",
        name: "Abyssinian",
        temperament: "Active, Energetic, Independent, Intelligent, Gentle",
        origin: "Egypt",
        lifeSpan: "14 - 15",
        description: "The Abyssinian is easy to care for and a joy to have in your home. They're affectionate cats and love both people and other animals.",
        referenceImageId: "0XYvRd7oD"
    )
}
