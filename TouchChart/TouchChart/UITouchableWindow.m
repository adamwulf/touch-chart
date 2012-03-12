//
//  UITouchableWindow.m
//  WelcomeToYourMac
//
//  Created by Adam Wulf on 9/12/09.
//  Copyright 2009 Jotlet, LLC. All rights reserved.
//

#import "UITouchableWindow.h"


@implementation UITouchableWindow

@synthesize tapDelegate;



-(void)sendEvent:(UIEvent *)event{
	[super sendEvent:event];
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	if( touch.tapCount == 1 && touch.phase == UITouchPhaseEnded){
		if(tapDelegate != nil) [tapDelegate didTapView];
	}else if( touch.tapCount == 2 && touch.phase == UITouchPhaseEnded){
		if(tapDelegate != nil) [tapDelegate didDoubleTapView];
	}
}

@end
