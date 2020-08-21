//
//  Copyright © 2020 Suppy.io. All rights reserved.
//

import Foundation

internal protocol ResultHandler: class {
    func handle(type: Any.Type, key: String, value: String)
    @discardableResult
    func setNext(handler: ResultHandler) -> ResultHandler
}

internal class FetchResultHandler {

    private let chain: ResultHandler

    init(defaults: UserDefaults, logger: Logger?) {

        let urlHandler = URLHandler(defaults: defaults, logger: logger)
        let arrayHandler = ArrayHandler(defaults: defaults, logger: logger)
        let dictionaryHandler = DictionaryHandler(defaults: defaults, logger: logger)
        let defaultHandler = DefaultHandler(defaults: defaults, logger: logger)

        urlHandler
            .setNext(handler: dictionaryHandler)
            .setNext(handler: arrayHandler)
            .setNext(handler: defaultHandler)

        chain = urlHandler
    }

    func handle(type: Any.Type, key: String, value: String) {
        chain.handle(type: type, key: key, value: value)
    }
}

internal class BaseResultHandler: ResultHandler {

    private let defaults: UserDefaults

    private let logger: Logger?

    private(set) var nextHandler: ResultHandler?

    init(defaults: UserDefaults, logger: Logger?) {
        self.defaults = defaults
        self.logger = logger
    }

    func handle(type: Any.Type, key: String, value: String) {
        fatalError("not implemented")
    }

    func setNext(handler: ResultHandler) -> ResultHandler {
        self.nextHandler = handler
        return handler
    }

    func save(_ value: Any?, forKey key: String) {
        // making sure the appropriate UserDefaults
        // overload is used, otherwise it fails.
        if let url = value as? URL {
            defaults.set(url, forKey: key)
        } else {
            defaults.set(value, forKey: key)
        }
    }

    func log(key: String,
             value: String,
             type: Any.Type,
             result: String,
             file: String = #file,
             function: String = #function) {
        logger?.debug(
            "handled key: \"\(key)\", type \"\(type)\", " +
                "raw value: \"\(value)\", final value: \"\(result)\"", file: file, function: function)
    }
}

private final class DictionaryHandler: BaseResultHandler {
    override func handle(type: Any.Type, key: String, value: String) {
        guard type is Dictionary<String, String>.Type else {
            nextHandler?.handle(type: type, key: key, value: value)
            return
        }

        let dictionary: [String: String]?
        if let data = value.data(using: .utf8) {
            dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
        } else {
            dictionary = nil
        }

        save(dictionary, forKey: key)

        log(key: key,
            value: value,
            type: type,
            result: String(describing: dictionary))
    }
}

private final class ArrayHandler: BaseResultHandler {
    override func handle(type: Any.Type, key: String, value: String) {
        guard type is Array<String>.Type else {
            nextHandler?.handle(type: type, key: key, value: value)
            return
        }

        let array: [String]?
        if let data = value.data(using: .utf8) {
            array = try? JSONSerialization.jsonObject(with: data, options: []) as? [String]
        } else {
            array = nil
        }

        save(array, forKey: key)

        log(key: key,
            value: value,
            type: type,
            result: String(describing: array))
    }
}

/// URLHandler converts a String to URL and stores the result appropriately
/// in the UserDefaults.
private final class URLHandler: BaseResultHandler {
    override func handle(type: Any.Type, key: String, value: String) {
        guard type is URL.Type else {
            nextHandler?.handle(type: type, key: key, value: value)
            return
        }
        // using URL instead of String because default.url resolves to a file scheme otherwise
        let url = URL(string: value)!

        save(url, forKey: key)

        log(key: key,
            value: value,
            type: type,
            result: String(describing: url.absoluteString))
    }
}

/// DefaultHandler must be the last handler in the chain
/// and is responsible for handling any types which aren't
/// specifically handled. i.e. URL's are handled by URLHandler
/// therefore they do not reach DefaultHandler.
private final class DefaultHandler: BaseResultHandler {
    override func handle(type: Any.Type, key: String, value: String) {
        save(value, forKey: key)

        log(key: key,
            value: value,
            type: type,
            result: (String(describing: value)))
    }
}
