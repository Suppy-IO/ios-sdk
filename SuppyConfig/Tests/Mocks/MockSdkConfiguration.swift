//
//  Copyright © 2020 Suppy.IO - All rights reserved.
//

import Foundation

@testable import SuppyConfig

internal struct MockContextFactory: SuppySdkConfiguration {

    var configID: String = ""
    var applicationID: String = ""
    var useProductionEnvironment: Bool = false
    var dependencies: [Dependency] = []
    var variantID: String?

    init() {}

    init(dependencies: [Dependency]) {
        self.dependencies = dependencies
    }
}
