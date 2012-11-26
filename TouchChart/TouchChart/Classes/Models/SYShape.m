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

// Other Methods
- (CGPoint) midPointBetweenPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;

@end


@implementation SYShape

@synthesize closeCurve;
@synthesize openCurve;


- (id) init
{
    self = [super init];
    
    if (self) {
        geometriesArray = [[NSMutableArray alloc]init];
        openCurve = NO;
        closeCurve = NO;
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
        if (geometry.geometryType == SquareType)
            [string appendString:@"type: Square\n"];
        else if (geometry.geometryType == CircleType)
            [string appendFormat:@"type: CircleType: (%f, %f)\n", geometry.rectGeometry.origin.x, geometry.rectGeometry.origin.y];
        else if (geometry.geometryType == LinesType)
            [string appendString:@"type: LinesType\n"];
        else if (geometry.geometryType == BezierType)
            [string appendString:@"type: BezierType\n"];
        else if (geometry.geometryType == ArcType)
            [string appendString:@"type: ArcType\n"];
    }
    
    return [NSString stringWithString:string];
    
}// description


#pragma mark - Setter Methods

- (void) setCloseCurve: (BOOL) isCloseCurve
{
    closeCurve = isCloseCurve;
    openCurve = !isCloseCurve;
    
}// setCloseCurve


- (void) setOpenCurve:(BOOL)isOpenCurve
{
    openCurve = isOpenCurve;
    closeCurve = !isOpenCurve;
    
}// setOpenCurve


#pragma mark - Getter elements

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
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = CircleType;
    geometry.rectGeometry = CGRectMake(keyPoint.x - 3.0, keyPoint.y - 3.0, 6.0, 6.0);
    
    // Draw properties
    geometry.lineWidth = 2.0;
    geometry.fillColor = [UIColor redColor];
    geometry.strokeColor = [UIColor redColor];
    
    [geometriesArray addObject:geometry];
    [geometry release];
    
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
    [geometry release];
    
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


- (void) addCircle:(CGRect) circleRect
{
    if (circleRect.size.width == .0 ||
        circleRect.size.height == .0)
        return;
    
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = CircleType;
    geometry.rectGeometry = circleRect;
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    [geometriesArray addObject:geometry];
    [geometry release];
    
}// addCircle:


- (void) addCircleWithRect:(CGRect) rect andTransform:(CGAffineTransform) transform
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = CircleType;
    geometry.rectGeometry = rect;
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    geometry.transform = transform;
    
    [geometriesArray addObject:geometry];
    [geometry release];
    
}// addCircleWithRect:andTransform:


- (void) addArc:(CGPoint) midPoint radius:(NSUInteger) radius startAngle:(CGFloat) startAngle endAngle:(CGFloat) endAngle clockwise:(BOOL) clockwise
{
    if (radius == 0 ||
        startAngle - endAngle == .0)
        return;
    
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = ArcType;
    [geometry setArcParametersWithMidPoint:midPoint
                                    radius:radius
                                startAngle:startAngle
                                  endAngle:endAngle
                              andClockWise:clockwise];
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    [geometriesArray addObject:geometry];
    [geometry release];
    
}// addArc:radius:startAngle:endAngle:clockwise:


#pragma mark - Replace Elements

