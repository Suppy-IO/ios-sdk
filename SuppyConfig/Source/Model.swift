//
//  Copyright © 2020 Suppy.IO - All rights reserved.
//

import Foundation

/// Structure of resources received from the server.
internal struct Attribute: Codable {

    let name: String
    let value: String?

    init(name: String, value: String?) {
        self.name = name
        self.value = value
    }
}

internal struct Config: Codable {

    private(set) var attributes: [Attribute]?

    init(attributes: [Attribute]? = nil) {
        self.attributes = attributes
    }

    internal static func fromData(_ data: Data) -> Config? {
        do {
            return try JSONDecoder().decode(Config.self, from: data)
        } catch {
            assertionFailure("failed to parse data: \(error)")
            return nil
        }
    }

    internal static func toData(_ config: Config) -> Data? {
        return try? JSONEncoder().encode(config)
    }
}
