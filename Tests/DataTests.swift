//
//  DataTest.swift
//  Tests
//
//  Created by Ricardo Rautalahti-Hazan on 18.8.2020.
//  Copyright © 2020 Suppy.io - All rights reserved.
//

import XCTest

@testable import SuppyConfig

class DataTests: XCTestCase {

    let defaults = UserDefaults.standard

    override func setUp() {
        defaults.removeObject(forKey: "attribute")
    }

    func testStringAttribute() throws {
        let local = "local value"
        let remote = "remote value"

        let configFetcher = MockDataFetcher()
        configFetcher.attributes = [Attribute(name: "attribute", value: remote)]

        let dependencies = ["attribute": local]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.string(forKey: "attribute"), local)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.string(forKey: "attribute"), remote)
    }

    func testURLAttribute() throws {
        let local = "https://local-dummy-url.com?id=123"
        let remote = "https://remote-dummy-url.com?id=123"

        let configFetcher = MockDataFetcher()
        configFetcher.attributes = [Attribute(name: "attribute", value: remote)]

        let dependencies = ["attribute": URL(string: local)!]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.url(forKey: "attribute"), URL(string: local)!)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.url(forKey: "attribute"), URL(string: remote)!)
    }

    func testDateAttribute() throws {
        // Sunday, November 26, 2017
        let local = Date.init(timeIntervalSinceNow: 86400)
        // Today
        let remote = Date()

        let configFetcher = MockDataFetcher()
        configFetcher.attributes = [Attribute(name: "attribute", value: String(remote.timeIntervalSince1970))]

        let dependencies = ["attribute": local.timeIntervalSince1970]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.double(forKey: "attribute"), local.timeIntervalSince1970)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.double(forKey: "attribute"), remote.timeIntervalSince1970)
    }

    func testTrueToFalseBoolAttribute() throws {
        let local = true
        let remote = false

        let configFetcher = MockDataFetcher()
        configFetcher.attributes = [Attribute(name: "attribute", value: String(remote))]

        let dependencies = ["attribute": local]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.bool(forKey: "attribute"), local)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.bool(forKey: "attribute"), remote)
    }

    func testFalseToTrueBoolAttribute() throws {
        let local = false
        let remote = true

        let configFetcher = MockDataFetcher()
        configFetcher.attributes = [Attribute(name: "attribute", value: String(remote))]

        let dependencies = ["attribute": local]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.bool(forKey: "attribute"), local)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.bool(forKey: "attribute"), remote)
    }

    func testDictionary() throws {
        let localDictionary: [String: String] = ["x": "local x value", "y": "local y value"]

        let remoteDictionary = ["x": "remote x value", "y": "remote y value", "z": "remote z value"]
        let remoteData = try JSONSerialization.data(withJSONObject: remoteDictionary)
        let remote = String(data: remoteData, encoding: .utf8)

        let configFetcher = MockDataFetcher()
        configFetcher.attributes = [Attribute(name: "attribute", value: remote)]

        let dependencies = ["attribute": localDictionary]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher)

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
    }

    func testIntAttribute() throws {
        let local = 1
        let remote = 2

        let configFetcher = MockDataFetcher()
        configFetcher.attributes = [Attribute(name: "attribute", value: String(remote))]

        let dependencies = ["attribute": local]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.integer(forKey: "attribute"), local)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.integer(forKey: "attribute"), remote)
    }

    func testDoubleAttribute() throws {
        let local = 3.141592653589793238462643383279502884197169399375105820974944592307816 // PI
        let remote = 1.61803 // golden ratio

        let configFetcher = MockDataFetcher()
        configFetcher.attributes = [Attribute(name: "attribute", value: String(remote))]

        let dependencies = ["attribute": local]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.double(forKey: "attribute"), local)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.double(forKey: "attribute"), remote)
    }

    func testFloatAttribute() throws {
        let local: Float = 3.141592653589793238462643383279502884197169399375105820974944592307816 // PI
        let remote: Float = 1.61803 // golden ratio

        let configFetcher = MockDataFetcher()
        configFetcher.attributes = [Attribute(name: "attribute", value: String(remote))]

        let dependencies = ["attribute": local]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.float(forKey: "attribute"), local)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        XCTAssertEqual(defaults.float(forKey: "attribute"), remote)
    }

    func testArrayAttribute() throws {
        let local = ["a", "b", "c"]
        let remote = "[\"d\",\"e\",\"f\"]"

        let configFetcher = MockDataFetcher()
        configFetcher.attributes = [Attribute(name: "attribute", value: remote)]

        let dependencies = ["attribute": local]
        let context = MockContextFactory.mock(dependencies: dependencies)
        let fetcher = RetryExecutor(with: configFetcher)
        let suppy = SuppyConfig(context: context, fetcher: fetcher)

        // verifying that dependency value has been set as local value
        XCTAssertEqual(defaults.array(forKey: "attribute") as? [String], local)
        suppy.fetchConfiguration()
        // verifying that remote value has replaced local value
        let remoteArray = try? JSONSerialization.jsonObject(with: remote.data(using: .utf8)!) as? [String]
        XCTAssertEqual(defaults.array(forKey: "attribute") as? [String], remoteArray)
    }

}
