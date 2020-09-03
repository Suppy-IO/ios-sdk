//
//  Created by Suppy.io
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "ConfigKey.h"
@import SuppyConfig;

@implementation AppDelegate {
    SuppyConfig *suppy;
    ViewController *viewController;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        NSArray *dependencies = [NSArray arrayWithObjects:
                                 [[Dependency alloc] initWithName:kApplicationTitle value:@"Intial App Title" mappedType:DependencyTypeString],
                                 [[Dependency alloc] initWithName:kPrivacyPolicy value:[NSURL URLWithString:@"https://default-local-url.com"] mappedType:DependencyTypeUrl],
                                 [[Dependency alloc] initWithName:kRecommendedVersion value:@"1.0.0" mappedType:DependencyTypeString],
                                 [[Dependency alloc] initWithName:kAcceptanceRatio value:[NSNumber numberWithFloat:1.61803] mappedType:DependencyTypeNumber],
                                 [[Dependency alloc] initWithName:kNumberOfSeats value: @(2) mappedType:DependencyTypeNumber],
                                 [[Dependency alloc] initWithName:kBackgroundColor value: @"white" mappedType:DependencyTypeString],
                                 [[Dependency alloc] initWithName:kProductList value:@[] mappedType:DependencyTypeArray],
                                 [[Dependency alloc] initWithName:kFeatureXEnabled value: @(0) mappedType:DependencyTypeBoolean],
                                 nil];

        suppy = [[SuppyConfig alloc] initWithConfigId:@"5f43879d25bc1e682f988129" applicationName:@"Obj-C Example" dependencies:dependencies suiteName:nil enableDebugMode:true];
    }
    return self;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [suppy fetchConfigurationWithCompletion:^{
        [self->viewController refreshData];
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    viewController = [[ViewController alloc] init];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
