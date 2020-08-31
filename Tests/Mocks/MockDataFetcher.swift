//
//  Copyright © 2020 Suppy.io - All rights reserved.
//

import Foundation

@testable import SuppyConfig

internal class MockDataFetcher: DataFetchExecutor {

    var attributes: [[String: Any]] = []
    var numberOfCalls = 0
    var numberOfFailures = 0

    func execute(context: Context, completion: @escaping (Result<FetchResult, Error>) -> Void) {
        numberOfCalls += 1
        if numberOfCalls < numberOfFailures {
            completion(.failure(FetchError.invalidStatus(418)))
        } else {
            let config = ["attributes": attributes]
            let data = try? JSONSerialization.data(withJSONObject: config, options: [])
            completion(.success(FetchResult.newData(data!)))
        }
    }

    func addAttribute(name: String, value: Any) {
        attributes.append(["name": "attribute", "value": value])
    }
}
