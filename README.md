

## How to get started
- Create an account at **suppy.io**
- Create a configuration with at least one attribute and release it at **suppy.io**
- Check one of our examples: Swift Example or Objc Example projects.
- Continue reading this page.

## Installation:
CocoaPods is the preferred and supported installation method at the moment.
### CocoaPods
[CocoaPods](http://cocoapods.org/) is a dependency manager for Swift and Objective-C, which automates and simplifies the process of using 3rd-party libraries like SuppyConfig in your projects. You can install it with the following command:
```
$ gem install cocoapods
```
To integrate SuppyConfig into your Xcode project using CocoaPods, specify it in your Podfile:
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

target 'TargetName' do
  pod 'SuppyConfig', '1.0.10'
end
```
Then, run the following command:
```
$ pod install
```

## Usage
This library supports iOS 10.0 and iPadOS 14.0 and above.

### Imports
Swift: `import SuppyConfig`  
Objective-C: `@import SuppyConfig;`

### Initialize 
In order to be able to use SuppyConfig you need to initialize it first.
```swift
let suppyConfig = SuppyConfig(configId: "<identifier>", 
                              applicationName: "<name>", 
                              dependencies: "<[String: Any]>")       
```
After the initialization, you are ready to fetch your configuration.

### Dependencies
Dependencies are stored in the UserDefaults registration dictionary. It is used as the last item in every search list. This means that after UserDefaults
has looked for a value in every other valid location, it will look in the registered defaults.

**IMPORTANT** The server's response is based on the application dependencies. If you pass an empty array, nothing is retrieved. If your dependencies do not match your server configurations, nothing is retrieved. 

```swift
Dependency(name: "<Name of the dependency>", 
           value: <A initial value / fallback>, // type = Any
           mappedType: <Dependency Type>)
```
*Available types:* **string, number, boolean, array, dictionary, url, date**

### Fetch configuration
```swift
suppyConfig.fetchConfiguration(completion:)       
```
The completion is optional and allows you to get informed when fetching is complete.

### Use configurations
Configurations are stored in the standard UserDefaults therefore they are accessible through an API you already know.

*Configuration values are stored according to the dependency types specified in the initialization.*

```swift
UserDefaults.standard.string(forKey:)
UserDefaults.standard.bool(forKey:)
UserDefaults.standard.array(forKey:)
UserDefaults.standard.dictionary(forKey:)
UserDefaults.standard.url(forKey:)
UserDefaults.standard.integer(forKey:)
UserDefaults.standard.double(forKey:)
UserDefaults.standard.float(forKey:)
```

### Recommendation
Configuration fetching is not bound to any specific part of your application life-cycle. 
Nevertheless, we suggest that fetchConfiguration is called during AppDelegate's: applicationDidBecomeActive.

```swift
application(_:didFinishLaunchingWithOptions:)     
```
Fetching during didFinishLaunchingWithOptions will ensure that your configurations are refreshed once 
per cold start.

```swift
applicationDidBecomeActive(_:)
```
Fetching during applicationDidBecomeActive will ensure that your configurations are refreshed every time
the application comes back from background.

## Example
**This library is not a singleton. You need to hold a reference to it.**

```swift
let dependencies = [
            
            Dependency(name: "Application Title", value: "Intial App Title", mappedType: .string),

            Dependency(name: "Privacy Policy", value: URL(string: "https://default-local-url.com")!, mappedType: .url),
            
            Dependency(name: "Number of Seats", value: 2, mappedType: .number),
            
            Dependency(name: "Product List", value: [], mappedType: .array),
            
            Dependency(name: "Feature X Enabled", value: false, mappedType: .boolean)
        ]

let suppyConfig = SuppyConfig(configId: "5f43879d25bc1e682f988129",        
                              applicationName: "Swift Example", 
                              dependencies: dependencies, 
                              suiteName: nil, 
                              enableDebugMode: true) 
                              
suppyConfig.fetchConfiguration {
    let defaults = UserDefaults.standard    
    let string = defaults.string(forKey: "Application Title")
    let url = defaults.url(forKey: "Privacy Policy")
    let int = defaults.integer(forKey: "Number of Seats")
    let bool = defaults.bool(forKey: "Feature X Enabled")
    let array = defaults.array(forKey: "Product List")
}
```
