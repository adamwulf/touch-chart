//
//  TCAppDelegate.h
//  TouchChart
//
//  Created by Adam Wulf on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UITouchableWindow.h"

@class TCViewController;

@interface TCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UITouchableWindow *window;

@property (strong, nonatomic) TCViewController *viewController;

@end
