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
#import "SYBezier.h"
#import "SYBezierController.h"

@interface SYShape () {
    
    NSMutableArray *geometriesArray;
    float toleranceBezier;

}

// Other Methods
- (CGPoint) midPointBetweenPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;

@end


@implementation SYShape

@synthesize isClosedCurve;
@synthesize isOpenCurve;


- (id) init
{
    self = [super init];
    
    if (self) {
        geometriesArray = [[NSMutableArray alloc]init];
        isOpenCurve = NO;
        isClosedCurve = NO;
    }
    
    return self;
    
}// init


- (id) initWithBezierTolerance:(float) toleranceSlider
{
    self = [super init];
    
    if (self) {
        geometriesArray = [[NSMutableArray alloc]init];
        isOpenCurve = NO;
        isClosedCurve = NO;
        toleranceBezier = toleranceSlider;
    }
    
    return self;
    
}// initWithBezierTolerance


- (NSString *) description
{
    NSMutableString *string = [NSMutableString string];
    
    for (SYGeometry *geometry in geometriesArray) {
        [string appendString:[geometry description]];
        [string appendString:@"\n"];
    }
    
    return [NSString stringWithString:string];
    
}// description


#pragma mark - Setter Methods

- (void) setIsClosedCurve: (BOOL) isCloseCurve
{
    isClosedCurve = isCloseCurve;
    isOpenCurve = !isCloseCurve;
    
}// setCloseCurve



#pragma mark - Getter elements

- (NSUInteger) geometriesCount
{
    return [geometriesArray count];
    
}// geometriesCount


- (SYGeometry *) getElement:(NSUInteger) index
{
    if ([geometriesArray count] <= index || !geometriesArray)
        return nil;
    
    return [geometriesArray objectAtIndex:index];
    
}// getShape:


- (SYGeometry *) getLastElement
{
    if ([geometriesArray count] == 0 || !geometriesArray)
        return nil;
    
    return [geometriesArray objectAtIndex:[geometriesArray count]-1];
    
}// getLastShape


- (NSArray *) geometries
{
    return [NSArray arrayWithArray:geometriesArray];
    
}// geometries


#pragma mark - Adding Elements

- (void) addPoint:(CGPoint) keyPoint
{
    // Geometry parameters
    SYGeometry *geometry = [[SYGeometry alloc] initCircleInRect:CGRectMake(keyPoint.x - 3.0, keyPoint.y - 3.0, 6.0, 6.0)];
    
    // Draw properties
    geometry.lineWidth = 2.0;
    geometry.fillColor = [UIColor redColor];
    geometry.strokeColor = [UIColor redColor];
    
    [geometriesArray addObject:geometry];
    
}// addKeyPoint:


- (void) addKeyPoint:(CGPoint) keyPoint
{
    // Geometry parameters
    SYGeometry *geometry = [[SYGeometry alloc] initCircleInRect:CGRectMake(keyPoint.x - 8.0, keyPoint.y - 8.0, 16.0, 16.0)];
    
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
    SYGeometry *geometry = [[SYGeometry alloc] initWithSegmentFrom:segment.pointSt to:segment.pointFn];
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    [geometriesArray addObject:geometry];
    
}// createPolygonalFromSegment


- (void) addCurvesForListPoints:(NSArray *) listPoints
{
    if (!listPoints || [listPoints count] == 0)
        return;
    
    SYBezierController *bezierController = [[SYBezierController alloc]init];
    NSArray *curves = [bezierController buildBestBezierForListPoint:listPoints tolerance:toleranceBezier/*bezierTolerance*/];
    
    // Draw the resulting shape
    SYGeometry *geometry = [[SYGeometry alloc] initWithBezierCurves:curves];
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    [geometriesArray addObject:geometry];
    
}// addCurve:


- (void) addCircle:(CGRect) circleRect
{
    if (circleRect.size.width == .0 ||
        circleRect.size.height == .0)
        return;
    
    // Geometry parameters
    SYGeometry *geometry = [[SYGeometry alloc] initCircleInRect:circleRect];
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    [geometriesArray addObject:geometry];
    
}// addCircle:


- (void) addCircleWithRect:(CGRect) rect andTransform:(CGAffineTransform) transform
{
    // Geometry parameters
    SYGeometry *geometry = [[SYGeometry alloc] initCircleInRect:rect andTransform:transform];
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    [geometriesArray addObject:geometry];
    
}// addCircleWithRect:andTransform:


