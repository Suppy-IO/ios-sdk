//
//  Copyright © 2020 Suppy.io - All rights reserved.
//

import Foundation

// Types of expected errors that can be discovered while parsing server responses.
enum FetchError: Error {
    case noResponse
    case invalidStatus(Int)
    case noData
}

internal struct ConfigFetcher: DataFetchable {

    private var persistence: Persistence

    init(persistence: Persistence = Persistence()) {
        self.persistence = persistence
    }

    func execute(context: Context, completion: @escaping (Result<Data, Error>) -> Void) {
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
                let result = self.resultFromResponse(data: data,
                                                     response: response,
                                                     error: error)
                self.persistence.save(etag: response)
                //self.persistence.(response: response)
                completion(result)
            })
            .resume()
    }

    private func resultFromResponse(data: Data?,
                                    response: URLResponse?,
                                    error: Error?) -> Result<Data, Error> {
        // verifies that we have got no errors during remote call
        if let error = error {
            return .failure(error)
        }

        // verifies that we have got an HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(FetchError.noResponse)
        }

        // verifies that the status code in the HTTP status code SUCCESS range
        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            return .failure(FetchError.invalidStatus(httpResponse.statusCode))
        }

        // verifies that the response contained data to be parsed
        guard let data = data else {
            return .failure(FetchError.noData)
        }

        return .success(data)
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

        let dependencyNames = context.dependencies.map { $0.key }.joined(separator: ",")
        let dependencyName = URLQueryItem(name: "dependencyName", value: dependencyNames)

        let dependencyTypes = context.dependencies.map { String(describing: type(of: $0.value)) }.joined(separator: ",")
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
