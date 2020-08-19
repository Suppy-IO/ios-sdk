//
//  Copyright © 2020 Suppy.IO - All rights reserved.
//

import Foundation

internal struct State: Codable {
    // latest version of remote config
    var remoteConfig: RemoteConfig?
    // latest successful configuration fetch date
    var latestFetchAt: Date?
    // identifier used to keep track of the amount of clients
    var mauID: String?
}

internal struct StateManager {

    private let paths = FileManager
        .default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("suppy-config-state")

    private(set) var state = State()

    init(dependencies: [Dependency]) {
        state.remoteConfig = RemoteConfig(headers: nil, attributes: nil, dependencies: dependencies)
        state.mauID = UUID().uuidString // gets overridden if cached

        guard FileManager.default.fileExists(atPath: paths.path) else {
            return // cannot decode what doesn't exist
        }
        do {
            // reading cached file
            let data = try Data(contentsOf: paths)

            // reading cached state
            self.state = try JSONDecoder().decode(State.self, from: data)
        } catch {
            // ignored - unable to parse the existing version
            assertionFailure("error \(error.localizedDescription) while retrieving configuration from cache")
        }
    }

    mutating func save(_ configuration: RemoteConfig) {
        do {
            // updating in-memory RemoteConfig
            self.state.remoteConfig = configuration
            // updating the latest fetched date
            self.state.latestFetchAt = Date()

            try JSONEncoder().encode(self.state).write(to: paths)
        } catch {
            // ignored - unable to store
            assertionFailure("error \(error.localizedDescription) while storing configuration data")
        }
    }
}
