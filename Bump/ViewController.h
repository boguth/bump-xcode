//
//  ViewController.h
//  Bump
//
//  Created by Apprentice on 7/18/15.
//  Copyright (c) 2015 Bump Boys!, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MySupplementaryViewCollectionReusableView.h"


@interface ViewController : UICollectionViewController<
    CLLocationManagerDelegate> {
    CLLocationManager *_locationManager;
}

@property(nonatomic, strong) NSArray * dataArray;
//@property (strong, nonatomic) CLLocationManager *locationManager;

@end

