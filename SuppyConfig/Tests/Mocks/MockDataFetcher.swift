//
//  Copyright © 2020 Suppy.io - All rights reserved.
//

import Foundation

@testable import SuppyConfig

internal class MockDataFetcher: DataFetchable {

    var attributes: [Attribute]?
    var dependencies: [String: Any]?
    var numberOfCalls = 0
    var numberOfFailures = 0

    func execute(context: Context, completion: @escaping (Result<Data, Error>) -> Void) {
        numberOfCalls += 1
        if numberOfCalls <  numberOfFailures {
            completion(.failure(FetchError.invalidStatus(418)))
        } else {
            let data = Config.toData(Config(attributes: attributes))
            completion(.success(data!))
        }
    }
}
