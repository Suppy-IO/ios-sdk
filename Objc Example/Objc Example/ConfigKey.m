//
//  Created by Suppy.io
//

#import <Foundation/Foundation.h>
#import "ConfigKey.h"

@implementation ConfigKey

@synthesize globalArray;

+(ConfigKey *)singleton
{
    static dispatch_once_t pred;
    static ConfigKey *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[ConfigKey alloc] init];

        NSArray *tmp = [NSArray arrayWithObjects:
                        kApplicationTitle,
                        kPrivacyPolicy,
                        kRecommendedVersion,
                        kAcceptanceRatio,
                        kNumberOfSeats,
                        kBackgroundColor,
                        kProductList,
                        kFeatureXEnabled, nil];

        shared.globalArray = [tmp sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    });
    return shared;
}

@end