- (void) addArc:(CGPoint) midPoint radius:(NSUInteger) radius startAngle:(CGFloat) startAngle endAngle:(CGFloat) endAngle clockwise:(BOOL) clockwise
{
    if (radius == 0 ||
        startAngle - endAngle == .0)
        return;
    
    SYGeometry *geometry = [[SYGeometry alloc] initArcWithMidPoint:midPoint radius:radius startAngle:startAngle endAngle:endAngle andClockWise:clockwise];
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    [geometriesArray addObject:geometry];
    
}// addArc:radius:startAngle:endAngle:clockwise:


- (void) addRectangle:(CGRect)rect
{
    // Geometry parameters
    SYGeometry *geometry = [[SYGeometry alloc] initSquareInRect:rect];
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    [geometriesArray addObject:geometry];
    
}// addRectangle:


- (void) addRotateRectangle:(NSArray *) pointArray
{
    if ([pointArray count] > 5 ||
        [pointArray count] < 4)
        return;
    
    // Snap angles
    // Get the four segments
    CGPoint keyPointA = [[pointArray objectAtIndex:0]CGPointValue];
    CGPoint keyPointB = [[pointArray objectAtIndex:1]CGPointValue];
    CGPoint keyPointC = [[pointArray objectAtIndex:2]CGPointValue];
    
    SYSegment *segmentAB = [[SYSegment alloc]initWithPoint:keyPointA andPoint:keyPointB];
    SYSegment *segmentBC = [[SYSegment alloc]initWithPoint:keyPointB andPoint:keyPointC];
    
    // Study the direction for next point
    float cosAB = cosf([segmentBC angleRad]);
    float possibleCosBC = cosf([segmentAB angleRad] + M_PI_2);
    
    if (cosAB * possibleCosBC < .0)
        [segmentBC setFinalPointToDegree:[segmentAB angleDeg] - 90.0];
    else
        [segmentBC setFinalPointToDegree:[segmentAB angleDeg] + 90.0];
    keyPointC = [segmentBC pointFn];

    // Third Segment
    CGPoint keyPointD = CGPointMake(keyPointC.x - (cosf([segmentAB angleRad]) * [segmentAB longitude]),
                                    keyPointC.y + (sinf([segmentAB angleRad]) * [segmentAB longitude]));
    
    // Create geometry
    SYGeometry *geometry = [[SYGeometry alloc] initWithRotatedRectangleFrom:keyPointA to:keyPointB to:keyPointC to:keyPointD];
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    [geometriesArray addObject:geometry];
    
}// addRotateRectangle:


#pragma mark - Replace Elements

- (void) replaceElementAtIndex:(NSUInteger) index withElement:(id) element
{
    if (!element)
        return;
    
    // The new element is a list Points
    if ([element isKindOfClass:[NSArray class]] ||
        [element isKindOfClass:[NSMutableArray class]]) {
        
        NSArray *curvePoints = element;
        if (!curvePoints || [curvePoints count] == 0)
            return;
        
        SYSegment *segment = [[SYSegment alloc]initWithPoint:[[curvePoints objectAtIndex:0]CGPointValue]
                                                    andPoint:[[curvePoints lastObject]CGPointValue]];
        CGFloat longitude = [segment longitude];
        
        if (longitude < 80.0) {
            SYBezierController *bezierController = [[SYBezierController alloc]init];
            NSArray *curves = [bezierController buildCubicBezierPointsForListPoint:curvePoints];
            
            // Draw the resulting shape
            SYGeometry *geometry = [[SYGeometry alloc] initWithBezierCurves:curves];
            
            // Draw properties
            geometry.lineWidth = 4.0;
            geometry.fillColor = [UIColor clearColor];
            geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
            
            [geometriesArray replaceObjectAtIndex:index
                                       withObject:geometry];
        }
        else {
            SYBezierController *bezierController = [[SYBezierController alloc]init];
            NSArray *curves = [bezierController buildBestBezierForListPoint:curvePoints tolerance:toleranceBezier/*bezierTolerance*/];
            
            // Draw the resulting shape
            SYGeometry *geometry = [[SYGeometry alloc] initWithBezierCurves:curves];
            
            // Draw properties
            geometry.lineWidth = 4.0;
            geometry.fillColor = [UIColor clearColor];
            geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
            
            [geometriesArray replaceObjectAtIndex:index
                                       withObject:geometry];
        }
    }
    // It's a segment
    else if ([element isKindOfClass:[SYSegment class]]) {
        
        if (!element)
            return;
        
        // Draw the resulting shape
        SYGeometry *geometry = [[SYGeometry alloc] initWithSegmentFrom:[element pointSt] to:[element pointFn]];
        
        // Draw properties
        geometry.lineWidth = 4.0;
        geometry.fillColor = [UIColor clearColor];
        geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
        
        [geometriesArray replaceObjectAtIndex:index
                                   withObject:geometry];
    }
    else if ([element isKindOfClass:[SYGeometry class]]) {
        [geometriesArray replaceObjectAtIndex:index
                                   withObject:element];
    }
    // It's a SYGeometry
    else if ([element isKindOfClass:[SYGeometry class]]) {
        
        if (!element)
            return;
        
        // Draw the resulting shape
        SYGeometry *geometry = (SYGeometry *) element;        
        [geometriesArray replaceObjectAtIndex:index
                                   withObject:geometry];
    }
        
}// replaceElementAtIndex:withElement:


