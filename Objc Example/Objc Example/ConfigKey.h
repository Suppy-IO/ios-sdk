//
//  Created by Suppy.io
//

#define kApplicationTitle @"Application Title"
#define kPrivacyPolicy @"Privacy Policy"
#define kRecommendedVersion @"Recommended Version"
#define kAcceptanceRatio @"Acceptance Ratio"
#define kNumberOfSeats @"Number of Seats"
#define kBackgroundColor @"Background Color"
#define kProductList @"Product List"
#define kFeatureXEnabled @"Feature X Enabled"

@interface ConfigKey : NSObject

+(ConfigKey*)singleton;
@property (nonatomic, retain) NSArray * globalArray;

@end
