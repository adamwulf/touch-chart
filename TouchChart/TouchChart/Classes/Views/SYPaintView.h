//
//  SYPaintView.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 28/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCViewController;
@class SYUnitTestController;

@interface SYPaintView : UIView {
    
    // Data
    NSMutableArray *_allPoints;
    
    // Controller
    __weak IBOutlet TCViewController *viewController;
    __weak IBOutlet SYUnitTestController *unitTestController;
    
}

@property(readonly, strong) NSMutableArray *allPoints; // Unit test data

// Clears the finger drawing from the screen
- (void) clearPaint;

// Setter Parameters Drawing
- (void) setLineWidth:(float)lineWidth;

@end
