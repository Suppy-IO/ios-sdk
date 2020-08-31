//
//  Copyright © 2020 Suppy.io. All rights reserved.
//

import Foundation

@objc public enum DependencyType: Int {

    case string
    case number
    case boolean
    case array
    case dictionary
    case url
    case date

    var description: String {
        switch self {
        case .string: return "String"
        case .number: return "Number"
        case .boolean: return "Boolean"
        case .array: return "Array"
        case .dictionary: return "Dictionary"
        case .url: return "URL"
        case .date: return "Date"
        }
    }

    func isAssignableFrom(value: Any) -> Bool {
        switch self {
        case .string: return value as? String != nil
        case .number: return value as? NSNumber != nil
        case .boolean: return value as? Bool != nil
        case .array: return value as? NSArray != nil
        case .dictionary: return value as? NSDictionary != nil
        case .url: return value as? URL != nil
        case .date: return value as? NSDate != nil
        }
    }
}

@objc public class Dependency: NSObject {
    /// Name of the attribute that must be matched on the server side
    let name: String
    /// The initial value of the attribute
    let value: Any
    let mappedType: DependencyType

    @objc public init(name: String, value: Any, mappedType: DependencyType) {
        self.name = name
        self.value = value
        self.mappedType = mappedType
    }

    public override var description: String {
        return "name: \(name) value: \(value) local type: \(type(of: value)) mapped type: \(mappedType)"
    }
}
