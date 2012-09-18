//
//  SYShape.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 11/09/12.
//
//

#import <Foundation/Foundation.h>

@class SYSegment;

@interface SYShape : NSObject

// Adding Elements
- (void) addPolygonalFromSegment:(SYSegment *) segment;
- (void) addCurve:(NSArray *) curvePoints;

// Get elements
- (NSArray *) geometries;

@end
