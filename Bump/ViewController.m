//
//  ViewController.m
//  Bump
//
//  Created by Apprentice on 7/18/15.
//  Copyright (c) 2015 Bump Boys!, Inc. All rights reserved.
//

#import "ViewController.h"
#import "Cell.h"
#import "AppDelegate.h"
@import CoreLocation;
//#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSOperationQueue *bgQueue;
@property (strong, nonatomic) NSMutableArray *imageData;


@end

@implementation ViewController{
    float *prevLat;
    float *prevLong;
}


/// ASYNCHRONOUS REQUEST CODE ///

-(void)makeRequest:(NSString*)string
{
    NSString *location = string;
    NSString *prefix = @"https://whispering-stream-9304.herokuapp.com/update?lat=";
    NSString *queryString = [prefix stringByAppendingString:location];
    [self loadURLsFromLocation:queryString];
}


//// LOCATION CODE /////

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [NSThread sleepForTimeInterval:0.5f];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
//    [self.locationManager stopUpdatingLocation];
    
    CLLocation *location = [self.locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    float longitude=coordinate.longitude;
    float latitude=coordinate.latitude;
    
    
    
    /// MOVEMENT TOLERANCE
    //    if (prevLat == nil){
    //        prevLat = &latitude;
    //    }
    //    else if (prevLat == &latitude){
    //        [self.locationManager stopUpdatingLocation];
    //    }
    //    if (prevLat !=
    //    NSLog(@"We're in the request maker.");
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *token = appDelegate.pushCode;
    NSLog(@"%@", token);
    
    [self makeRequest:[NSString stringWithFormat:@"%f&lon=%f&token=%@",latitude,longitude,token]];
}

- (void)loadURLsFromLocation:(NSString *)locationString {
    if(!self.bgQueue){
        self.bgQueue = [[NSOperationQueue alloc] init]; // Background threads it (backgroundqueue).
    }
    
    [NSURLConnection sendAsynchronousRequest:
     [NSURLRequest requestWithURL:
      [NSURL URLWithString:locationString]]
                                       queue:self.bgQueue
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if(connectionError){
                                   NSLog(@"%@", connectionError);
                               }
                               
                               if(data != nil){
                                   
                                   NSDictionary *imagesDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                   NSArray *urls = [imagesDict valueForKey:@"images"];
                                   NSLog(@"%@", urls);
                                   self.dataArray = urls;
                                   [self updateImageData];
                               }
                               
                           }];
}

- (void)updateImageData{
    __block NSInteger count = self.dataArray.count;
    
    
    NSLog(@"%lu", self.dataArray.count);
    for (NSInteger i = 0; i< self.dataArray.count; i++) {
        NSLog(@"Hey");
        if(!self.bgQueue){
            self.bgQueue = [[NSOperationQueue alloc] init];
        }
        
        [NSURLConnection sendAsynchronousRequest:
         [NSURLRequest requestWithURL:
          [NSURL URLWithString:self.dataArray[i]]]
                                           queue:self.bgQueue
                               completionHandler: ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if(data){
//                                       NSLog(@"%@", data);
                                       self.imageData[i] = [UIImage imageWithData:data];
                                   }
                                   
                                   count -= 1;
                                   if(count <= 0){
                                       [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                           
                                           [self.collectionView reloadData];
                                       }];
                                   }
                               }];
    }
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = @[];
    self.imageData = [[NSMutableArray alloc] init];
    
    // This conditional block of code is for push notifications
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        // iOS 8 Notifications
        // use registerUserNotificationSettings
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        // use registerForRemoteNotifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    }
    
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    // This is the notification block of code specifically for location.
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// THESE ARE THE COLLECTION VIEW DELEGATE METHODS///


-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}


-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSLog(@"%u", self.dataArray.count);
 
    return self.dataArray.count;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    Cell *aCell = [cv dequeueReusableCellWithReuseIdentifier:@"myCell" forIndexPath:indexPath];
    
    aCell.image.image = (UIImage *)[self.imageData objectAtIndex:indexPath.row];
    
    [aCell.layer setBorderWidth:1.5f];
    [aCell.layer setBorderColor:[UIColor whiteColor].CGColor];
    [aCell.layer setCornerRadius:37.5f]; // MAKES CIRCLES!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    
    return aCell;
}


// HEADER CODE ///


-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    MySupplementaryViewCollectionReusableView *header = nil;
    if ([kind isEqual:UICollectionElementKindSectionHeader])
    {
        header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                    withReuseIdentifier:@"MyHeader"
                                                           forIndexPath:indexPath];
        
        header.headerLabel.text = @"bump";
        [header.headerLabel setFont:[UIFont fontWithName:@"AmericanTypewriter-Condensed" size:38.0]];
    }
    return header;
}






@end