- (void) replaceLastElementWithElement:(id) element
{
    if (!element)
        return;
    
    if ([element isKindOfClass:[NSArray class]] ||
        [element isKindOfClass:[NSMutableArray class]]) {
        
        if ([element count] == 0)
            return;
        
        SYSegment *segment = [[SYSegment alloc]initWithPoint:[[element objectAtIndex:0]CGPointValue]
                                                    andPoint:[[element lastObject]CGPointValue]];
        CGFloat longitude = [segment longitude];
        
        if (longitude < 80.0) {
            SYBezierController *bezierController = [[SYBezierController alloc]init];
            NSArray *curves = [bezierController buildCubicBezierPointsForListPoint:element];
            
            // Draw the resulting shape
            SYGeometry *geometry = [[SYGeometry alloc] initWithBezierCurves:curves];
            
            // Draw properties
            geometry.lineWidth = 4.0;
            geometry.fillColor = [UIColor clearColor];
            geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
            
            [geometriesArray replaceObjectAtIndex:[geometriesArray count]-1
                                       withObject:geometry];
        }
        else {
            SYBezierController *bezierController = [[SYBezierController alloc]init];
            NSArray *curves = [bezierController buildBestBezierForListPoint:element tolerance:toleranceBezier/*bezierTolerance*/];
            
            // Draw the resulting shape
            SYGeometry *geometry = [[SYGeometry alloc] initWithBezierCurves:curves];
            
            // Draw properties
            geometry.lineWidth = 4.0;
            geometry.fillColor = [UIColor clearColor];
            geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
            
            [geometriesArray replaceObjectAtIndex:[geometriesArray count]-1
                                       withObject:geometry];
        }
    }
    else if ([element isKindOfClass:[SYSegment class]]) {
        
        // Draw the resulting shape
        SYGeometry *geometry = [[SYGeometry alloc] initWithSegmentFrom:[element pointSt] to:[element pointFn]];
        
        // Draw properties
        geometry.lineWidth = 4.0;
        geometry.fillColor = [UIColor clearColor];
        geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
        
        [geometriesArray replaceObjectAtIndex:[geometriesArray count]-1
                                   withObject:geometry];
    }
    else if ([element isKindOfClass:[SYGeometry class]]) {        
        [geometriesArray replaceObjectAtIndex:[geometriesArray count]-1
                                   withObject:element];
    }
    
}// replaceLastElementWithElement:


#pragma mark - Modify shape

