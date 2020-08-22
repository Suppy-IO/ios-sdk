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

    var description: String {
        switch self {
        case .string: return "String"
        case .number: return "Number"
        case .boolean: return "Boolean"
        case .array: return "Array"
        case .dictionary: return "Dictionary"
        case .url: return "URL"
        }
    }
}

@objc public class Dependency: NSObject {

    let name: String
    let value: Any
    let mappedType: DependencyType

    @objc public init(name: String, value: Any, type: DependencyType) {
        self.name = name
        self.value = value
        self.mappedType = type
    }

    public override var description: String {
        return "name: \(name) value: \(value) local type: \(type(of: value)) mapped type: \(mappedType)"
    }
}
