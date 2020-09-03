//
//  Copyright © 2020 Suppy.io - All rights reserved.
//

import Foundation

internal protocol DataFetchExecutor {
    func execute(context: Context, completion: @escaping (Result<FetchResult, Error>) -> Void)
}
