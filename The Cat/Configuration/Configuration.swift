//
//  Configuration.swift
//  The Cat
//
//  Created by Jeremie Berduck on 11/6/26.
//

import Foundation

enum Configuration {
    enum Error: Swift.Error {
        case missingKey(String)
    }

    static func value(for key: String) throws -> String {
        guard let value = Bundle.main.infoDictionary?[key] as? String, !value.isEmpty else {
            throw Error.missingKey(key)
        }
        return value
    }

    static var catAPIKey: String {
        (try? value(for: "CAT_API_KEY")) ?? ""
    }
}
