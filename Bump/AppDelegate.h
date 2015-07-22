//
//  AppDelegate.h
//  Bump
//
//  Created by Apprentice on 7/18/15.
//  Copyright (c) 2015 Bump Boys!, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

//extern NSString *MYGlobalVariable; // Gobal Variable Test


@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    NSString *pushCode;
}


@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSString *pushCode;

@end

