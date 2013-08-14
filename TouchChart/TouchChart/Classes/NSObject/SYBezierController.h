//
//  SYBezierController.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 24/07/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYBezierController : NSObject

// Build Curves
- (NSArray *) addPointBasedQuadraticBezier:(NSArray *) listPoints;
- (NSArray *) buildCubicBezierPointsForListPoint:(NSArray *) listPoints;
- (NSArray *) buildCubicBezierPointsForListPoint:(NSArray *) listPoints splitIn:(NSUInteger) ntimes;
- (NSArray *) buildBestBezierForListPoint:(NSArray *) listPoints tolerance:(CGFloat) ratioError;

// Error
- (CGFloat) getErrorRatioListPoint:(NSArray *)listPoints splitIn:(CGFloat)i;

@end
