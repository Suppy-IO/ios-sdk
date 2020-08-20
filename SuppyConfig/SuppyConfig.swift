//
//  Copyright © 2020 Suppy.io - All rights reserved.
//

import Foundation

@objc public class SuppyConfig: NSObject {

    private let context: Context
    private let fetcher: RetryExecutor
    private let logger: Logger?

    internal init(context: Context,
                  fetcher: RetryExecutor = RetryExecutor(with: ConfigFetcher())) {
        self.context = context
        self.fetcher = fetcher
        self.logger = context.enableDebugMode ? Logger() : nil

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
            case let .success(data):
                self.handleSuccessFetch(data: data)
            case let .failure(error):
                self.handleFailureFetch(error: error)
            }
            self.logger?.debug("Completed")
            completion?()
        }
    }

    // swiftlint:disable function_body_length

    /// Maps the configurations received from the server into the UserDefaults following the dependencies name and type.
    private func handleSuccessFetch(data: Data) {
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

            let handlingResult: String
            switch dependencyValueType {

            case is URL.Type:
                // using URL instead of String because default.url resolves to a file scheme otherwise
                let url = URL(string: attributeValue)
                handlingResult = "assigned URL: \(String(describing: url?.absoluteString))"
                defaults.set(url, forKey: attribute.name)

            case is Array<String>.Type:
                guard
                    let data = attributeValue.data(using: .utf8),
                    let decoded = try? JSONSerialization.jsonObject(with: data, options: [])
                else {
                    handlingResult = "unable to decode the received data - assigning nil"
                    defaults.set(nil, forKey: attribute.name)
                    return
                }
                let array = decoded as? [String]
                handlingResult = "assigned Array<String>: \(String(describing: array))"
                defaults.set(array, forKey: attribute.name)

            case is Dictionary<String, String>.Type:
                guard
                    let data = attributeValue.data(using: .utf8),
                    let decoded = try? JSONSerialization.jsonObject(with: data, options: [])
                else {
                    handlingResult = "unable to decode the received data - assigning nil"
                    defaults.set(nil, forKey: attribute.name)
                    return
                }
                let dictionary = decoded as? [String: String]
                handlingResult = "assigned Dictionary<String, String>: \(String(describing: dictionary))"
                defaults.set(dictionary, forKey: attribute.name)

            default:
                handlingResult = "assigned value: \(String(describing: attribute.value))"
                defaults.set(attribute.value, forKey: attribute.name)
            }

            logger?.debug(
                "Handled dependency of name: \"\(key)\" and type \(dependencyValueType)" +
                " - received value: \(attributeValue) - \(handlingResult)")
        }
    }

    private func handleFailureFetch(error: Error) {
        switch error {
        case let FetchError.invalidStatus(statusCode):
            // HTTP Status Code 304 - "Not Modified" (RFC 7232)
            // Indicates that the resource has not been modified since the version specified by the
            // request headers If-Modified-Since or If-None-Match. In such case, there is no need to
            // retransmit the resource since the client still has a previously-downloaded copy.
            // source: https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
            if statusCode == 304 {
                self.logger?.debug("Configuration was not modified since the last fetch.")
            } else {
                self.logger?.error(error)
            }
        default:
            self.logger?.error(error)
        }
    }
}
