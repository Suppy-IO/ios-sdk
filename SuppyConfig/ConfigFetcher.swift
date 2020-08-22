//
//  Copyright © 2020 Suppy.io - All rights reserved.
//

import Foundation

enum FetchResult {
    case noData(Int)
    case newData(Data)
}

// Types of expected errors that can be discovered while parsing server responses.
enum FetchError: Error {
    case noResponse
    case invalidStatus(Int)
}

internal struct ConfigFetcher: DataFetchExecutor {

    private var persistence: Persistence

    init(persistence: Persistence = Persistence()) {
        self.persistence = persistence
    }

    func execute(context: Context, completion: @escaping (Result<FetchResult, Error>) -> Void) {
        guard let url = createUrl(context: context) else {
            return assertionFailure("unable to create URL")
        }

        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 30 /* seconds */)

        if let etag = persistence.etag {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }

        URLSession
            .shared
            .dataTask(with: request, completionHandler: { data, response, error in
                // stores ETag if present
                self.persistence.save(etag: response)

                let result = self.resultFromResponse(data: data,
                                                     response: response,
                                                     error: error)
                completion(result)
            })
            .resume()
    }

    private func resultFromResponse(data: Data?,
                                    response: URLResponse?,
                                    error: Error?) -> Result<FetchResult, Error> {
        // verifies that we have got no errors during remote call
        if let error = error {
            return .failure(error)
        }

        // verifies that we have got an HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(FetchError.noResponse)
        }

        // verifies that the status code in the HTTP status code SUCCESS range 200...299
        //
        // OR
        //
        // HTTP Status Code 304 - "Not Modified" (RFC 7232)
        //
        // Indicates that the resource has not been modified since the version specified by the
        // request headers If-Modified-Since or If-None-Match. In such case, there is no need to
        // retransmit the resource since the client still has a previously-downloaded copy.
        // source: https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
        guard
            (200 ..< 300).contains(httpResponse.statusCode) ||
            httpResponse.statusCode == 304
        else {
            return .failure(FetchError.invalidStatus(httpResponse.statusCode))
        }

        if let data = data,
           !data.isEmpty {
            return .success(.newData(data))
        } else {
            return .success(.noData(httpResponse.statusCode))
        }
    }

    private func createUrl(context: Context) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "suppy.io"
        components.path = "/api/clients/\(self.applicationName)"

        let configId = URLQueryItem(name: "configId", value: context.configId)
        let anonymousId = URLQueryItem(name: "anonymousId", value: persistence.anonymousId)

        /// the information below is collected in order to allow for configuration targeting and routing

        let deviceModel = URLQueryItem(name: "deviceModel", value: self.deviceModel)
        let appIdentifier = URLQueryItem(name: "bundleIdentifier", value: self.bundleIdentifier)
        let appVersion = URLQueryItem(name: "bundleVersion", value: self.bundleVersion)
        let appBuild = URLQueryItem(name: "bundleBuild", value: self.bundleBuild)

        /// dependencies mapping to URL parameters

        let dependencyNames = context.dependencies.map { $0.name }.joined(separator: ",")
        let dependencyName = URLQueryItem(name: "dependencyName", value: dependencyNames)

        let dependencyTypes = context.dependencies.map { $0.mappedType.description }.joined(separator: ",")
        let dependencyType = URLQueryItem(name: "dependencyType", value: dependencyTypes)

        components.queryItems = [
            configId,
            deviceModel,
            appIdentifier,
            appVersion,
            appBuild,
            anonymousId,
            dependencyName,
            dependencyType
        ]

        return components.url
    }
}

// MARK: Helpers

private extension ConfigFetcher {
    var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    var bundleIdentifier: String {
        return Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""
    }

    var bundleVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    var bundleBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }

    var applicationName: String {
        bundleIdentifier + bundleVersion + bundleBuild
    }
}
