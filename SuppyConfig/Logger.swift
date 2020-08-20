//
//  Copyright © 2020 Suppy.io. All rights reserved.
//

import Foundation

struct Logger {

    func debug(_ message: String, callingFunction: String = #function) {
        print("[\(NSStringFromClass(SuppyConfig.self)) \(callingFunction)] - \(message)")
    }

    func error(_ error: Error, callingFunction: String = #function) {
        print("[\(NSStringFromClass(SuppyConfig.self)) \(callingFunction)] - \(error)")
    }
}
