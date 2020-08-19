//
//  Copyright © 2020 Suppy.io - All rights reserved.
//

import Foundation

internal struct Context {
    /// Identifier of the configuration to be used.
    let configId: String
    /// Name of the application
    let applicationName: String
    /// Names and default values for cloud managed properties.
    let dependencies: [String: Any]
}
