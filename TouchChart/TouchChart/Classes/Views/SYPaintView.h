//
//  SYPaintView.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 28/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYGeometricMathController;

@interface SYPaintView : UIView {
    
    // Calculation variables
    IBOutlet SYGeometricMathController *geometricMathController;
    
    // Data Collector
    CGPoint	location;
	CGPoint	previousLocation;
	Boolean	firstTouch;
}

// Sets the stroke width
@property(nonatomic) float lineWidth;

// The stroke color
@property(nonatomic,strong) UIColor *foreColor;

// Clears the signature from the screen
- (void) clearPaint;

@end
