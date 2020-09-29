//
//  Copyright © 2020 Suppy.io - All rights reserved.
//

import Foundation

/// Helps information outlast the application life-cycle.
internal struct Persistence {

    enum SuiteKey {
        static let anonymousId = "anonymousId"
        static let etag = "etag"
        static let variantId = "variantId"
    }

    let suite = UserDefaults(suiteName: "suppy-config-suite")

    var anonymousId: String {
        if let anonymousId = suite?.value(forKey: SuiteKey.anonymousId) as? String {
            return anonymousId
        }
        let anonymousId = UUID().uuidString
        suite?.set(anonymousId, forKey: SuiteKey.anonymousId)
        return anonymousId
    }

    var etag: String? {
        suite?.string(forKey: SuiteKey.etag)
    }

    var variantId: String? {
        suite?.string(forKey: SuiteKey.variantId)
    }

    func save(etag response: URLResponse?) {
        guard
            let httpResponse = response as? HTTPURLResponse,
            let etag = httpResponse.allHeaderFields["Etag"] as? String
        else {
            return
        }
        suite?.set(etag, forKey: SuiteKey.etag)
    }

    func save(variantId: String?) {        
        suite?.set(variantId, forKey: SuiteKey.variantId)
    }
}
