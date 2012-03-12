//
//  UITouchableView.m
//  WelcomeToYourMac
//
//  Created by Adam Wulf on 9/12/09.
//  Copyright 2009 Jotlet, LLC. All rights reserved.
//

#import "UITouchableView.h"
#import "Constants.h"


@implementation UITouchableView

@synthesize passToView;

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
	}
	return self; 
}

-(BOOL) becomeFirstResponder{
	return [[[passToView subviews] objectAtIndex:0] becomeFirstResponder];
}

-(BOOL) canBecomeFirstResponder{
	return [[[passToView subviews] objectAtIndex:0] canBecomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
	return [[[passToView subviews] objectAtIndex:0] canPerformAction:action withSender:sender];
}

- (BOOL)canResignFirstResponder{
	return [[[passToView subviews] objectAtIndex:0] canResignFirstResponder];
}

- (BOOL)isFirstResponder{
	return [[[passToView subviews] objectAtIndex:0] isFirstResponder];
}

- (void)motionBegan:(UIEventSubtype)touches withEvent:(UIEvent *)event{
	[[[passToView subviews] objectAtIndex:0] motionBegan:touches withEvent:event];
}

- (void)motionCancelled:(UIEventSubtype)touches withEvent:(UIEvent *)event{
	[[[passToView subviews] objectAtIndex:0] motionCancelled:touches withEvent:event];
}

- (void)motionEnded:(UIEventSubtype)touches withEvent:(UIEvent *)event{
	[[[passToView subviews] objectAtIndex:0] motionEnded:touches withEvent:event];
}

- (UIResponder*) nextResponder{
	return [[[passToView subviews] objectAtIndex:0] nextResponder];
}

- (BOOL)resignFirstResponder{
	return [[[passToView subviews] objectAtIndex:0] resignFirstResponder];
}



- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
	NSSet *touches = [event allTouches];
	BOOL forwardToSuper = YES;
	for (UITouch *touch in touches) {
		if ([touch tapCount] >= 2) {
			// prevent this 
			forwardToSuper = NO;
		}		
	}
	if (forwardToSuper){
		//return self.superview;
		return [[[passToView subviews] objectAtIndex:0] hitTest:point withEvent:event];
	}
	else {
		// Return the superview as the hit and prevent
		// UIWebView receiving double or more taps
		return self.superview;
	}
}



- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
	return [[[passToView subviews] objectAtIndex:0] pointInside:point withEvent:event];
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	debug_NSLog(@"touch cancelled");
	[[[passToView subviews] objectAtIndex:0] touchesCancelled:touches withEvent:event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	debug_NSLog(@"touch began");
	[[[passToView subviews] objectAtIndex:0] touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	debug_NSLog(@"touch moved");
	[[[passToView subviews] objectAtIndex:0] touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	debug_NSLog(@"touch ended");
	[[[passToView subviews] objectAtIndex:0]   touchesEnded:touches withEvent:event];
}

@end
