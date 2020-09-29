//
//  Copyright © 2020 Suppy.io - All rights reserved.
//

import Foundation

enum FetchResult {
    case noData(Int)
    case newData(Data)
}

// Types of expected errors that can be discovered while parsing server responses.
enum FetchError: Error {
    case noResponse
    case invalidStatus(Int)
}

internal protocol DataFetchExecutor {
    func execute(context: Context, completion: @escaping (Result<FetchResult, Error>) -> Void)
}

// MARK: Helpers

internal extension DataFetchExecutor {
    var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    var bundleIdentifier: String {
        return Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? "bundle identifier"
    }

    var bundleVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }

    var osVersion: String {
        let osVersion = ProcessInfo().operatingSystemVersion
        let versionString =
            osVersion.majorVersion.description + "." +
            osVersion.minorVersion.description + "." +
            osVersion.patchVersion.description
        return versionString
    }
}
