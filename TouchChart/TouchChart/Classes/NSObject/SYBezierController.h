//
//  SYBezierController.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 24/07/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYBezierController : NSObject

- (NSDictionary *) getCubicBezierPointsForListPoint:(NSArray *) listPoints;
- (NSDictionary *) getCubicBezierPointsForListPoint:(NSArray *) listPoints andConvertFromView:(UIView *) viewtoConvert;
- (NSArray *) getCubicBezierPointsForListPoint:(NSArray *) listPoints splitIn:(NSUInteger) ntimes;
- (NSArray *) getCubicBezierPointsForListPoint:(NSArray *) listPoints splitIn:(NSUInteger) ntimes andConvertFromView:(UIView *) viewtoConvert;
- (NSArray *) getBestCurveForListPoint:(NSArray *) listPoints tolerance:(CGFloat) percentage andConvertFromView:(UIView *) viewtoConvert;

@end
