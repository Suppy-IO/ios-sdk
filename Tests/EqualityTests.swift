//
//  Copyright © 2020 Suppy.io. All rights reserved.
//

import XCTest

@testable import SuppyConfig

/// Tests meant to ensure that values received from
/// the server do not get written to the UserDefaults in case
/// the value has not changed.
///
/// Reasoning: Often, developers will track changes in specific
/// keys of UserDefaults with observers. We wasnt to avoid
/// false triggers.
class EqualityTests: XCTestCase {

    let userDefaultsSuiteName = "TestDefaults"
    var defaults: UserDefaults!
    let logger = Logger()

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removePersistentDomain(forName: userDefaultsSuiteName)
        defaults = UserDefaults(suiteName: userDefaultsSuiteName)
    }

    func testStringEquality() {
        defaults.set("value", forKey: "attribute")

        let handler = BaseResultHandler(defaults: defaults, logger: logger)
        let isDifferent = handler.isDifferent(value: "value", key: "attribute", mappedType: .string)

        XCTAssertFalse(isDifferent)
    }

    func testStringInequality() {
        defaults.set("value", forKey: "attribute")

        let handler = BaseResultHandler(defaults: defaults, logger: logger)
        let isDifferent = handler.isDifferent(value: "eulav", key: "attribute", mappedType: .string)

        XCTAssertTrue(isDifferent)
    }

    func testNumberEquality() {
        defaults.set(1, forKey: "integer")
        defaults.set(1.1234, forKey: "floating point")

        let handler = BaseResultHandler(defaults: defaults, logger: logger)
        let isIntegerDifferent = handler.isDifferent(value: 1, key: "integer", mappedType: .number)
        let isFloatingPointDifferent = handler.isDifferent(value: 1.1234, key: "floating point", mappedType: .number)

        XCTAssertFalse(isIntegerDifferent)
        XCTAssertFalse(isFloatingPointDifferent)
    }

    func testNumberInequality() {
        defaults.set(1, forKey: "integer")
        defaults.set(1.1234, forKey: "floating point")

        let handler = BaseResultHandler(defaults: defaults, logger: logger)
        let isIntegerDifferent = handler.isDifferent(value: -1, key: "integer", mappedType: .number)
        let isFloatingPointDifferent = handler.isDifferent(value: -1.1234, key: "floating point", mappedType: .number)

        XCTAssertTrue(isIntegerDifferent)
        XCTAssertTrue(isFloatingPointDifferent)
    }

    func testArrayEquality() {
        defaults.set([1, 2, 3], forKey: "array")

        let handler = BaseResultHandler(defaults: defaults, logger: logger)
        let isDifferent = handler.isDifferent(value: [1, 2, 3], key: "array", mappedType: .array)

        XCTAssertFalse(isDifferent)
    }

    func testArrayInequality() {
        defaults.set([1, 2, 3], forKey: "array")

        let handler = BaseResultHandler(defaults: defaults, logger: logger)
        let isDifferent = handler.isDifferent(value: [3, 2, 1], key: "array", mappedType: .array)

        XCTAssertTrue(isDifferent)
    }

    func testDictionaryEquality() {
        defaults.set(["x": "1", "y": "2"], forKey: "dictionary")

        let handler = BaseResultHandler(defaults: defaults, logger: logger)
        // items in different order
        let isDifferent = handler.isDifferent(value: ["y": "2", "x": "1"], key: "dictionary", mappedType: .dictionary)

        XCTAssertFalse(isDifferent)
    }

    func testDictionaryInequality() {
        defaults.set(["x": "1", "y": "2"], forKey: "dictionary")

        let handler = BaseResultHandler(defaults: defaults, logger: logger)
        let isDifferent = handler.isDifferent(value: ["x": "2", "y": "2"], key: "dictionary", mappedType: .dictionary)

        XCTAssertTrue(isDifferent)
    }

    func testDateEquality() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"

        let xDate = formatter.date(from: "2016/10/08 22:31")
        let yDate = formatter.date(from: "2016/10/08 22:31")

        defaults.set(xDate, forKey: "date")

        let handler = BaseResultHandler(defaults: defaults, logger: logger)
        let isDifferent = handler.isDifferent(value: yDate as Any, key: "date", mappedType: .date)

        XCTAssertFalse(isDifferent)
    }

    func testURLEquality() {
        let xURL = URL(string: "https://url.com")!
        let yURL = URL(string: "https://url.com")!

        defaults.set(xURL, forKey: "url")

        let handler = BaseResultHandler(defaults: defaults, logger: logger)
        let isDifferent = handler.isDifferent(value: yURL as Any, key: "url", mappedType: .url)

        XCTAssertFalse(isDifferent)
    }

    func testURLInequality() {
        let xURL = URL(string: "https://url.com")!
        let yURL = URL(string: "https://dev.url.com")!

        defaults.set(xURL, forKey: "url")

        let handler = BaseResultHandler(defaults: defaults, logger: logger)
        let isDifferent = handler.isDifferent(value: yURL as Any, key: "url", mappedType: .url)

        XCTAssertTrue(isDifferent)
    }

    func testNilEquality() {
        defaults.set(nil, forKey: "nil")

        let handler = BaseResultHandler(defaults: defaults, logger: logger)
        let isDifferent = handler.isDifferent(value: NSNull() as Any, key: "nil", mappedType: .string)

        XCTAssertFalse(isDifferent)
    }

    func testNilInequality() {
        let xURL = URL(string: "https://url.com")!

        defaults.set(xURL, forKey: "nil")

        let handler = BaseResultHandler(defaults: defaults, logger: logger)
        let isDifferent = handler.isDifferent(value: NSNull() as Any, key: "nil", mappedType: .url)

        XCTAssertTrue(isDifferent)
    }

    func testBoolEquality() {
        defaults.set(true, forKey: "bool")

        let handler = BaseResultHandler(defaults: defaults, logger: logger)
        let isDifferent = handler.isDifferent(value: true as Any, key: "bool", mappedType: .boolean)

        XCTAssertFalse(isDifferent)
    }

    func testBoolInequality() {
        defaults.set(true, forKey: "bool")

        let handler = BaseResultHandler(defaults: defaults, logger: logger)
        let isDifferent = handler.isDifferent(value: false as Any, key: "bool", mappedType: .boolean)

        XCTAssertTrue(isDifferent)
    }

    func testNilToFalseEquality() {
        defaults.set(nil, forKey: "bool")

        let handler = BaseResultHandler(defaults: defaults, logger: logger)
        let isDifferent = handler.isDifferent(value: false as Any, key: "bool", mappedType: .boolean)

        XCTAssertFalse(isDifferent)
    }

    func testNilToTrueInequality() {
        defaults.set(nil, forKey: "bool")

        let handler = BaseResultHandler(defaults: defaults, logger: logger)
        let isDifferent = handler.isDifferent(value: true as Any, key: "bool", mappedType: .boolean)

        XCTAssertTrue(isDifferent)
    }
}
