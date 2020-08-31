//
//  Copyright © 2020 Suppy.io. All rights reserved.
//

import Foundation

class MockObserver: NSObject {

    private(set) var numberOfCalls = 0

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        numberOfCalls = numberOfCalls + 1
    }
}
