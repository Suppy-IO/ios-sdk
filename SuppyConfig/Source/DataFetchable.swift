//
//  Copyright © 2020 Suppy.io. All rights reserved.
//

import Foundation

internal protocol DataFetchable {
    func execute(context: Context, completion: @escaping (Result<Data, Error>) -> Void)
}
