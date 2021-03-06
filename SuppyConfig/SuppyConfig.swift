//
//  Copyright © 2020 Suppy.io - All rights reserved.
//

import Foundation

@objc public final class SuppyConfig: NSObject {

    private let context: Context
    private let configFetcher: RetryExecutor
    private let variantsFetcher: RetryExecutor
    private let defaults: UserDefaults
    private let logger: Logger?

    internal init(context: Context,
                  configFetcher: RetryExecutor? = nil,
                  variantsFetcher: RetryExecutor? = nil,
                  defaults: UserDefaults) {
        self.context = context
        self.defaults = defaults
        self.logger = context.enableDebugMode ? Logger() : nil

        if let fetcher = configFetcher {
            self.configFetcher = fetcher
        } else {
            self.configFetcher = RetryExecutor(with: ConfigFetcher(), logger: self.logger)
        }

        if let variantsFetcher = variantsFetcher {
            self.variantsFetcher = variantsFetcher
        } else {
            self.variantsFetcher = RetryExecutor(attempts: 1, with: VariantsFetcher(), logger: self.logger)
        }

        /// Registered defaults are never stored between runs of an application.
        ///
        /// Adds the registrationDictionary to the last item in every search list. This means that
        /// after NSUserDefaults has looked for a value in every other valid location,
        /// it will look in registered defaults.

        let defaultsRegister = context.dependencies.reduce(into: [:]) { (result, dependency) in
            result[dependency.name] = dependency.value
        }

        self.defaults.register(defaults: defaultsRegister)
        super.init()
        self.logger?.debug("anonymous ID: \(anonymousId)")
    }

    /// Maps the configurations received from the server into the UserDefaults following the dependencies name and type.
    private func handleSuccessFetch(_ fetchResult: FetchResult) {
        switch fetchResult {
        case let .newData(data):
            guard let config = Config(data: data, logger: logger),
                  config.hasAttributes
            else {
                return
            }

            self.context.dependencies.forEach { dependency in

                guard let attribute = (config.attributes.first { $0.name == dependency.name }) else {
                    logger?.debug("Dependency of name: \"\(dependency.name)\" was not returned from the server.")
                    return
                }

                FetchResultHandler(defaults: defaults, logger: logger)
                    .handle(mappedType: dependency.mappedType,
                            defaultsKey: dependency.name,
                            newValue: attribute.value)

            }
        case let .noData(httpStatusCode):
            logger?.debug("no data received - HTTP status code: \(httpStatusCode)")
        }
    }
}

extension SuppyConfig {

    /// UUID that identifies an SDK instance
    @objc public var anonymousId: String {
        return Persistence().anonymousId
    }

    /// Identifier of the variant to be used.
    @objc public var variantId: String? {
        get {
            Persistence().variantId
        }
        set {
            Persistence().save(variantId: newValue)
        }
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
    ///     - suiteName: Intializes a UserDefaults database using the specified name
    ///     @see https://developer.apple.com/documentation/foundation/userdefaults/1409957-init
    ///     - enableDebugMode: Outputs configuration fetching and processing information.
    @objc public convenience init(configId: String,
                                  applicationName: String,
                                  dependencies: [Dependency],
                                  suiteName: String? = nil,
                                  enableDebugMode: Bool = false) {

        let defaults: UserDefaults
        if let suiteName = suiteName,
           let defaultSuite = UserDefaults(suiteName: suiteName) {
            defaults = defaultSuite
        } else {
            defaults = UserDefaults.standard
        }

        let context = Context(configId: configId,
                              applicationName: applicationName,
                              dependencies: dependencies,
                              enableDebugMode: enableDebugMode)

        self.init(context: context, defaults: defaults)
    }

    /// Fetches the configuration correspondent to the init(configId:) parameter
    /// and updates the user defaults based on the init(dependencies:) parameter.
    ///
    /// - parameter completion: Called when fetching is complete irrespective of the result.
    @objc public func fetchConfiguration(completion: (() -> Void)? = nil) {
        logger?.debug("Fetching config")
        configFetcher.execute(context: context) { result in
            switch result {
            case let .success(fetchResult):
                self.handleSuccessFetch(fetchResult)
            case let .failure(error):
                self.logger?.error(error)
            }
            self.logger?.debug("Completed fetching config")
            completion?()
        }
    }

    /// Fetches variants of a configuration.
    ///
    /// - parameter completion: Called with a Dictionary<[String: String]> parameter
    /// when fetching is complete irrespective of the result.
    @objc public func fetchVariants(completion: (([String: String]) -> Void)? = nil) {
        logger?.debug("Fetching variants")
        variantsFetcher.execute(context: context) { result in
            var variants = [String: String]()
            switch result {
            case let .success(fetchResult):
                switch fetchResult {
                case let .newData(data):
                    variants = Variant.toDictionary(data: data, logger: self.logger)
                case let .noData(httpStatusCode):
                    self.logger?.debug("no variants received - HTTP status code: \(httpStatusCode)")
                }
            case let .failure(error):
                self.logger?.error(error)
            }
            self.logger?.debug("Completed fetching variants")
            completion?(variants) // completion must be called
        }
    }
}