- (void) snapLinesAngles
{
    if (self.isOpenCurve) {
        
        // Single line
        if ([geometriesArray count] == 1) {
            
            SYGeometry *geometryCurrent = [geometriesArray objectAtIndex:0];
            
            if (geometryCurrent.geometryType == LinesType) {
                // Snap. Start point pivot
                CGPoint pointSt = [[geometryCurrent.pointArray objectAtIndex:0]CGPointValue];
                CGPoint pointFn = [[geometryCurrent.pointArray objectAtIndex:1]CGPointValue];
                
                SYSegment *segment = [[SYSegment alloc]initWithPoint:pointSt andPoint:pointFn];
                [segment snapAngleChangingFinalPoint];
                
                // create a replacement geometry
                SYGeometry* replacementGeometry = [[SYGeometry alloc] initWithSegment:segment];
                [replacementGeometry matchDrawingPropertiesOf:geometryCurrent];
                // now swap it into place
                [geometriesArray replaceObjectAtIndex:0 withObject:replacementGeometry];
            }
        }
        // Two o more lines
        else {
            
            // There is not enough points to snap
            if ([geometriesArray count] < 3)
                return;
            
            // The first line
            SYGeometry *geometryCurrent = [geometriesArray objectAtIndex:0];
            if (geometryCurrent.geometryType == LinesType) {
                
                // Snap. Start point pivot
                CGPoint pointSt = [[geometryCurrent.pointArray objectAtIndex:0]CGPointValue];
                CGPoint pointFn = [[geometryCurrent.pointArray objectAtIndex:1]CGPointValue];
                
                SYSegment *segment = [[SYSegment alloc]initWithPoint:pointSt andPoint:pointFn];
                if ([segment isSnapAngle])
                    [segment snapAngleChangingStartPoint];
                
                // prep a replacement geometry
                SYGeometry* replacementGeometry = [[SYGeometry alloc] initWithSegment:segment];
                [replacementGeometry matchDrawingPropertiesOf:geometryCurrent];
                // now swap it into place
                [geometriesArray replaceObjectAtIndex:0 withObject:replacementGeometry];
            }
            
            for (int i = 1 ; i < [geometriesArray count]-1 ; i++) {
                
                SYGeometry *geometryCurrent = [geometriesArray objectAtIndex:i];
                SYGeometry *geometryNext = [geometriesArray objectAtIndex:i+1];
                
                if (geometryCurrent.geometryType == LinesType &&
                    geometryNext.geometryType == LinesType) {
                    
                    // Snap. Start point pivot
                    CGPoint pointSt = [[geometryCurrent.pointArray objectAtIndex:0]CGPointValue];
                    CGPoint pointFn = [[geometryCurrent.pointArray objectAtIndex:1]CGPointValue];
                    
                    SYSegment *segment = [[SYSegment alloc]initWithPoint:pointSt andPoint:pointFn];
                    [segment snapAngleChangingFinalPoint];
                    
                    // Snap. Get the new points final point in the current line
                    // and it will be the first point in the next one
                    CGPoint pointStNext = [[geometryNext.pointArray objectAtIndex:0]CGPointValue];
                    CGPoint pointFnNext = [[geometryNext.pointArray objectAtIndex:1]CGPointValue];
                    
                    SYSegment *segmentNext = [[SYSegment alloc]initWithPoint:pointStNext andPoint:pointFnNext];
                    CGPoint intersectionPoint = [segment pointIntersectWithSegment:segmentNext];
                    
                    // prep the replacement geometry
                    SYGeometry* replacementCurrent = [[SYGeometry alloc] initWithSegmentFrom:pointSt to:intersectionPoint];
                    SYGeometry* replacementNext = [[SYGeometry alloc] initWithSegmentFrom:intersectionPoint to:pointFnNext];
                    [replacementCurrent matchDrawingPropertiesOf:geometryCurrent];
                    [replacementNext matchDrawingPropertiesOf:geometryNext];

                    // now swap them into the array
                    [geometriesArray replaceObjectAtIndex:i withObject:replacementCurrent];
                    [geometriesArray replaceObjectAtIndex:i+1 withObject:replacementNext];
                }
            }
            
            // The last line
            geometryCurrent = [geometriesArray lastObject];
            if (geometryCurrent.geometryType == LinesType) {
                
                // Snap. Start point pivot
                CGPoint pointSt = [[geometryCurrent.pointArray objectAtIndex:0]CGPointValue];
                CGPoint pointFn = [[geometryCurrent.pointArray objectAtIndex:1]CGPointValue];
                
                SYSegment *segment = [[SYSegment alloc]initWithPoint:pointSt andPoint:pointFn];
                [segment snapAngleChangingFinalPoint];
                // replace the geometry with the snapped version
                [geometriesArray removeLastObject];
                [geometriesArray addObject:[[SYGeometry alloc] initWithSegment:segment]];
            }
        }
    }
    else {
        // Single line
        if ([geometriesArray count] == 1) {
            
            SYGeometry *geometryCurrent = [geometriesArray objectAtIndex:0];
            
            if (geometryCurrent.geometryType == LinesType) {
                // Snap. Start point pivot
                CGPoint pointSt = [[geometryCurrent.pointArray objectAtIndex:0]CGPointValue];
                CGPoint pointFn = [[geometryCurrent.pointArray objectAtIndex:1]CGPointValue];
                
                SYSegment *segment = [[SYSegment alloc]initWithPoint:pointSt andPoint:pointFn];
                [segment snapAngleChangingFinalPoint];
                
                [geometriesArray replaceObjectAtIndex:0 withObject:[[SYGeometry alloc] initWithSegment:segment]];
                [[geometriesArray objectAtIndex:0] matchDrawingPropertiesOf:geometryCurrent];
            }
        }
        // Two o more lines
        else {

            // There is not enough points to snap
            if ([geometriesArray count] < 3)
                return;
            
            for (int i = 1 ; i < [geometriesArray count]-1 ; i++) {
                
                SYGeometry *geometryCurrent = [geometriesArray objectAtIndex:i];
                SYGeometry *geometryNext = [geometriesArray objectAtIndex:i+1];
                
                if (geometryCurrent.geometryType == LinesType &&
                    geometryNext.geometryType == LinesType) {
                    
                    // Snap. Start point pivot
                    CGPoint pointSt = [[geometryCurrent.pointArray objectAtIndex:0]CGPointValue];
                    CGPoint pointFn = [[geometryCurrent.pointArray objectAtIndex:1]CGPointValue];
                    
                    SYSegment *segment = [[SYSegment alloc]initWithPoint:pointSt andPoint:pointFn];
                    [segment snapAngleChangingFinalPoint];
                    
                    // Snap. Get the new points final point in the current line
                    // and it will be the first point in the next one
                    CGPoint pointStNext = [[geometryNext.pointArray objectAtIndex:0]CGPointValue];
                    CGPoint pointFnNext = [[geometryNext.pointArray objectAtIndex:1]CGPointValue];
                    
                    SYSegment *segmentNext = [[SYSegment alloc]initWithPoint:pointStNext andPoint:pointFnNext];
                    CGPoint intersectionPoint = [segment pointIntersectWithSegment:segmentNext];
                    
                    // prep replacement geometry
                    SYGeometry* replacementCurrent = [[SYGeometry alloc] initWithSegmentFrom:pointSt to:intersectionPoint];
                    SYGeometry* replacementNext = [[SYGeometry alloc] initWithSegmentFrom:intersectionPoint to:pointFnNext];
                    [replacementCurrent matchDrawingPropertiesOf:geometryCurrent];
                    [replacementNext matchDrawingPropertiesOf:geometryNext];

                    // now swap them into the array
                    [geometriesArray replaceObjectAtIndex:i withObject:replacementCurrent];
                    [geometriesArray replaceObjectAtIndex:i+1 withObject:replacementNext];
                }
            }
           
            
            // The first line
            SYGeometry *geometryCurrent = [geometriesArray objectAtIndex:0];
            SYGeometry *geometryLast = [geometriesArray lastObject];
            
            if (geometryCurrent.geometryType == LinesType &&
                geometryLast.geometryType == LinesType) {
                
                // Snap. Start point pivot
                CGPoint pointSt = [[geometryCurrent.pointArray objectAtIndex:0]CGPointValue];
                CGPoint pointFn = [[geometryCurrent.pointArray objectAtIndex:1]CGPointValue];
                
                SYSegment *firstSegment = [[SYSegment alloc]initWithPoint:pointSt andPoint:pointFn];
                [firstSegment snapAngleChangingStartPoint];
                
                if (self.isClosedCurve) {
                    // Snap. Final point pivot
                    pointSt = [[geometryLast.pointArray objectAtIndex:0]CGPointValue];
                    pointFn = [[geometryLast.pointArray objectAtIndex:1]CGPointValue];
                    
                    SYSegment *lastSegment = [[SYSegment alloc]initWithPoint:pointSt andPoint:pointFn];
                    [lastSegment snapAngleChangingFinalPoint];
                    
                    // Intersection between the two snap lines
                    CGPoint intersectPoint = [firstSegment pointIntersectWithSegment:lastSegment];
                    
                    // If exist intersectPoint
                    if (intersectPoint.x != 10000.0 || intersectPoint.y != 10000.0) {
                        // Update geometries
                        
                        // prep replacement geometry
                        SYGeometry* replacementCurrent = [[SYGeometry alloc] initWithSegmentFrom:pointSt to:intersectPoint];
                        SYGeometry* replacementLast = [[SYGeometry alloc] initWithSegmentFrom:intersectPoint to:pointFn];
                        
                        [replacementCurrent matchDrawingPropertiesOf:geometryCurrent];
                        [replacementLast matchDrawingPropertiesOf:geometryLast];

                        // now swap them into the array
                        [geometriesArray replaceObjectAtIndex:0 withObject:replacementCurrent];
                        [geometriesArray removeLastObject];
                        [geometriesArray addObject:replacementLast];
                    }
                }
            }
        }
    }
    
}// snapLinesAngles