- (void) replaceElementAtIndex:(NSUInteger) index withElement:(id) element
{
    if (!element)
        return;
    
    if ([element isKindOfClass:[NSArray class]] ||
        [element isKindOfClass:[NSMutableArray class]]) {
        
        NSArray *curvePoints = element;
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
            
            [geometriesArray replaceObjectAtIndex:index
                                       withObject:geometry];
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
            
            [geometriesArray replaceObjectAtIndex:index
                                       withObject:geometry];
        }
    }
    else if ([element isKindOfClass:[SYSegment class]]) {
        
        if (!element)
            return;
        
        // Draw the resulting shape
        SYGeometry *geometry = [[[SYGeometry alloc]init]autorelease];
        
        // Geometry parameters
        geometry.geometryType = LinesType;
        geometry.pointArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:[element pointSt]],
                               [NSValue valueWithCGPoint:[element pointFn]], nil];
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
        [segment release];
        
        if (longitude < 80.0) {
            SYBezierController *bezierController = [[SYBezierController alloc]init];
            NSArray *curves = [bezierController getCubicBezierPointsForListPoint:element];
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
            
            [geometriesArray replaceObjectAtIndex:[geometriesArray count]-1
                                       withObject:geometry];
        }
        else {
            SYBezierController *bezierController = [[SYBezierController alloc]init];
            NSArray *curves = [bezierController getBestCurveForListPoint:element tolerance:0.01];
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
            
            [geometriesArray replaceObjectAtIndex:[geometriesArray count]-1
                                       withObject:geometry];
        }
    }
    else if ([element isKindOfClass:[SYSegment class]]) {
        
        // Draw the resulting shape
        SYGeometry *geometry = [[[SYGeometry alloc]init]autorelease];
        
        // Geometry parameters
        geometry.geometryType = LinesType;
        geometry.pointArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:[element pointSt]],
                               [NSValue valueWithCGPoint:[element pointFn]], nil];
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
    if (self.openCurve) {
        
        // Single line
        if ([geometriesArray count] == 1) {
            
            SYGeometry *geometryCurrent = [geometriesArray objectAtIndex:0];
            
            if (geometryCurrent.geometryType == LinesType) {
                // Snap. Start point pivot
                CGPoint pointSt = [[geometryCurrent.pointArray objectAtIndex:0]CGPointValue];
                CGPoint pointFn = [[geometryCurrent.pointArray objectAtIndex:1]CGPointValue];
                
                SYSegment *segment = [[[SYSegment alloc]initWithPoint:pointSt andPoint:pointFn]autorelease];
                [segment snapAngleChangingFinalPoint];
                
                geometryCurrent.pointArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:segment.pointSt],
                                              [NSValue valueWithCGPoint:segment.pointFn], nil];
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
                
                SYSegment *segment = [[[SYSegment alloc]initWithPoint:pointSt andPoint:pointFn]autorelease];
                if ([segment isSnapAngle])
                    [segment snapAngleChangingStartPoint];
                
                geometryCurrent.pointArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:segment.pointSt],
                                              [NSValue valueWithCGPoint:segment.pointFn], nil];
            }
            
            for (int i = 1 ; i < [geometriesArray count]-1 ; i++) {
                
                SYGeometry *geometryCurrent = [geometriesArray objectAtIndex:i];
                SYGeometry *geometryNext = [geometriesArray objectAtIndex:i+1];
                
                if (geometryCurrent.geometryType == LinesType &&
                    geometryNext.geometryType == LinesType) {
                    
                    // Snap. Start point pivot
                    CGPoint pointSt = [[geometryCurrent.pointArray objectAtIndex:0]CGPointValue];
                    CGPoint pointFn = [[geometryCurrent.pointArray objectAtIndex:1]CGPointValue];
                    
                    SYSegment *segment = [[[SYSegment alloc]initWithPoint:pointSt andPoint:pointFn]autorelease];
                    [segment snapAngleChangingFinalPoint];
                    
                    // Snap. Get the new points final point in the current line
                    // and it will be the first point in the next one
                    CGPoint pointStNext = [[geometryNext.pointArray objectAtIndex:0]CGPointValue];
                    CGPoint pointFnNext = [[geometryNext.pointArray objectAtIndex:1]CGPointValue];
                    
                    SYSegment *segmentNext = [[[SYSegment alloc]initWithPoint:pointStNext andPoint:pointFnNext]autorelease];
                    CGPoint intersectionPoint = [segment pointIntersectWithSegment:segmentNext];
                    
                    geometryCurrent.pointArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:pointSt],
                                                  [NSValue valueWithCGPoint:intersectionPoint], nil];
                    geometryNext.pointArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:intersectionPoint],
                                               [NSValue valueWithCGPoint:pointFnNext], nil];
                }
            }
            
            // The last line
            geometryCurrent = [geometriesArray lastObject];
            if (geometryCurrent.geometryType == LinesType) {
                
                // Snap. Start point pivot
                CGPoint pointSt = [[geometryCurrent.pointArray objectAtIndex:0]CGPointValue];
                CGPoint pointFn = [[geometryCurrent.pointArray objectAtIndex:1]CGPointValue];
                
                SYSegment *segment = [[[SYSegment alloc]initWithPoint:pointSt andPoint:pointFn]autorelease];
                [segment snapAngleChangingFinalPoint];
                
                geometryCurrent.pointArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:segment.pointSt],
                                              [NSValue valueWithCGPoint:segment.pointFn], nil];
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
                
                SYSegment *segment = [[[SYSegment alloc]initWithPoint:pointSt andPoint:pointFn]autorelease];
                [segment snapAngleChangingFinalPoint];
                
                geometryCurrent.pointArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:segment.pointSt],
                                              [NSValue valueWithCGPoint:segment.pointFn], nil];
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
                    
                    SYSegment *segment = [[[SYSegment alloc]initWithPoint:pointSt andPoint:pointFn]autorelease];
                    [segment snapAngleChangingFinalPoint];
                    
                    // Snap. Get the new points final point in the current line
                    // and it will be the first point in the next one
                    CGPoint pointStNext = [[geometryNext.pointArray objectAtIndex:0]CGPointValue];
                    CGPoint pointFnNext = [[geometryNext.pointArray objectAtIndex:1]CGPointValue];
                    
                    SYSegment *segmentNext = [[[SYSegment alloc]initWithPoint:pointStNext andPoint:pointFnNext]autorelease];
                    CGPoint intersectionPoint = [segment pointIntersectWithSegment:segmentNext];
                    
                    geometryCurrent.pointArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:pointSt],
                                                  [NSValue valueWithCGPoint:intersectionPoint], nil];
                    geometryNext.pointArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:intersectionPoint],
                                               [NSValue valueWithCGPoint:pointFnNext], nil];
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
                
                SYSegment *firstSegment = [[[SYSegment alloc]initWithPoint:pointSt andPoint:pointFn]autorelease];
                [firstSegment snapAngleChangingStartPoint];
                
                if (self.closeCurve) {
                    // Snap. Final point pivot
                    pointSt = [[geometryLast.pointArray objectAtIndex:0]CGPointValue];
                    pointFn = [[geometryLast.pointArray objectAtIndex:1]CGPointValue];
                    
                    SYSegment *lastSegment = [[[SYSegment alloc]initWithPoint:pointSt andPoint:pointFn]autorelease];
                    [lastSegment snapAngleChangingFinalPoint];
                    
                    // Intersection between the two snap lines
                    CGPoint intersectPoint = [firstSegment pointIntersectWithSegment:lastSegment];
                    
                    // Update geometries
                    geometryCurrent.pointArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:intersectPoint],
                                                  [NSValue valueWithCGPoint:firstSegment.pointFn], nil];
                    
                    geometryLast.pointArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:lastSegment.pointSt],
                                               [NSValue valueWithCGPoint:intersectPoint], nil];
                }
            }
        }
    }
    
}// snapLinesAngles


