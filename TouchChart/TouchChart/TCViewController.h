//
//  TCViewController.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 28/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SYUnitTestController.h"
#import "TCShapeController.h"

@class SYSaveMessageView;
@class SYPaintView;
@class SYVectorView;
@class SYTableBase;

@interface TCViewController : UIViewController <SYUnitTestDelegate> {
    
    // Views
    IBOutlet SYPaintView *paintView;        // Get the points from the finger touch
    IBOutlet SYVectorView *vectorView;      // Will draw the final shape

    // Test
    IBOutlet SYTableBase *tableBase;
    IBOutlet SYSaveMessageView *selectCaseNameView;
    IBOutlet UITextField *nameTextField;
    
    IBOutlet UISlider *continuitySlider;
    IBOutlet UISlider *toleranceSlider;
    IBOutlet UILabel *continuityLabel;
    IBOutlet UILabel *toleranceLabel;
    
}

// Test Methods
- (IBAction) selectName:(id)sender;
- (IBAction) saveCase:(id)sender;
- (IBAction) cancelCase:(id)sender;
- (void) importCase:(NSArray *) allPoints;

- (SYShape*) getFigurePainted;
-(void) resetData;

- (void) addPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;
- (void) addLastPoint:(CGPoint) lastPoint;
@end
