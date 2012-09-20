//
//  SYBezierController.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 24/07/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYBezierController : NSObject

// Getter Curves
- (NSArray *) addPointBasedQuadraticBezier:(NSArray *) listPoints;
- (NSArray *) getCubicBezierPointsForListPoint:(NSArray *) listPoints;
- (NSArray *) getCubicBezierPointsForListPoint:(NSArray *) listPoints splitIn:(NSUInteger) ntimes;
- (NSArray *) getBestCurveForListPoint:(NSArray *) listPoints tolerance:(CGFloat) ratioError;

// Getter Parameters
- (CGFloat) getErrorRatioListPoint:(NSArray *)listPoints splitIn:(CGFloat)i;

@end
