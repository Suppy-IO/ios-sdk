//
//  Created by Suppy.io
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SubtitleTableViewCell : UITableViewCell
@end

@implementation SubtitleTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    return self;
}

@end
