//
//  TCShapeController.h
//  TouchChart
//
//  Created by Adam Wulf on 8/15/13.
//
//

#import <UIKit/UIKit.h>
#import "SYShape.h"

@interface TCShapeController : UIViewController

// Calculate Shapes
- (SYShape*) getFigurePaintedWithTolerance:(CGFloat)toleranceValue andContinuity:(CGFloat)continuityValue;

// Cloud Points Methods
- (void) addPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;
- (void) addLastPoint:(CGPoint) lastPoint;

-(BOOL) hasPointData;

// Other Helper Methods
- (NSDictionary *) reducePointsKey;



@end