- (void) checkCloseShape
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
        
        [newFirstSegment release];
        [newLastSegment release];
    }
    else if ([firstShape geometryType] == BezierType &&
             [lastShape geometryType] == LinesType) {
                
        CGPoint firstPointSt = [[[[firstShape pointArray]objectAtIndex:0]valueForKey:@"t0Point"]CGPointValue];
        CGPoint lastPointFn = [[[lastShape pointArray]objectAtIndex:1]CGPointValue];
        CGPoint midPoint = [self midPointBetweenPoint:firstPointSt
                                             andPoint:lastPointFn];
        
        // Move the first point in the bezier curve
        NSMutableArray *curves = [NSMutableArray arrayWithArray:firstShape.pointArray];
        NSMutableDictionary *dictMut = [NSMutableDictionary dictionaryWithDictionary:[curves objectAtIndex:0]];
        [dictMut setValue:[NSValue valueWithCGPoint:midPoint] forKey:@"t0Point"];
        [curves replaceObjectAtIndex:0 withObject:dictMut];
        
        // Create the new bezier (modified the original)
        SYGeometry *geometry = [[SYGeometry alloc]init];
        geometry.geometryType = BezierType;
        geometry.pointArray = curves;
        geometry.lineWidth = 4.0;
        geometry.fillColor = [UIColor clearColor];
        geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];

        // And replace the other one
        [self replaceElementAtIndex:0 withElement:geometry];
        [geometry release];
        
        // Move the last point in the line
        SYSegment *newLastSegment = [[SYSegment alloc]initWithPoint:[[[lastShape pointArray]objectAtIndex:0]CGPointValue] andPoint:midPoint];
        [self replaceLastElementWithElement:newLastSegment];
        [newLastSegment release];
        
    }
    else if ([firstShape geometryType] == LinesType &&
             [lastShape geometryType] == BezierType) {
                
        CGPoint firstPointSt = [[[firstShape pointArray]objectAtIndex:0]CGPointValue];
        CGPoint lastPointFn = [[[[lastShape pointArray]lastObject]valueForKey:@"t3Point"]CGPointValue];
        CGPoint midPoint = [self midPointBetweenPoint:firstPointSt
                                             andPoint:lastPointFn];

        // Move the first point in the line
        SYSegment *newFirstSegment = [[SYSegment alloc]initWithPoint:midPoint andPoint:[[[firstShape pointArray]objectAtIndex:1]CGPointValue]];
        [self replaceElementAtIndex:0 withElement:newFirstSegment];
        [newFirstSegment release];
        
        // Move the last point in the bezier
        NSMutableArray *curves = [NSMutableArray arrayWithArray:lastShape.pointArray];
        NSMutableDictionary *dictMut = [NSMutableDictionary dictionaryWithDictionary:[curves lastObject]];
        [dictMut setValue:[NSValue valueWithCGPoint:midPoint] forKey:@"t3Point"];
        [curves replaceObjectAtIndex:[curves count]-1 withObject:dictMut];
        
        // Create the new bezier (modified the original)
        SYGeometry *geometry = [[SYGeometry alloc]init];
        geometry.geometryType = BezierType;
        geometry.pointArray = curves;
        geometry.lineWidth = 4.0;
        geometry.fillColor = [UIColor clearColor];
        geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
        
        // And replace the other one
        [self replaceLastElementWithElement:geometry];
        [geometry release];
                
    }
    else {

        CGPoint firstPointSt = [[[[firstShape pointArray]objectAtIndex:0]valueForKey:@"t0Point"]CGPointValue];
        CGPoint lastPointFn = [[[[lastShape pointArray]lastObject]valueForKey:@"t3Point"]CGPointValue];
        CGPoint midPoint = [self midPointBetweenPoint:firstPointSt
                                             andPoint:lastPointFn];
        
        // Move the first point in the bezier curve
        NSMutableArray *curves = [NSMutableArray arrayWithArray:firstShape.pointArray];
        NSMutableDictionary *dictMut = [NSMutableDictionary dictionaryWithDictionary:[curves objectAtIndex:0]];
        [dictMut setValue:[NSValue valueWithCGPoint:midPoint] forKey:@"t0Point"];
        [curves replaceObjectAtIndex:0 withObject:dictMut];
        
        // Create the new bezier (modified the original)
        SYGeometry *geometry = [[SYGeometry alloc]init];
        geometry.geometryType = BezierType;
        geometry.pointArray = curves;
        geometry.lineWidth = 4.0;
        geometry.fillColor = [UIColor clearColor];
        geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
        
        // And replace the other one
        [self replaceElementAtIndex:0 withElement:geometry];
        [geometry release];
        
        // Move the last point in the bezier
        curves = [NSMutableArray arrayWithArray:lastShape.pointArray];
        dictMut = [NSMutableDictionary dictionaryWithDictionary:[curves lastObject]];
        [dictMut setValue:[NSValue valueWithCGPoint:midPoint] forKey:@"t3Point"];
        [curves replaceObjectAtIndex:[curves count]-1 withObject:dictMut];
        
        // Create the new bezier (modified the original)
        geometry = [[SYGeometry alloc]init];
        geometry.geometryType = BezierType;
        geometry.pointArray = curves;
        geometry.lineWidth = 4.0;
        geometry.fillColor = [UIColor clearColor];
        geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
        
        // And replace the other one
        [self replaceLastElementWithElement:geometry];
        [geometry release];
    }
    
}// checkCloseShape


#pragma mark - Other Methods

- (CGPoint) midPointBetweenPoint:(CGPoint) pointA andPoint:(CGPoint) pointB
{
    CGFloat xPoint = (pointA.x + pointB.x) / 2;
    CGFloat yPoint = (pointA.y + pointB.y) / 2;
    CGPoint result = CGPointMake(xPoint, yPoint);
    
    return result;
    
}// midPointBetween:andPoint:

@end
