//
//  Created by Suppy.io
//

import UIKit
import SuppyConfig

enum ConfigKey: String, CaseIterable {
    case applicationTitle = "Application Title"
    case privacyPolicy = "Privacy Policy"
    case recommendedVersion = "Recommended Version"
    case acceptanceRatio = "Acceptance Ratio"
    case numberOfSeats = "Number of Seats"
    case backgroundColor = "Background Color"
    case productList = "Product List"
    case featureXEnabled = "Feature X Enabled"
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var viewController: ViewController?
    let suppy: SuppyConfig

    override init() {
        let dependencies = [
            Dependency(name: ConfigKey.applicationTitle.rawValue, value: "Intial App Title", mappedType: .string),
            Dependency(name: ConfigKey.privacyPolicy.rawValue, value: URL(string: "https://default-local-url.com")!, mappedType: .url),
            Dependency(name: ConfigKey.recommendedVersion.rawValue, value: "1.0.0", mappedType: .string),
            Dependency(name: ConfigKey.acceptanceRatio.rawValue, value: 1.61803, mappedType: .number),
            Dependency(name: ConfigKey.numberOfSeats.rawValue, value: 2, mappedType: .number),
            Dependency(name: ConfigKey.backgroundColor.rawValue, value: "white", mappedType: .string),
            Dependency(name: ConfigKey.productList.rawValue, value: [], mappedType: .array),
            Dependency(name: ConfigKey.featureXEnabled.rawValue, value: false, mappedType: .boolean)
        ]

        suppy = SuppyConfig(configId: "5f43879d25bc1e682f988129", applicationName: "Swift Example", dependencies: dependencies, suiteName: nil, enableDebugMode: true)
        super.init()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        suppy.fetchConfiguration { [weak self] in
            self?.viewController?.refreshData()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        viewController = ViewController()

        window = UIWindow()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()

        return true
    }
}

