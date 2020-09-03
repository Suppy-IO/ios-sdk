//
//  Created by Suppy.io
//

#import "ViewController.h"
#import "SubtitleTableViewCell.h"
#import "ConfigKey.h"

static NSString *kCellIdentifier = @"cellIdentifier";

@interface ViewController () 
@end

@implementation ViewController {
    UITableView             *tableView;
    NSMutableDictionary     *data;
    NSArray                 *configKeys;
}

- (void)refreshData
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self loadFromUserDefaults];
        [self->tableView reloadData];
    });
}

- (void)loadFromUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [data removeAllObjects];

    for(NSString *key in configKeys)
    {
        if([key isEqualToString:kPrivacyPolicy]) {
            NSURL *url = [defaults URLForKey:key];
            [data setValue:url.absoluteString forKey:key];
        } else if([key isEqualToString:kProductList]) {
            [data setValue:[[defaults arrayForKey:key] componentsJoinedByString:@", "] forKey:key];
        } else if([key isEqualToString:kFeatureXEnabled]) {
            BOOL isEnabled = [defaults boolForKey: key];
            NSString *boolStr = isEnabled ? @"True" : @"False";
            [data setValue:boolStr forKey:key];
        } else {
            [data setValue:[defaults stringForKey:key] forKey:key];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    data = [NSMutableDictionary dictionary];
    configKeys = [ConfigKey singleton].globalArray;

    tableView = [[UITableView alloc] init];

    [self.view addSubview:tableView];

    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [[tableView topAnchor] constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [[tableView bottomAnchor] constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [[tableView leftAnchor] constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [[tableView rightAnchor] constraintEqualToAnchor:self.view.rightAnchor].active = YES;

    tableView.delegate = self;
    tableView.dataSource = self;

    self.view.backgroundColor = UIColor.whiteColor;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ConfigKey singleton].globalArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];

    if(cell == nil) {
        cell = [[SubtitleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }

    NSString *key = configKeys[indexPath.row];
    cell.textLabel.text = [data valueForKey:key];
    cell.detailTextLabel.text = key;

    if([key isEqualToString:kBackgroundColor]) {
        NSString *color =  [data valueForKey:key];
        if([color isEqualToString:@"white"]) {
            cell.backgroundColor = UIColor.whiteColor;
        } else if([color isEqualToString:@"red"]) {
            cell.backgroundColor = UIColor.redColor;
        } else if([color isEqualToString:@"blue"]) {
            cell.backgroundColor = UIColor.blueColor;
        } else if([color isEqualToString:@"green"]) {
            cell.backgroundColor = UIColor.greenColor;
        } else if([color isEqualToString:@"yellow"]) {
            cell.backgroundColor = UIColor.yellowColor;
        } else {
            cell.backgroundColor = UIColor.whiteColor;
        }
    }

    return cell;
}

@end
