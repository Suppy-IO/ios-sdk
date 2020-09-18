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
}
