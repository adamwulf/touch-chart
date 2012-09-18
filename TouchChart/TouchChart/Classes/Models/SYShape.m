//
//  SYShape.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 11/09/12.
//
//

#import "SYShape.h"
#import "SYGeometry.h"
#import "SYSegment.h"
#import "SYBezierController.h"

@interface SYShape () {
    
    NSMutableArray *geometriesArray;
    
}

@end


@implementation SYShape

- (id) init
{
    self = [super init];
    
    if (self) {
        geometriesArray = [[NSMutableArray alloc]init];
    }
    
    return self;
    
}// init


- (void) dealloc
{
    [geometriesArray release];
    [super dealloc];
    
}// dealloc


- (void) addGeometry:(SYGeometry *) geometry
{
    [geometriesArray addObject:geometry];
    
}// addGeometry:


#pragma mark - Adding Elements

- (void) addPolygonalFromSegment:(SYSegment *) segment
{
    if (!segment)
        return;
    
    // Draw the resulting shape
    SYGeometry *geometry = [[[SYGeometry alloc]init]autorelease];
    
    // Geometry parameters
    geometry.geometryType = LinesType;
    geometry.pointArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:[segment pointSt]],
                           [NSValue valueWithCGPoint:[segment pointFn]], nil];
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    [geometriesArray addObject:geometry];
    
}// createPolygonalFromSegment


- (void) addCurve:(NSArray *) curvePoints
{
    if (!curvePoints || [curvePoints count] == 0)
        return;
    
    SYBezierController *bezierController = [[SYBezierController alloc]init];
    NSArray *curves = [bezierController getBestCurveForListPoint:curvePoints tolerance:0.01];
    [bezierController release];
    
    // Draw the resulting shape
    SYGeometry *geometry = [[[SYGeometry alloc]init]autorelease];
    
    // Geometry parameters
    geometry.geometryType = BezierType;
    geometry.pointArray = curves;
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    [geometriesArray addObject:geometry];
    
}// addCurve:


#pragma mark - Get elements

- (NSArray *) geometries
{
    return [NSArray arrayWithArray:geometriesArray];
    
}// geometries

@end
