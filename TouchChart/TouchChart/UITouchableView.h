//
//  UITouchableView.h
//  WelcomeToYourMac
//
//  Created by Adam Wulf on 9/12/09.
//  Copyright 2009 Jotlet, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UITouchableWindowDelegate.h"


@interface UITouchableView : UIView {

	UIView* passToView;
	
}
@property (nonatomic, retain) UIView* passToView;

@end
