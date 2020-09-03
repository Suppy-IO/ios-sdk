//
//  Copyright © 2020 Suppy.io - All rights reserved.
//

import Foundation

/// Structure of resources received from the server.
internal struct Attribute {

    let name: String
    let value: Any

    init(name: String, value: Any) {
        self.name = name
        self.value = value
    }
}

internal struct Config {

    private(set) var attributes: [Attribute]

    var hasAttributes: Bool {
        attributes.count > 0
    }

    init(attributes: [Attribute]? = nil) {
        self.attributes = attributes ?? []
    }

    init?(data: Data, logger: Logger?) {

        // Verifies that data can be converted into dictionary and
        // that the dictionary contain an "attributes" node containing
        // an array of dictionaries.

        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let node = root["attributes"] as? [[String: Any]]
        else {
            logger?.debug(
                """
                Some data was returned but we were unable to parse it.
                Data: \(String(data: data, encoding: .utf8) ?? "")
                """
            )
            return nil
        }

        // converting the attributes node [[String: Any]] -> Attribute type.

        let attributes = node.compactMap { attribute -> Attribute? in
            guard let name = attribute["name"] as? String else {
                let message = "Attribute lacked a name of type String: \(attribute)"
                assertionFailure(message)
                logger?.debug(message)
                return nil
            }

            let value = attribute["value"] ?? NSNull()
            return Attribute(name: name, value: value)
        }

        self.attributes = attributes
    }
}
