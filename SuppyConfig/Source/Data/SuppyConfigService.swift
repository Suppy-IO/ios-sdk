//
//  Copyright © 2020 Suppy.IO - All rights reserved.
//
import Foundation

internal class ConfigService {

    var context: Context

    private var stateManager: State
    private let configurationFetcher: RemoteConfigFetcher
    private let variantsFetcher: VariantsFetcher

    var configuration: Config {
        stateManager.remoteConfig
    }

    var configurationKeys: Set<String> {
        let attributeKeys = configuration.attributes?.map { $0.name } ?? []
        let dependencyKeys = context.dependencies.map { $0.name }
        return Set([attributeKeys, dependencyKeys].flatMap { $0 })
    }

    init(configID: String,
         applicationID: String,
         dependencies: [Dependency],
         variantID: String?) {
        self.stateManager = State()
        let mauID = stateManager.clientId
        self.context = Context(configID: configID,
                               applicationID: applicationID,
                               dependencies: dependencies,
                               mauID: mauID,
                               variantID: variantID)

        self.variantsFetcher = VariantsFetcher()
        self.configurationFetcher = RemoteConfigFetcher()
    }

    internal init(context: Context,
                  variantsFetcher: VariantsFetcher = VariantsFetcher(),
                  configurationFetcher: RemoteConfigFetcher = RemoteConfigFetcher()) {
        self.stateManager = State()
        self.context = context
        self.variantsFetcher = variantsFetcher
        self.configurationFetcher = configurationFetcher
    }

    private func dependency(forKey key: String) -> Attribute? {
        return context.dependencies
            .first(where: {$0.name == key})
            .flatMap({ (dependency) -> Attribute? in
                Attribute(name: dependency.name, value: dependency.defaultValue)
            })
    }

    func listVariants(completion: @escaping ([Variant]) -> Void) {
        FetchOnceExecutor().execute(context: context, fetcher: variantsFetcher) { result in
            switch result {
            case let .success(data):
                if let variants = Variant.fromData(data) {
                    completion(variants)
                } else {
                    completion([])
                }
            case .failure:
                completion([])
            }
        }
    }

    func use(variantID: String) {
        context.use(variantID: variantID)
    }

    func fetchConfiguration(completion: @escaping () -> Void) {
        FetchWithRetryExecutor().execute(context: context, fetcher: configurationFetcher) { [weak self] result in
            guard let self = self else {
                return
            }

            if  case let .success(data) = result,
                let remoteConfig = Config.fromData(data) {
                self.stateManager.update(remoteConfig: remoteConfig, eTag: "")
            }
            completion()
        }
    }

    func attribute(for key: String) -> Attribute? {
        return configuration.attributes?.first(where: { (attribute) -> Bool in
            attribute.name == key
        })
    }

    func url(forKey key: String, defaultValue: URL? = nil) -> URL? {
        guard let attribute = attribute(for: key) else {
            return defaultValue ?? dependency(forKey: key)?.url()
        }
        return attribute.url()
    }

    func int(forKey key: String, defaultValue: Int? = nil) -> Int? {
        guard let attribute = attribute(for: key) else {
            return defaultValue ?? dependency(forKey: key)?.int()
        }
        return attribute.int()
    }

    func string(forKey key: String, defaultValue: String? = nil) -> String? {
        guard let attribute = attribute(for: key) else {
            return defaultValue ?? dependency(forKey: key)?.value
        }
        return attribute.value
    }

    func bool(forKey key: String, defaultValue: Bool? = nil) -> Bool? {
        guard let attribute = attribute(for: key) else {
            return defaultValue ?? dependency(forKey: key)?.bool()
        }
        return attribute.bool()
    }

    func double(forKey key: String, defaultValue: Double? = nil) -> Double? {
        guard let attribute = attribute(for: key) else {
            return defaultValue ?? dependency(forKey: key)?.double()
        }
        return attribute.double()
    }

    func float(forKey key: String, defaultValue: Float? = nil) -> Float? {
        guard let attribute = attribute(for: key) else {
            return defaultValue ?? dependency(forKey: key)?.float()
        }
        return attribute.float()
    }

    func json(forKey key: String, defaultValue: [String: Any]? = nil) -> [String: Any]? {
        guard let attribute = attribute(for: key) else {
            return defaultValue ?? dependency(forKey: key)?.json()
        }
        return attribute.json()
    }
}
