//
//  Copyright © 2020 Suppy.io - All rights reserved.
//

import XCTest

@testable import SuppyConfig

/// Tests meant to ensure that the different supported
/// data types are properly received and mapped in UserDefaults.
class AttributeTests: XCTestCase {

    let userDefaultsSuiteName = "TestDefaults"
    var defaults: UserDefaults!
    var observer: MockObserver?

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removePersistentDomain(forName: userDefaultsSuiteName)
        defaults = UserDefaults(suiteName: userDefaultsSuiteName)

        let observer = MockObserver()
        self.observer = observer
        defaults.addObserver(observer, forKeyPath: "attribute", options: [.new], context: nil)
    }

    override func tearDown() {
        guard let observer = self.observer else { return }
        defaults.removeObserver(observer, forKeyPath: "attribute")
        super.tearDown()
    }

    func testStringAttribute() throws {
        let local = "a local value"
        let remote = "a remote value"

        let configFetcher = MockDataFetcher()
        configFetcher.addAttribute(name: "attribute", value: remote)

        let dependencies = [Dependency(name: "attribute", value: local, mappedType: .string)]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher, defaults: defaults)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.string(forKey: "attribute"), local)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.string(forKey: "attribute"), remote)
        XCTAssertEqual(observer?.numberOfCalls, 2)
    }

    func testURLAttribute() throws {
        let local = "https://local-dummy-url.com?id=123"
        let remote = "https://remote-dummy-url.com?id=123"

        let configFetcher = MockDataFetcher()
        configFetcher.addAttribute(name: "attribute", value: remote)

        let dependencies = [Dependency(name: "attribute", value: URL(string: local)!, mappedType: .url)]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher, defaults: defaults)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.url(forKey: "attribute"), URL(string: local)!)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.url(forKey: "attribute"), URL(string: remote)!)
        XCTAssertEqual(observer?.numberOfCalls, 2)
    }

    func testTrueToFalseBoolAttribute() throws {
        let local = true
        let remote = false

        let configFetcher = MockDataFetcher()
        configFetcher.addAttribute(name: "attribute", value: remote)

        let dependencies = [Dependency(name: "attribute", value: local, mappedType: .boolean)]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher, defaults: defaults)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.bool(forKey: "attribute"), local)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.bool(forKey: "attribute"), remote)
        XCTAssertEqual(observer?.numberOfCalls, 2)
    }

    func testFalseToTrueBoolAttribute() throws {
        let local = false
        let remote = true

        let configFetcher = MockDataFetcher()
        configFetcher.addAttribute(name: "attribute", value: remote)

        let dependencies = [Dependency(name: "attribute", value: local, mappedType: .boolean)]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher, defaults: defaults)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.bool(forKey: "attribute"), local)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.bool(forKey: "attribute"), remote)
        XCTAssertEqual(observer?.numberOfCalls, 2)
    }

    func testDictionary() throws {
        let localDictionary: [String: String] = ["x": "local x value", "y": "local y value"]

        let remoteDictionary = ["x": "remote x value", "y": "remote y value", "z": "remote z value"]

        let configFetcher = MockDataFetcher()
        configFetcher.addAttribute(name: "attribute", value: remoteDictionary)

        let dependencies = [Dependency(name: "attribute", value: localDictionary, mappedType: .dictionary)]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher, defaults: defaults)

        // verifying that dependency value has been set as local value

        let localDictionaryFromDefaults = defaults.dictionary(forKey: "attribute")!

        XCTAssertEqual(localDictionaryFromDefaults["x"] as? String, localDictionary["x"])
        XCTAssertEqual(localDictionaryFromDefaults["y"] as? String, localDictionary["y"])

        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value

        let remoteDictionaryFromDefaults = defaults.dictionary(forKey: "attribute")!

        XCTAssertEqual(remoteDictionaryFromDefaults["x"] as? String, remoteDictionary["x"])
        XCTAssertEqual(remoteDictionaryFromDefaults["y"] as? String, remoteDictionary["y"])
        XCTAssertEqual(remoteDictionaryFromDefaults["z"] as? String, remoteDictionary["z"])
        XCTAssertEqual(observer?.numberOfCalls, 2)
    }

    func testIntAttribute() throws {
        let local = 1
        let remote = 2

        let configFetcher = MockDataFetcher()
        configFetcher.addAttribute(name: "attribute", value: remote)

        let dependencies = [Dependency(name: "attribute", value: local, mappedType: .number)]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher, defaults: defaults)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.integer(forKey: "attribute"), local)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.integer(forKey: "attribute"), remote)
        XCTAssertEqual(observer?.numberOfCalls, 2)
    }

    func testDoubleAttribute() throws {
        let local = 3.141592653589793238462643383279502884197169399375105820974944592307816 // PI
        let remote = 1.61803 // golden ratio

        let configFetcher = MockDataFetcher()
        configFetcher.addAttribute(name: "attribute", value: remote)

        let dependencies = [Dependency(name: "attribute", value: local, mappedType: .number)]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher, defaults: defaults)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.double(forKey: "attribute"), local)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.double(forKey: "attribute"), remote)
        XCTAssertEqual(observer?.numberOfCalls, 2)
    }

    func testFloatAttribute() throws {
        let local: Float = 3.141592653589793238462643383279502884197169399375105820974944592307816 // PI
        let remote: Float = 1.61803 // golden ratio

        let configFetcher = MockDataFetcher()
        configFetcher.addAttribute(name: "attribute", value: remote)

        let dependencies = [Dependency(name: "attribute", value: local, mappedType: .number)]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher, defaults: defaults)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.float(forKey: "attribute"), local)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.float(forKey: "attribute"), remote)
        XCTAssertEqual(observer?.numberOfCalls, 2)
    }

    func testArrayAttribute() throws {
        let local = ["a", "b", "c"]
        let remote = ["d", "e", "f"]

        let configFetcher = MockDataFetcher()
        configFetcher.addAttribute(name: "attribute", value: remote)

        let dependencies = [Dependency(name: "attribute", value: local, mappedType: .array)]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher, defaults: defaults)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.array(forKey: "attribute") as? [String], local)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.array(forKey: "attribute") as? [String], remote)
        XCTAssertEqual(observer?.numberOfCalls, 2)
    }

    func testEqualArrayAttribute() throws {
        let local = ["a", "b", "c"]
        let remote = ["a", "b", "c"]

        let configFetcher = MockDataFetcher()
        configFetcher.addAttribute(name: "attribute", value: remote)

        let dependencies = [Dependency(name: "attribute", value: local, mappedType: .array)]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher, defaults: defaults)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.array(forKey: "attribute") as? [String], local)
        suppy.fetchConfiguration()
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.array(forKey: "attribute") as? [String], remote)
        XCTAssertEqual(observer?.numberOfCalls, 1)
    }

    func testDateAsDateAttribute() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"

        let local = formatter.date(from: "1999/01/01 00:00")!
        let remote = formatter.date(from: "2016/10/08 22:31")!

        let configFetcher = MockDataFetcher()
        configFetcher.addAttribute(name: "attribute", value: remote.timeIntervalSince1970)

        let dependencies = [Dependency(name: "attribute", value: local as Any, mappedType: .date)]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher, defaults: defaults)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.object(forKey: "attribute") as? Date, local)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.object(forKey: "attribute") as? Date, remote)
        XCTAssertEqual(observer?.numberOfCalls, 2)
    }

    func testDateAsDoubleAttribute() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"

        let local = formatter.date(from: "1999/01/01 00:00")!
        let remote = formatter.date(from: "2016/10/08 22:31")!

        let configFetcher = MockDataFetcher()
        configFetcher.addAttribute(name: "attribute", value: remote.timeIntervalSince1970)

        let dependencies = [Dependency(name: "attribute", value: local.timeIntervalSince1970, mappedType: .number)]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher, defaults: defaults)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.double(forKey: "attribute"), local.timeIntervalSince1970)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.double(forKey: "attribute"), remote.timeIntervalSince1970)
        XCTAssertEqual(observer?.numberOfCalls, 2)
    }

    func testNullValueAttribute() throws {
        let local = "local value"
        let remote: String? = nil

        let configFetcher = MockDataFetcher()
        configFetcher.addAttribute(name: "attribute", value: remote as Any)

        let dependencies = [Dependency(name: "attribute", value: local, mappedType: .string)]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher, defaults: defaults)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.string(forKey: "attribute"), local)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.string(forKey: "attribute"), local)
        XCTAssertEqual(observer?.numberOfCalls, 1)
    }

}
