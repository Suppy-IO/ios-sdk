//
//  Copyright © 2020 Suppy.io. All rights reserved.
//

import Foundation

internal struct Logger {

    func debug(_ message: String, file: String = #file, function: String = #function) {
        print("[SuppyConfig \(extractFilename(file)) \(function)] - \(message)")
    }

    func error(_ error: Error, file: String = #file, function: String = #function) {
        print("[SuppyConfig \(extractFilename(file)) \(function)] - \(error)")
    }

    private func extractFilename(_ file: String) -> String {
        let result: [String]
        do {
            // Regex description:
            //
            // Negated set: Matches a "/" character
            // Quantifier: "+" for precending token
            // Positive lookahead: Matches a "." character
            //
            // Matches the last element in a path up to "."
            // example: "/a/b/c.swift" -> (matches) "c"
            //
            let regex = try NSRegularExpression(pattern: #"[^/]+(?=\.)"#)
            let results = regex.matches(in: file,
                                        range: NSRange(file.startIndex..., in: file))
            result = results.map {
                String(file[Range($0.range, in: file)!])
            }
        } catch let error {
            assertionFailure("Error while trying to match file name - invalid regex: \(error.localizedDescription)")
            result = []
        }
        return result.first ?? file
    }
}
