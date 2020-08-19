

## How to get started
- Create an account at **suppy.io**
- Create a configuration with at least one attribute and release it at **suppy.io**
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
platform :ios, '10.0'

target 'TargetName' do
  pod 'SuppyConfig', '1.0.0'
end
```
Then, run the following command:
```
$ pod install
```

## Usage
This library can be used for iPhones, iPads and MacOS. It supports iOS 10.0 and above.

#### Imports
Swift: `import SuppyConfig`  
Objective-C: `@import SuppyConfig;`

#### Initialize 
In order to be able to use SuppyConfig you need to initialize it first.
```swift
let suppyConfig = SuppyConfig(configId: "<identifier>", 
                              applicationName: "<name>", 
                              dependencies: "<[String: Any]>")       
```
After the initialization, you are ready to fetch your configuration.

#### Fetch configuration
```swift
suppyConfig.fetchConfiguration(completion:)       
```
The completion is optional and allows you to get informed when fetching is complete.

#### Use configurations
Configurations are stored in the standard UserDefaults therefore they are accessible through it.

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

#### Recommendation
Configuration fetching is not bound to any specific part of your application life-cycle. 
Nevertheless, we suggest that fetchConfiguration is called during AppDelegate's: didFinishLaunchingWithOptions and applicationDidBecomeActive.

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
let dependencies: [String: Any] = ["String Configuration": "a string",
                                   "URL Configuration": URL(string: "https://url.com")!,
                                   "INT Configuration": 1,
                                   "BOOL Configuration": true]

let suppyConfig = SuppyConfig(configId: "1234", 
                              applicationName: "IOS Client", 
                              dependencies: dependencies
                              
suppy.fetchConfiguration {
    let defaults = UserDefaults.standard
    
    let string = defaults.string(forKey: "String Configuration")
    let url = defaults.url(forKey: "URL Configuration")
    let int = defaults.integer(forKey: "INT Configuration")
    let bool = defaults.integer(forKey: "BOOL Configuration")
}
```
