//
//  Copyright © 2020 Suppy.io - All rights reserved.
//

import Foundation

@objc public class SuppyConfig: NSObject {

    private let context: Context
    private let fetcher: RetryExecutor
    private let logger: Logger?

    internal init(context: Context,
                  fetcher: RetryExecutor? = nil) {
        self.context = context
        self.logger = context.enableDebugMode ? Logger() : nil

        if let fetcher = fetcher {
            self.fetcher = fetcher
        } else {
            self.fetcher = RetryExecutor(with: ConfigFetcher(), logger: self.logger)
        }

        /// Registered defaults are never stored between runs of an application.
        ///
        /// Adds the registrationDictionary to the last item in every search list. This means that
        /// after NSUserDefaults has looked for a value in every other valid location,
        /// it will look in registered defaults.
        UserDefaults.standard.register(defaults: context.dependencies)
        super.init()
        self.logger?.debug("anonymous ID: \(anonymousId)")
    }
}

extension SuppyConfig {

    /// UUID that identifies an SDK instance
    public var anonymousId: String {
        return Persistence().anonymousId
    }

    /// Constructor
    ///
    /// Note on dependencies:
    ///     Dependencies have 2 functions:
    ///     1 - To specify the name and (value) type of configurations required by an app.
    ///     2 - fallback when configuration isn't returned from the server.
    ///
    /// - parameters:
    ///     - configId: Configuration used.
    ///     - applicationName: Application identifier seen in the web interface routing table.
    ///     - dependencies: Configurations required by the application.
    public convenience init(configId: String,
                            applicationName: String,
                            dependencies: [String: Any],
                            enableDebugMode: Bool = false) {

        let context = Context(configId: configId,
                              applicationName: applicationName,
                              dependencies: dependencies,
                              enableDebugMode: enableDebugMode)

        self.init(context: context)
    }

    /// Fetches the configuration correspondent to the init(configId:) parameter
    /// and updates the user defaults based on the init(dependencies:) parameter.
    ///
    /// - parameter completion: Called when fetching is complete irrespective of the result.
    public func fetchConfiguration(completion: (() -> Void)? = nil) {
        logger?.debug("Executing")
        fetcher.execute(context: context) { result in
            switch result {
            case let .success(fetchResult):
                self.handleSuccessFetch(fetchResult)
            case let .failure(error):
                self.logger?.error(error)
            }
            self.logger?.debug("Completed")
            completion?()
        }
    }

    /// Maps the configurations received from the server into the UserDefaults following the dependencies name and type.
    private func handleSuccessFetch(_ fetchResult: FetchResult) {
        switch fetchResult {
        case let .newData(data):
            guard let config = Config.fromData(data) else {
                logger?.debug(
                    """
                       Some data was returned but we were unable to parse it.
                       Data: \(String(data: data, encoding: .utf8) ?? "")
                    """)
                return
            }

            let defaults = UserDefaults.standard

            self.context.dependencies.forEach { key, value in
                guard let attribute = (config.attributes?.first { $0.name == key }) else {
                    logger?.debug("Dependency of name: \"\(key)\" was not returned from the server.")
                    return
                }

                guard let attributeValue = attribute.value else {
                    defaults.set(nil, forKey: attribute.name)
                    logger?.debug("Dependency of name: \"\(key)\" got assigned: nil")
                    return
                }

                let dependencyValueType = type(of: value)

                FetchResultHandler(defaults: defaults, logger: logger)
                    .handle(type: dependencyValueType,
                            key: key,
                            value: attributeValue)

            }
        case let .noData(httpStatusCode):
            logger?.debug("no data received - HTTP status code: \(httpStatusCode)")
        }
    }
}
