//
//  Copyright © 2020 Suppy.io - All rights reserved.
//

import Foundation

/// Executor that retries upon failure.
internal struct RetryExecutor {
    /// Amount of times a fetcher will be executed.
    let attempts: Int
    /// Amount of delay between executions in case of failures.
    let delay: DispatchTimeInterval
    /// Object that talks to the server.
    let fetcher: DataFetchExecutor
    /// Logs debug messages.
    let logger: Logger?

    init(attempts: Int = 10,
         delay: DispatchTimeInterval = .seconds(10),
         with fetcher: DataFetchExecutor,
         logger: Logger? = nil) {
        self.attempts = attempts
        self.delay = delay
        self.fetcher = fetcher
        self.logger = logger
    }

    func execute(context: Context,
                 completion: @escaping (Result<FetchResult, Error>) -> Void) {
        retry(attempts,
              delay: delay,
              task: { result in
                self.fetcher.execute(context: context, completion: result)
              },
              completion: { result in
                completion(result)
              }
        )
    }

    private func retry(_ attempts: Int,
                       delay: DispatchTimeInterval,
                       task: @escaping (_ completion: @escaping (Result<FetchResult, Error>) -> Void) -> Void,
                       completion: @escaping (Result<FetchResult, Error>) -> Void) {
        task({ result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                guard attempts > 1 else {
                    return completion(result)
                }
                logger?.debug("retrying fetch...")
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.retry(attempts - 1, delay: delay, task: task, completion: completion)
                }
            }
        })
    }
}
