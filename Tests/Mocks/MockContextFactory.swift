//
//  Copyright © 2020 Suppy.io - All rights reserved.
//

import Foundation

@testable import SuppyConfig

internal class MockContextFactory {

    class func mock(dependencies: [String: Any] = [:]) -> Context {
        return Context(configId: "", applicationName: "", dependencies: dependencies)
    }
}
