//
//  Copyright © 2020 Suppy.io. All rights reserved.
//

import Foundation

@objc public class SuppyConfig: NSObject {

    private let context: Context
    private let fetcher: RetryExecutor

    internal init(context: Context,
                  fetcher: RetryExecutor = RetryExecutor(with: ConfigFetcher())) {
        self.context = context
        self.fetcher = fetcher

        /// Registered defaults are never stored between runs of an application.
        ///
        /// Adds the registrationDictionary to the last item in every search list. This means that
        /// after NSUserDefaults has looked for a value in every other valid location,
        /// it will look in registered defaults.
        UserDefaults.standard.register(defaults: context.dependencies)
    }
}

extension SuppyConfig {

    /// UUID that identifies an SDK instance
    public var anonymousId: String {
        Persistence().anonymousId
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
                            dependencies: [String: Any]) {

        let context = Context(configId: configId,
                              applicationName: applicationName,
                              dependencies: dependencies)

        self.init(context: context)
    }

    /// Fetches the configuration correspondent to the init(configId:) parameter
    /// and updates the user defaults based on the init(dependencies:) parameter.
    ///
    /// - parameter completion: Called when fetching is complete.
    public func fetchConfiguration(completion: (() -> Void)? = nil) {
        fetcher.execute(context: context) { [weak self] result in
            guard
                let self = self,
                case let .success(data) = result,
                let config = Config.fromData(data)
            else {
                return
            }

            let defaults = UserDefaults.standard

            self.context.dependencies.forEach { key, value in
                guard let attribute = (config.attributes?.first { $0.name == key }) else {
                    return
                }

                let dependencyValueType = type(of: value)
                switch dependencyValueType {
                case is URL.Type:
                    guard let value = attribute.value else { return }
                    // using URL instead of String because default.url resolves to a file scheme otherwise
                    defaults.set(URL(string: value), forKey: attribute.name)
                case is Array<String>.Type:
                    guard
                        let value = attribute.value,
                        let data = value.data(using: .utf8),
                        let decoded = try? JSONSerialization.jsonObject(with: data, options: []),
                        let array = decoded as? [String]
                    else {
                        return
                    }
                    defaults.set(array, forKey: attribute.name)
                case is Dictionary<String, String>.Type:
                    guard
                        let value = attribute.value,
                        let data = value.data(using: .utf8),
                        let decoded = try? JSONSerialization.jsonObject(with: data, options: []),
                        let dictionary = decoded as? [String: String]
                    else {
                        return
                    }
                    defaults.set(dictionary, forKey: attribute.name)
                default:
                    defaults.set(attribute.value, forKey: attribute.name)
                }
            }

            completion?()
        }
    }
}
