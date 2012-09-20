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


- (NSString *) description
{
    NSMutableString *string = [NSMutableString string];
    
    for (SYGeometry *geometry in geometriesArray) {
        if (geometry.geometryType == SquareType) {
            [string appendString:@"type: Square\n"];
        }
        else if (geometry.geometryType == CircleType) {
            [string appendFormat:@"type: CircleType: (%f, %f)\n", geometry.rectGeometry.origin.x, geometry.rectGeometry.origin.y];
        }
        else if (geometry.geometryType == DiamondType) {
            [string appendString:@"type: DiamondType\n"];
        }
        else if (geometry.geometryType == TriangleType) {
            [string appendString:@"type: TriangleType\n"];
        }
        else if (geometry.geometryType == LinesType) {
            [string appendString:@"type: LinesType\n"];
        }
        else if (geometry.geometryType == BezierType) {
            [string appendString:@"type: BezierType\n"];
        }
        else if (geometry.geometryType == ArcType) {
            [string appendString:@"type: ArcType\n"];
        }
    }
    
    return [NSString stringWithString:string];
    
}// description


- (void) addGeometry:(SYGeometry *) geometry
{
    [geometriesArray addObject:geometry];
    
}// addGeometry:


#pragma mark - Adding Elements

- (void) addPoint:(CGPoint) keyPoint
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = CircleType;
    geometry.rectGeometry = CGRectMake(keyPoint.x - 3.0, keyPoint.y - 3.0, 6.0, 6.0);
    
    // Draw properties
    geometry.lineWidth = 2.0;
    geometry.fillColor = [UIColor redColor];
    geometry.strokeColor = [UIColor redColor];
    
    [geometriesArray addObject:geometry];
    
}// addKeyPoint:


- (void) addKeyPoint:(CGPoint) keyPoint
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = CircleType;
    geometry.rectGeometry = CGRectMake(keyPoint.x - 8.0, keyPoint.y - 8.0, 16.0, 16.0);
    
    // Draw properties
    geometry.lineWidth = 6.0;
    geometry.fillColor = [UIColor orangeColor];
    geometry.strokeColor = [UIColor orangeColor];
    
    [geometriesArray addObject:geometry];
    
}// addKeyPoint:


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
    
    SYSegment *segment = [[SYSegment alloc]initWithPoint:[[curvePoints objectAtIndex:0]CGPointValue]
                                                andPoint:[[curvePoints lastObject]CGPointValue]];
    CGFloat longitude = [segment longitude];
    [segment release];
    
    if (longitude < 80.0) {
        SYBezierController *bezierController = [[SYBezierController alloc]init];
        NSArray *curves = [bezierController getCubicBezierPointsForListPoint:curvePoints];
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
    }
    else {
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
    }
    
}// addCurve:


#pragma mark - Get elements

- (NSArray *) geometries
{
    return [NSArray arrayWithArray:geometriesArray];
    
}// geometries

@end