- (void) closeShapeIfPossible
{
    // Get the first and the last curve
    SYGeometry *firstShape = [self getElement:0];
    SYGeometry *lastShape = [self getLastElement];
    
    if ([firstShape geometryType] == LinesType &&
        [lastShape geometryType] == LinesType) {
                
        CGPoint firstPointSt = [[[firstShape pointArray]objectAtIndex:0]CGPointValue];
        CGPoint lastPointFn = [[[lastShape pointArray]objectAtIndex:1]CGPointValue];
        CGPoint midPoint = [self midPointBetweenPoint:firstPointSt
                                             andPoint:lastPointFn];
        
        SYSegment *newFirstSegment = [[SYSegment alloc]initWithPoint:midPoint andPoint:[[[firstShape pointArray]objectAtIndex:1]CGPointValue]];
        SYSegment *newLastSegment = [[SYSegment alloc]initWithPoint:[[[lastShape pointArray]objectAtIndex:0]CGPointValue] andPoint:midPoint];
        
        [self replaceElementAtIndex:0 withElement:newFirstSegment];
        [self replaceLastElementWithElement:newLastSegment];
        
    }
    else if ([firstShape geometryType] == BezierType &&
             [lastShape geometryType] == LinesType) {
        
        // Get the midPoint between the current bezier and the last point in the previous line
        SYBezier *bezier = [[firstShape pointArray]objectAtIndex:0];        
        CGPoint firstPointSt = bezier.t0Point;
        CGPoint lastPointFn = [[[lastShape pointArray]objectAtIndex:1]CGPointValue];
        CGPoint midPoint = [self midPointBetweenPoint:firstPointSt
                                             andPoint:lastPointFn];
        
        // Move the first point in the bezier curve to midpoint
        NSMutableArray *curves = [NSMutableArray arrayWithArray:firstShape.pointArray];
        SYBezier *bezierToChange = [curves objectAtIndex:0];
        bezierToChange.t0Point = midPoint;
        [curves replaceObjectAtIndex:0 withObject:bezierToChange];
        
        // Create the new bezier (modified the original)
        SYGeometry *geometry = [[SYGeometry alloc] initWithBezierCurves:curves];
        geometry.lineWidth = 4.0;
        geometry.fillColor = [UIColor clearColor];
        geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];

        // And replace the other one
        [self replaceElementAtIndex:0 withElement:geometry];
        
        // Move the last point in the line
        SYSegment *newLastSegment = [[SYSegment alloc]initWithPoint:[[[lastShape pointArray]objectAtIndex:0]CGPointValue] andPoint:midPoint];
        [self replaceLastElementWithElement:newLastSegment];
        
    }
    else if ([firstShape geometryType] == LinesType &&
             [lastShape geometryType] == BezierType) {
                
        CGPoint firstPointSt = [[[firstShape pointArray]objectAtIndex:0]CGPointValue];
        
        SYBezier *bezier = [[lastShape pointArray]lastObject];
        CGPoint lastPointFn = bezier.t3Point;
        CGPoint midPoint = [self midPointBetweenPoint:firstPointSt
                                             andPoint:lastPointFn];

        // Move the first point in the line
        SYSegment *newFirstSegment = [[SYSegment alloc]initWithPoint:midPoint andPoint:[[[firstShape pointArray]objectAtIndex:1]CGPointValue]];
        [self replaceElementAtIndex:0 withElement:newFirstSegment];
        
        // Move the last point in the bezier
        NSMutableArray *curves = [NSMutableArray arrayWithArray:lastShape.pointArray];
        SYBezier *newBezier = [curves lastObject];
        newBezier.t3Point = midPoint;
        [curves replaceObjectAtIndex:[curves count]-1 withObject:newBezier];
        
        // Create the new bezier (modified the original)
        SYGeometry *geometry = [[SYGeometry alloc] initWithBezierCurves:curves];
        geometry.lineWidth = 4.0;
        geometry.fillColor = [UIColor clearColor];
        geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
        
        // And replace the other one
        [self replaceLastElementWithElement:geometry];
                
    }
    else if([geometriesArray count]){
        // Get the midPoint between the current bezier and the last point in the previous line
        SYBezier *bezier = [[firstShape pointArray]objectAtIndex:0];
        SYBezier *lastBezier = [[lastShape pointArray]lastObject];
        CGPoint firstPointSt = bezier.t0Point;
        CGPoint lastPointFn = lastBezier.t3Point;
        CGPoint midPoint = [self midPointBetweenPoint:firstPointSt
                                             andPoint:lastPointFn];
        
        // Move the first point in the bezier curve to midpoint
        NSMutableArray *curves = [NSMutableArray arrayWithArray:firstShape.pointArray];
        SYBezier *bezierToChange = [curves objectAtIndex:0];
        bezierToChange.t0Point = midPoint;
        [curves replaceObjectAtIndex:0 withObject:bezierToChange];
        
        // Create the new bezier (modified the original)
        SYGeometry *geometry = [[SYGeometry alloc] initWithBezierCurves:curves];
        geometry.lineWidth = 4.0;
        geometry.fillColor = [UIColor clearColor];
        geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
        
        // And replace the other one
        [self replaceElementAtIndex:0 withElement:geometry];
        
        // Move the last point in the bezier
        curves = [NSMutableArray arrayWithArray:lastShape.pointArray];
        SYBezier *newBezier = [curves lastObject];
        newBezier.t3Point = midPoint;
        [curves replaceObjectAtIndex:[curves count]-1 withObject:newBezier];
        
        // Create the new bezier (modified the original)
        geometry = [[SYGeometry alloc] initWithBezierCurves:curves];
        geometry.lineWidth = 4.0;
        geometry.fillColor = [UIColor clearColor];
        geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
        
        // And replace the other one
        [self replaceLastElementWithElement:geometry];
    }
    
}// checkCloseShape


