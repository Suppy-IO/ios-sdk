//
//  Copyright © 2020 Suppy.io. All rights reserved.
//
//  swiftlint:disable cyclomatic_complexity function_body_length

import Foundation

internal protocol ResultHandler: class {
    func handle(dependencyType: Any.Type, defaultsKey: String, newValue: Any)
    @discardableResult
    func setNext(handler: ResultHandler) -> ResultHandler
}

internal class FetchResultHandler {

    private let chain: ResultHandler

    init(defaults: UserDefaults, logger: Logger?) {

        let urlHandler = URLHandler(defaults: defaults, logger: logger)
        let dateHandler = DateHandler(defaults: defaults, logger: logger)
        let defaultHandler = DefaultHandler(defaults: defaults, logger: logger)

        urlHandler.setNext(handler: dateHandler).setNext(handler: defaultHandler)

        chain = urlHandler
    }

    func handle(dependencyType: Any.Type, defaultsKey: String, newValue: Any) {
        chain.handle(dependencyType: dependencyType, defaultsKey: defaultsKey, newValue: newValue)
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

    func handle(dependencyType: Any.Type, defaultsKey: String, newValue: Any) {
        fatalError("not implemented")
    }

    func setNext(handler: ResultHandler) -> ResultHandler {
        self.nextHandler = handler
        return handler
    }

    func save(_ value: Any, forKey key: String) -> Bool {
        // prevents setting equal values
        guard isDifferent(value: value, key: key) else {
            return false // not modified
        }

        // making sure the appropriate UserDefaults
        // overload is used, otherwise it fails.
        if value as? NSNull != nil {
            defaults.set(nil, forKey: key)
        } else if let url = value as? URL {
            defaults.set(url, forKey: key)
        } else {
            defaults.set(value, forKey: key)
        }

        return true // modified
    }

    func log(key: String,
             value: Any,
             type: Any.Type,
             result: String,
             hasChanged: Bool,
             file: String = #file,
             function: String = #function) {

        if hasChanged {
            logger?.debug(
                "handled key: \"\(key)\", type \"\(type)\", " +
                    "raw value: \"\(value)\", final value: \"\(result)\"", file: file, function: function)
        } else {
            logger?.debug(
            "handled key: \"\(key)\", type \"\(type)\" - " +
                " no changes due to new value being equal to old value: \(value)", file: file, function: function)
        }
    }

    func isDifferent(value: Any, key: String) -> Bool {
        switch value.self {
        case is NSString:
            guard let newValue = value as? String else {
                return true
            }
            let oldValue = defaults.string(forKey: key)
            return newValue != oldValue
        case is NSNumber:
            guard let newValue = value as? NSNumber else {
                return true
            }
            let oldValue = NSNumber(value: defaults.double(forKey: key))
            return newValue != oldValue
        case is NSDate:
            guard let newValue = value as? Date,
                  let oldValue = defaults.object(forKey: key) as? Date
            else {
                return true
            }
            return newValue.compare(oldValue) != ComparisonResult.orderedSame
        case is NSArray:
            guard let newValue = value as? NSArray else {
                return true
            }
            let oldValue = NSArray(array: defaults.array(forKey: key) ?? [])
            return newValue != oldValue
        case is NSDictionary:
            guard let newValue = value as? NSDictionary else {
                return true
            }
            let oldValue = NSDictionary(dictionary: defaults.dictionary(forKey: key) ?? [:])
            return newValue != oldValue
        case is NSURL:
            guard let newValue = value as? NSURL,
                  let oldValue = defaults.url(forKey: key)
            else {
                return true
            }
            return newValue.absoluteString != oldValue.absoluteString
        case is Bool:
            guard let newValue = value as? Bool else {
                return true
            }
            let oldValue = defaults.bool(forKey: key)
            return newValue != oldValue
        case is NSNull:
            return defaults.value(forKey: key) != nil
        default: return true
        }
    }
}

/// URLHandler converts a String to URL and stores the result appropriately in the UserDefaults.
private final class URLHandler: BaseResultHandler {
    override func handle(dependencyType: Any.Type, defaultsKey: String, newValue: Any) {
        guard dependencyType is URL.Type,
              let urlString = newValue as? String else {
            nextHandler?.handle(dependencyType: dependencyType, defaultsKey: defaultsKey, newValue: newValue)
            return
        }
        // using URL instead of String because default.url resolves to a file scheme otherwise
        let url = URL(string: urlString)!
        let hasChanged = save(url, forKey: defaultsKey)

        log(key: defaultsKey,
            value: newValue,
            type: dependencyType,
            result: String(describing: url.absoluteString),
            hasChanged: hasChanged)
    }
}

/// Converts a Double to Date and stores the result appropriately in the UserDefaults.
private final class DateHandler: BaseResultHandler {
    override func handle(dependencyType: Any.Type, defaultsKey: String, newValue: Any) {
        guard dependencyType is Date.Type,
              let urlString = newValue as? Double else {
            nextHandler?.handle(dependencyType: dependencyType, defaultsKey: defaultsKey, newValue: newValue)
            return
        }
        // using URL instead of String because default.url resolves to a file scheme otherwise
        let date = Date(timeIntervalSince1970: urlString)
        let hasChanged = save(date, forKey: defaultsKey)

        log(key: defaultsKey,
            value: newValue,
            type: dependencyType,
            result: String(describing: date),
            hasChanged: hasChanged)
    }
}

/// DefaultHandler must be the last handler in the chain
/// and is responsible for handling any types which aren't
/// specifically handled. i.e. URL's are handled by URLHandler
/// therefore they do not reach DefaultHandler.
private final class DefaultHandler: BaseResultHandler {
    override func handle(dependencyType: Any.Type, defaultsKey: String, newValue: Any) {
        let hasChanged = save(newValue, forKey: defaultsKey)

        log(key: defaultsKey,
            value: newValue,
            type: dependencyType,
            result: String(describing: newValue),
            hasChanged: hasChanged)
    }
}
