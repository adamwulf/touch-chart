//
//  UITouchableWindow.h
//  WelcomeToYourMac
//
//  Created by Adam Wulf on 9/12/09.
//  Copyright 2009 Jotlet, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UITouchableWindowDelegate.h"


@interface UITouchableWindow : UIWindow {

	NSObject<UITouchableWindowDelegate>* tapDelegate;
}

@property (nonatomic, retain) NSObject<UITouchableWindowDelegate>* tapDelegate;


@end