- (void) forceContinuity:(float) sliderValue
{
    if (sliderValue == 0)
        return;
    
    for (NSUInteger i = 1; i < [self geometriesCount]; i++) {
        
        // Get two contiguous shape and check if they're bezier
        SYGeometry *firstShape = [self getElement:i-1];
        SYGeometry *lastShape = [self getElement:i];
        
        if ([firstShape geometryType] == BezierType &&
            [lastShape geometryType] == BezierType) {
            
            SYBezier *bezierFirst = [[firstShape pointArray]lastObject];
            SYBezier *bezierLast = [[lastShape pointArray]objectAtIndex:0];
            
            // Get the three important points
            CGPoint previousCP = bezierFirst.cPointB;
            CGPoint pivotal = bezierLast.t0Point;
            CGPoint currentCP = bezierLast.cPointA;
            
            // Study the angle between them
            SYSegment *segmentA = [[SYSegment alloc]initWithPoint:pivotal andPoint:previousCP];
            SYSegment *segmentB = [[SYSegment alloc]initWithPoint:pivotal andPoint:currentCP];
            
            CGFloat angleA = [segmentA angleDeg];
            CGFloat angleB = [segmentB angleDeg];
            CGFloat alfa = .0;
            if (angleA > angleB)
                alfa  = angleA - angleB;
            else
                alfa  = angleB - angleA;
            
            CGFloat beta = fabsf((180.0 - alfa) * 0.5) * sliderValue;
            
            if (alfa < 180.0) {
//                if(alfa > 90){
//                    // test code for allowing to keep cusps
//                    // even when continuity is 1.0
//                    CGFloat distFrom180 = alfa;
//                    distFrom180 = abs(alfa - 180);
//                    CGFloat otherBeta = fabsf((180.0 - alfa) * 0.5) * sliderValue * distFrom180/90.0;
//                    DebugLog(@"beta1: %f  vs otherBeta: %f", beta, otherBeta);
//                }
                
                if (angleA > angleB) {
                    [segmentA setFinalPointToDegree:angleA+beta];
                    [segmentB setFinalPointToDegree:angleB-beta];
                }
                else {
                    [segmentA setFinalPointToDegree:angleA-beta];
                    [segmentB setFinalPointToDegree:angleB+beta];
                }
            }
            else {
//                if(alfa > 270){
//                // test code for allowing to keep cusps
//                // even when continuity is 1.0
//                    CGFloat distFrom180 = alfa;
//                    CGFloat otherAlpha = alfa - 180;
//                    distFrom180 = abs(otherAlpha - 180);
//                    CGFloat otherBeta = fabsf((180.0 - otherAlpha) * 0.5) * sliderValue * distFrom180/90.0;
//                    DebugLog(@"beta2: %f  vs otherBeta: %f", beta, otherBeta);
//                }
                if (angleA > angleB) {
                    [segmentA setFinalPointToDegree:angleA-beta];
                    [segmentB setFinalPointToDegree:angleB+beta];
                }
                else {
                    [segmentA setFinalPointToDegree:angleA+beta];
                    [segmentB setFinalPointToDegree:angleB-beta];
                }
            }
            
            // Get the new points
            bezierFirst.cPointB = [segmentA pointFn];
            bezierLast.cPointA = [segmentB pointFn];
        }
    }
    
    // And if it's a close shape, the first bezier with the last one
    if ([self isClosedCurve]) {
        // Get two contiguous shape and check if they're bezier
        SYGeometry *firstShape = [self getElement:0];
        SYGeometry *lastShape = [self getElement:[self geometriesCount]-1];
        
        if ([firstShape geometryType] == BezierType &&
            [lastShape geometryType] == BezierType) {
            
            SYBezier *bezierFirst = [[firstShape pointArray]objectAtIndex:0];
            SYBezier *bezierLast = [[lastShape pointArray]lastObject];
            
            // Get the three important points
            CGPoint previousCP = bezierFirst.cPointA;
            CGPoint pivotal = bezierLast.t3Point;
            CGPoint currentCP = bezierLast.cPointB;
            
            // Study the angle between them
            SYSegment *segmentA = [[SYSegment alloc]initWithPoint:pivotal andPoint:previousCP];
            SYSegment *segmentB = [[SYSegment alloc]initWithPoint:pivotal andPoint:currentCP];
            
            CGFloat angleA = [segmentA angleDeg];
            CGFloat angleB = [segmentB angleDeg];
            CGFloat alfa = .0;
            if (angleA > angleB)
                alfa  = angleA - angleB;
            else
                alfa  = angleB - angleA;
            
            CGFloat beta = fabsf((180.0 - alfa) * 0.5) * sliderValue;
            
            if (alfa < 180.0) {
                if (angleA > angleB) {
                    [segmentA setFinalPointToDegree:angleA+beta];
                    [segmentB setFinalPointToDegree:angleB-beta];
                }
                else {
                    [segmentA setFinalPointToDegree:angleA-beta];
                    [segmentB setFinalPointToDegree:angleB+beta];
                }
            }
            else {
                if (angleA > angleB) {
                    [segmentA setFinalPointToDegree:angleA-beta];
                    [segmentB setFinalPointToDegree:angleB+beta];
                }
                else {
                    [segmentA setFinalPointToDegree:angleA+beta];
                    [segmentB setFinalPointToDegree:angleB-beta];
                }
            }
            
            // Get the new points
            bezierFirst.cPointA = [segmentA pointFn];
            bezierLast.cPointB = [segmentB pointFn];
        }
    }
    
}// forceContinuity


#pragma mark - Other Methods

- (CGPoint) midPointBetweenPoint:(CGPoint) pointA andPoint:(CGPoint) pointB
{
    CGFloat xPoint = (pointA.x + pointB.x) / 2;
    CGFloat yPoint = (pointA.y + pointB.y) / 2;
    CGPoint result = CGPointMake(xPoint, yPoint);
    
    return result;
    
}// midPointBetween:andPoint:

@end
