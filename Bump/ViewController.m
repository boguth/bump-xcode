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
#import "QuartzCore/QuartzCore.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
@import CoreLocation;
@import AddressBook;

@interface ViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSOperationQueue *bgQueue;
@property (strong, nonatomic) NSMutableArray *imageData;
@property (assign, nonatomic) CFErrorRef *error;
@property (assign, nonatomic) BOOL *hasBeenChecked;

@end

@implementation ViewController{
    float *prevLat;
    float *prevLong;

}

/// ASYNCHRONOUS REQUEST CODE ///

-(void)makeRequest:(NSString*)string
{
    NSString *location = string;
    NSString *prefix = @"https://whispering-stream-9304.herokuapp.com/update?token=b13e2dca0322957b7934a6b1f4d500f8dd7b59724db65f6f92f3a1072a31bbf4&lat=";
    NSString *queryString = [prefix stringByAppendingString:location];
    [self loadURLsFromLocation:queryString];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]){
        [self performSegueWithIdentifier:@"firstLogin" sender:self];
    }
    else
    {
    
    //     This conditional block of code is for push notifications
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
        {
        // iOS 8 Notifications
        // use registerUserNotificationSettings
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound |         UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else
        {
            // iOS < 8 Notifications
            // use registerForRemoteNotifications
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
        }
        
        if (self.hasBeenChecked != YES){
             [self addressBookAuth];
        }
        
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
    }
    
}
- (void)viewDidLoad {

    [super viewDidLoad];
    self.dataArray = @[];
    self.imageData = [[NSMutableArray alloc] init];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];

    if (self.error == NULL){
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, self.error);
        [self listPeopleInAddressBook:addressBook];
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        // This is the notification block of code specifically for location.
        
        

    }
    else{
    }
 
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
    NSLog(@"%lu", (unsigned long)self.dataArray.count);
 
    return self.dataArray.count;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    Cell *aCell = [cv dequeueReusableCellWithReuseIdentifier:@"myCell" forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cv viewWithTag:1];
    imageView.image = (UIImage *)[self.imageData objectAtIndex:indexPath.row];
    
    [imageView.layer setMasksToBounds:YES];
    [imageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [imageView.layer setBorderWidth:1];
    [imageView.layer setCornerRadius:40];

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
        [header.headerLabel setFont:[UIFont fontWithName:@"AmericanTypewriter-Condensed" size:34.0]];
    }
    return header;
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
    
    //    NSLog(@"%f", latitude);
    [self makeRequest:[NSString stringWithFormat:@"%f&lon=%f",latitude,longitude]];
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
                                   self.dataArray = urls;
                                   [self updateImageData];
                               }
                               
                           }];
}

- (void)updateImageData{
    __block NSInteger count = self.dataArray.count;
    
    for (NSInteger i = 0; i< self.dataArray.count; i++) {
        if(!self.bgQueue){
            self.bgQueue = [[NSOperationQueue alloc] init];
        }
        
        [NSURLConnection sendAsynchronousRequest:
         [NSURLRequest requestWithURL:
          [NSURL URLWithString:self.dataArray[i]]]
                                           queue:self.bgQueue
                               completionHandler: ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if(data){
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




// Address Book Methods
-(void)addressBookAuth
{
    
    self.hasBeenChecked = YES;
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    
    if (status == kABAuthorizationStatusDenied || status == kABAuthorizationStatusRestricted) {
        // if you got here, user had previously denied/revoked permission for your
        // app to access the contacts, and all you can do is handle this gracefully,
        // perhaps telling the user that they have to go to settings to grant access
        // to contacts
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"This app requires access to your contacts to function properly. Please visit to the \"Privacy\" section in the iPhone Settings app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
     self.error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, self.error);
    
    if (!addressBook) {
        NSLog(@"ABAddressBookCreateWithOptions error: %@", CFBridgingRelease(self.error));
        return;
    }
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (self.error) {
            NSLog(@"ABAddressBookRequestAccessWithCompletion error: %@", CFBridgingRelease(error));
        }
        
        if (granted) {
            // if they gave you permission, then just carry on
            [self listPeopleInAddressBook:addressBook];
        } else {
            // however, if they didn't give you permission, handle it gracefully, for example...
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // BTW, this is not on the main thread, so dispatch UI updates back to the main queue
                
                [[[UIAlertView alloc] initWithTitle:nil message:@"This app requires access to your contacts to function properly. Please visit to the \"Privacy\" section in the iPhone Settings app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            });
        }
        
        CFRelease(addressBook);
    });
}



-(void)listPeopleInAddressBook:(ABAddressBookRef *) addressBook {
    
    {
        NSArray *allPeople = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
        NSInteger numberOfPeople = [allPeople count];
        
        for (NSInteger i = 0; i < numberOfPeople; i++) {
            ABRecordRef person = (__bridge ABRecordRef)allPeople[i];
            NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            NSString *lastName  = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
            NSData  *imgData = (NSData *)CFBridgingRelease(ABPersonCopyImageData(person));
            UIImage  *img = [UIImage imageWithData:imgData];
            
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            CFStringRef mobileNumber;
            NSString *mobileLabel;
            mobileLabel = CFBridgingRelease(ABMultiValueCopyLabelAtIndex(phoneNumbers, i));
            if ([mobileLabel isEqualToString:@"_$!<Mobile>!$_"]) {
                mobileNumber = ABMultiValueCopyValueAtIndex(phoneNumbers,i);
                NSLog(@"Name:%@ %@, and Mobile: %@", firstName, lastName, mobileNumber);
                
            }
            
        }
    }
}











@end
