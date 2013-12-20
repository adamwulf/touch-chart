//
//  TCShapeController.h
//  TouchChart
//
//  Created by Adam Wulf on 8/15/13.
//
//

#import <UIKit/UIKit.h>
#import "SYShape.h"

@interface TCShapeController : NSObject{
    NSDictionary *recentlyReducedKeyPoints;
}

@property (readonly) NSDictionary* recentlyReducedKeyPoints;

// Calculate Shapes
- (SYShape*) getFigurePaintedWithTolerance:(CGFloat)toleranceValue andContinuity:(CGFloat)continuityValue forceOpen:(BOOL)forceOpen;

// Cloud Points Methods
- (void) addPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;
- (void) addLastPoint:(CGPoint) lastPoint;

-(BOOL) hasPointData;

@end
