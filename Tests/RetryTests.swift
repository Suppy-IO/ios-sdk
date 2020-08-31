//
//  Copyright © 2020 Suppy.io - All rights reserved.
//

import XCTest

@testable import SuppyConfig

/// Tests that verify that our network retry logic works as expected.
class RetryTests: XCTestCase {

    func testRetriesMaxOut() {
        let attempts = 10
        let failures = 10
        let expects = 10

        let mockFetcher = MockDataFetcher()
        mockFetcher.numberOfFailures = failures

        let executor = RetryExecutor(attempts: attempts, delay: .seconds(0), with: mockFetcher)
        let completionExpectation = expectation(description: "completion should get called")

        executor.execute(context: MockContextFactory.mock()) { _ in
            completionExpectation.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }

        XCTAssertEqual(mockFetcher.numberOfCalls, expects)
    }

    func testRetriesUntilSuccess() {
        let attempts = 10
        let failures = 5
        let expects = 5

        let mockFetcher = MockDataFetcher()
        mockFetcher.numberOfFailures = failures

        let executor = RetryExecutor(attempts: attempts, delay: .seconds(0), with: mockFetcher)
        let completionExpectation = expectation(description: "completion should get called")

        // note that the retries amount is set above the expectation

        executor.execute(context: MockContextFactory.mock()) { _ in
            completionExpectation.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }

        XCTAssertEqual(mockFetcher.numberOfCalls, expects)
    }

    func testRealTest() {

        let dependencies = [Dependency(name: "Privacy Policy", value: URL(string: "https://default-local-url.com")!, mappedType: .url),
                            Dependency(name: "Application Title", value: "Initial App Title", mappedType: .string),
                            Dependency(name: "Recommended Version", value: "1.0.0", mappedType: .string),
                            Dependency(name: "Acceptance Ratio", value: 1.61803, mappedType: .number),
                            Dependency(name: "Number of Seats", value: 2, mappedType: .number),
                            Dependency(name: "Background Color", value: "white", mappedType: .string),
                            Dependency(name: "Product List", value: [], mappedType: .array)]

        let suppy = SuppyConfig(configId: "5f43879d25bc1e682f988129",
                                applicationName: "Swift Example",
                                dependencies: dependencies,
                                enableDebugMode: true)

        let completionExpectation = expectation(description: "completion should get called")

        suppy.fetchConfiguration {
            completionExpectation.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
