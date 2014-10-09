//
//  TCShapeController.m
//  TouchChart
//
//  Created by Adam Wulf on 8/15/13.
//
//

#import "TCShapeController.h"
#import "SYSegment.h"
#import "SYBezier.h"
#import "SYVector.h"
#import "SYBezierController.h"

@interface TCShapeController ()

// Calculate Shapes
- (SYShape*) buildShapeClose:(BOOL) isCloseShape withTolerance:(CGFloat)toleranceValue andContinuity:(CGFloat)continuityValue;

// Analyze Shape
- (BOOL) isRectangle;
- (BOOL) isRotateRectangle;
- (SYShape*) buildOvalCircleWithTolerance:(CGFloat)toleranceValue;

// Geometric calculations
- (CGFloat) distanceBetweenPoint:(CGPoint) point1 andPoint:(CGPoint) point2;
- (CGFloat) getAngleBetweenVertex:(CGPoint) vertex andPointA:(CGPoint) pointA andPointB:(CGPoint) pointB;

// Other Helper Methods
- (NSDictionary *) reducePointsKey;

@end

@implementation TCShapeController{
    
    // Array Data
    NSMutableArray *listPoints;     // All the points touched
    NSMutableArray *pointKeyArray;  // All the key points calculated from listPoints
    
    // Cartesian values max, min
    CGPoint maxX, maxY;
    CGPoint minX, minY;
    
    // States
    NSInteger isDeltaXPos;
    NSInteger isDeltaYPos;
    
}

#define limitDistace 2.99
#define ovaltoleracetypeA 0.4
#define ovaltoleracetypeB 0.4
#define toleranceRect 0.16
#define rotateRectangleAngleTolerance 10.0


@synthesize recentlyReducedKeyPoints;

#pragma mark - Management Operations

-(id) init{
    if(self = [super init]){
        // Init all the data and set ready them
        maxX = CGPointZero;
        maxY = CGPointZero;
        minX = CGPointMake(10000, 10000);
        minY = CGPointMake(10000, 10000);
        
        // Create new point list
        listPoints = [[NSMutableArray alloc]init];
        pointKeyArray = [[NSMutableArray alloc]init];
        
        isDeltaXPos = 0;
        isDeltaYPos = 0;
    }
    return self;
}

-(BOOL) hasPointData{
    return [listPoints count] >= 5;
}

- (SYShape*) getFigurePaintedWithTolerance:(CGFloat)toleranceValue andContinuity:(CGFloat)continuityValue forceOpen:(BOOL)forceOpen{
    // If it doesn't draw, just touch, exit
    if ([listPoints count] < 5)
        return nil;
    
    // Is the painted shape closed (almost closed)?
    // --------------------------------------------------------------------------
    // Get radius to reduce point cloud
    CGFloat maxDeltaX = maxX.x - minX.x;
    CGFloat maxDeltaY = maxY.y - minY.y;
    
    CGFloat deltaX = [[listPoints objectAtIndex:0]CGPointValue].x - [[listPoints lastObject]CGPointValue].x;
    CGFloat deltaY = [[listPoints objectAtIndex:0]CGPointValue].y - [[listPoints lastObject]CGPointValue].y;
    CGFloat delta = sqrtf(powf(maxDeltaX, 2) + powf(maxDeltaY, 2));
    if (delta < 5.0)
        return nil;
    CGFloat ratioDistanceX = deltaX / maxDeltaX;
    CGFloat ratioDistanceY = deltaY / maxDeltaY;
    
    
    SYShape* possibleShape = nil;
    // It's open, do nothing, exit
    if (fabs(ratioDistanceX) > 0.22 || fabs(ratioDistanceY) > 0.22 || forceOpen)
        possibleShape = [self buildShapeClose:NO withTolerance:toleranceValue andContinuity:continuityValue];
    else {
        // If the resulting points number is insufficient, exit
        if ([pointKeyArray count] <= 2)
            return nil;
        
        possibleShape = [self buildShapeClose:YES withTolerance:toleranceValue andContinuity:continuityValue];
    }
    
    return possibleShape;
    
}// getFigurePaintedWithTolerance


- (SYShape*) buildShapeClose:(BOOL) isCloseShape withTolerance:(CGFloat)toleranceValue andContinuity:(CGFloat)continuityValue
{
    // Reduce Points
    // --------------------------------------------------------------------------
    NSDictionary *dataDict = [self reducePointsKey];
    NSMutableArray *pointsToFit = [dataDict valueForKey:@"pointsToFit"];            // Points to follow replacing keypoints for the final key points
    NSMutableArray *indexKeyPoints = [dataDict valueForKey:@"indexKeyPoints"];      // Index for all key points
    
    // Is a rotate rectangle?
    if ([self isRotateRectangle]) {
        SYShape *shape = [[SYShape alloc] init];
        
        // Get the four segments
        NSUInteger indexA = [[indexKeyPoints objectAtIndex:0]integerValue];
        CGPoint keyPointA = [[pointsToFit objectAtIndex:indexA]CGPointValue];
        NSUInteger indexB = [[indexKeyPoints objectAtIndex:1]integerValue];
        CGPoint keyPointB = [[pointsToFit objectAtIndex:indexB]CGPointValue];
        NSUInteger indexC = [[indexKeyPoints objectAtIndex:2]integerValue];
        CGPoint keyPointC = [[pointsToFit objectAtIndex:indexC]CGPointValue];
        NSUInteger indexD = [[indexKeyPoints objectAtIndex:3]integerValue];
        CGPoint keyPointD = [[pointsToFit objectAtIndex:indexD]CGPointValue];
        
        [shape addRotateRectangle:[NSArray arrayWithObjects:[NSValue valueWithCGPoint:keyPointA],
                                   [NSValue valueWithCGPoint:keyPointB],
                                   [NSValue valueWithCGPoint:keyPointC],
                                   [NSValue valueWithCGPoint:keyPointD],
                                   nil]];
        // Add shape to the canvas
        return shape;
    }
    // If it's a rectangle 0 or 90º
    else if ([self isRectangle] && [indexKeyPoints count] == 5) {
        SYShape *shape = [[SYShape alloc] init];
        [shape addRectangle:CGRectMake(minX.x, minY.y, maxX.x - minX.x, maxY.y - minY.y)];
        
        return shape;
    }
    
    // We have the correct keypoints now and its index into a points list.
    // We can start to study the stretch between key points (line or curve)
    SYShape *shape = [[SYShape alloc]initWithBezierTolerance:toleranceValue];
    [shape setIsClosedCurve:isCloseShape];
    BOOL needsCheckOval = YES;
    
    for (NSUInteger i = 1; i < [indexKeyPoints count]; i++) {
        // Build stretch
        NSUInteger fromIndex = [[indexKeyPoints objectAtIndex:i-1]integerValue];
        NSUInteger toIndex = [[indexKeyPoints objectAtIndex:i]integerValue];
        
        CGPoint firstPoint = [[pointsToFit objectAtIndex:fromIndex]CGPointValue];
        CGPoint lastPoint = [[pointsToFit objectAtIndex:toIndex]CGPointValue];
        
        // Get the points for that stretch
        if (fromIndex > toIndex) {
            // can't find a shape
            return nil;
        }
        NSRange theRange = NSMakeRange(fromIndex, toIndex - fromIndex + 1);
        NSArray *stretch = [pointsToFit subarrayWithRange:theRange];
        
        // If there are only 4 points,
        // it's possible that the estimation won't be right
        if ([stretch count] < 4) {
            SYSegment *segment = [[SYSegment alloc]initWithPoint:firstPoint andPoint:lastPoint];
            [shape addPolygonalFromSegment:segment];
        }
        else {
            
            // Line. Errors if we use a line to fit
            // ---------------------------------------------------------
            // Line between the first and the last point in that stretch
            SYSegment *segment = [[SYSegment alloc]initWithPoint:firstPoint andPoint:lastPoint];
            
            // Deviation ratio and Max curvature
            CGFloat sumDistance = .0; CGFloat maxCurvature = .0; CGFloat longitude = .0;
            for (NSUInteger j = fromIndex+1; j < toIndex; j++) {
                CGPoint aPoint = [[pointsToFit objectAtIndex:j]CGPointValue];
                sumDistance += [segment distanceToPoint:aPoint];
                
                // Study curvature
                SYSegment *fromStartToStudyPoint = [[SYSegment alloc]initWithPoint:firstPoint andPoint:aPoint];
                SYSegment *fromStudyPointToEnd = [[SYSegment alloc]initWithPoint:aPoint andPoint:lastPoint];
                
                CGFloat longitudeToStart = [fromStartToStudyPoint longitude];
                CGFloat longitudeToEnd = [fromStudyPointToEnd longitude];
                
                CGFloat minumumLongitude = [segment longitude] * 0.25;
                if (maxCurvature < [segment distanceToPoint:aPoint] && longitudeToStart > minumumLongitude && longitudeToEnd > minumumLongitude)
                    maxCurvature = [segment distanceToPoint:aPoint];
                
                CGPoint previousPoint = [[pointsToFit objectAtIndex:j-1]CGPointValue];
                SYSegment *segmentCalculateLongitude = [[SYSegment alloc]initWithPoint:previousPoint andPoint:aPoint];
                longitude += [segmentCalculateLongitude longitude];
            }
            
            CGFloat ratioTotalCurvature = sumDistance / longitude;
            
            
            // Bezier
            // ---------------------------------------------------------
            SYBezierController *bezierController = [[SYBezierController alloc]init];
            NSArray *result = [bezierController buildBestBezierForListPoint:stretch tolerance:toleranceValue/*bezierTolerance*/];
            
            // Is line or curve? (Are aligned the control points?)
            SYBezier *bezier = [result objectAtIndex:0];
            CGPoint controlPoint1 = bezier.cPointA;
            CGPoint controlPoint2 = bezier.cPointB;
            CGFloat bezierRatioError = bezier.errorRatio;
            CGFloat alignedCPRatio = (([segment distanceToPoint:controlPoint1]/[segment longitude]) + ([segment distanceToPoint:controlPoint2]/[segment longitude])) * 0.5;
            
            // Estimate curve or line reading the parameters calculated
            // If the bezier is fit to the shape well...
            if (longitude > 65.0) {
                if (maxCurvature < 6.3) {
                    [shape addPolygonalFromSegment:segment];
                    if (longitude > 110.0)
                        needsCheckOval = NO;    // it isn't an oval
                }
                else
                    [shape addCurvesForListPoints:stretch];
            }
            else if (bezierRatioError < 0.29) {
                if (alignedCPRatio < 0.035) {
                    needsCheckOval = NO;    // it isn't an oval
                    [shape addPolygonalFromSegment:segment];
                }
                else if (alignedCPRatio > 0.18)
                    [shape addCurvesForListPoints:stretch];
                else if (ratioTotalCurvature < 1.0)
                    [shape addPolygonalFromSegment:segment];
                else
                    [shape addCurvesForListPoints:stretch];
                
            }
            else if (ratioTotalCurvature < 2.1) {
                needsCheckOval = NO;    // it isn't an oval
                [shape addPolygonalFromSegment:segment];
            }
            else
                [shape addCurvesForListPoints:stretch];
            
        }
    }
    
    // Try to fit with a oval
    if (isCloseShape && needsCheckOval) {
        SYShape* possibleOval = [self buildOvalCircleWithTolerance:toleranceValue];
        if(possibleOval){
            return possibleOval;
        }
    }
    
    // Just snap
    //    if ([self isRectangle])
    //        [shape snapLinesAngles];
    
    // It's closed (almost closed), do closed perfectly
    if (isCloseShape)
        [shape closeShapeIfPossible];
    
    // Force continuity modifying the control points
    [shape forceContinuity:continuityValue];
    
    // Add shape to the canvas
    return shape;
    
}// buildShapeClose:


#pragma mark - Analyze Shape

- (BOOL) isRectangle
{
    return NO;
//    // Reduce Points
//    // --------------------------------------------------------------------------
//    NSDictionary *dataDict = [self reducePointsKey];
//    NSMutableArray *pointsToFit = [dataDict valueForKey:@"pointsToFit"];            // Points to follow replacing keypoints for the final key points
//    NSMutableArray *indexKeyPoints = [dataDict valueForKey:@"indexKeyPoints"];      // Index for all key points
//    
//    for (NSUInteger i = 0; i < [indexKeyPoints count]; i++) {
//        // Build stretch
//        NSUInteger index = [[indexKeyPoints objectAtIndex:i]integerValue];
//        CGPoint keyPoint = [[pointsToFit objectAtIndex:index]CGPointValue];
//        
//        // Check Rectangle 0 or 90 degree
//        float testXA = fabs((keyPoint.x - minX.x)/(maxX.x - minX.x));
//        float testYA = fabs((keyPoint.y - minY.y)/(maxY.y - minY.y));
//        
//        if (!(testXA < toleranceRect || testXA > 1-toleranceRect))
//            return NO;
//        if (!(testYA < toleranceRect || testYA > 1-toleranceRect))
//            return NO;
//    }
//    
//    return YES;
    
}// isRectangle


- (BOOL) isRotateRectangle
{
    return NO;
//    // Reduce Points
//    // --------------------------------------------------------------------------
//    NSDictionary *dataDict = [self reducePointsKey];
//    NSMutableArray *pointsToFit = [dataDict valueForKey:@"pointsToFit"];            // Points to follow replacing keypoints for the final key points
//    NSMutableArray *indexKeyPoints = [dataDict valueForKey:@"indexKeyPoints"];      // Index for all key points
//    if ([indexKeyPoints count] != 5)
//        return NO;
//    
//    // Get the four segments
//    NSUInteger indexA = [[indexKeyPoints objectAtIndex:0]integerValue];
//    CGPoint keyPointA = [[pointsToFit objectAtIndex:indexA]CGPointValue];
//    NSUInteger indexB = [[indexKeyPoints objectAtIndex:1]integerValue];
//    CGPoint keyPointB = [[pointsToFit objectAtIndex:indexB]CGPointValue];
//    NSUInteger indexC = [[indexKeyPoints objectAtIndex:2]integerValue];
//    CGPoint keyPointC = [[pointsToFit objectAtIndex:indexC]CGPointValue];
//    NSUInteger indexD = [[indexKeyPoints objectAtIndex:3]integerValue];
//    CGPoint keyPointD = [[pointsToFit objectAtIndex:indexD]CGPointValue];
//    NSUInteger indexE = [[indexKeyPoints objectAtIndex:4]integerValue];
//    CGPoint keyPointE = [[pointsToFit objectAtIndex:indexE]CGPointValue];
//    
//    SYSegment *segmentAB = [[SYSegment alloc]initWithPoint:keyPointA andPoint:keyPointB];
//    SYSegment *segmentBC = [[SYSegment alloc]initWithPoint:keyPointB andPoint:keyPointC];
//    SYSegment *segmentCD = [[SYSegment alloc]initWithPoint:keyPointC andPoint:keyPointD];
//    SYSegment *segmentDE = [[SYSegment alloc]initWithPoint:keyPointD andPoint:keyPointE];
//    
//    CGFloat angleAB = [segmentAB angleDeg];
//    if (angleAB > 180.0)
//        angleAB -=180.0;
//    CGFloat angleBC = [segmentBC angleDeg];
//    if (angleBC > 180.0)
//        angleBC -=180.0;
//    CGFloat angleCD = [segmentCD angleDeg];
//    if (angleCD > 180.0)
//        angleCD -=180.0;
//    CGFloat angleDE = [segmentDE angleDeg];
//    if (angleDE > 180.0)
//        angleDE -=180.0;
//    
//    // Are the segments parallels?
//    if (fabs(angleAB - angleCD) > rotateRectangleAngleTolerance ||
//        fabs(angleBC - angleDE) > rotateRectangleAngleTolerance) {
//        return NO;
//    }
//    
//    // Are the angles in segment contiguous between 85/95 degrees?
//    if (angleAB > angleBC) {
//        if (fabs(angleAB - angleCD) > 90.0 + rotateRectangleAngleTolerance) {   return NO;  }
//    }
//    else {
//        if (fabs(angleBC - angleAB) > 90.0 + rotateRectangleAngleTolerance) {   return NO;  }
//    }
//    
//    if (angleCD > angleDE) {
//        if (fabs(angleCD - angleDE) > 90.0 + rotateRectangleAngleTolerance) {   return NO;  }
//    }
//    else {
//        if (fabs(angleDE - angleCD) > 90.0 + rotateRectangleAngleTolerance) {   return NO;  }
//    }
//    
//    // Angles correct, It's a rectangle
//    return YES;
    
}// isRotateRectangle


- (SYShape*) buildOvalCircleWithTolerance:(CGFloat)toleranceValue
{
    // Get oval axis
    CGFloat axisDistance = .0;
    SYSegment *bigAxisSegment = nil;
    for (NSValue *pointValue in listPoints) {
        
        CGPoint pointA = [pointValue CGPointValue];
        
        for (int i = 0 ; i < [listPoints count] ; i++) {
            CGPoint pointB = [[listPoints objectAtIndex:i]CGPointValue];
            SYSegment *possibleAxis = [[SYSegment alloc]initWithPoint:pointA andPoint:pointB];
            
            if (axisDistance < [possibleAxis longitude]) {
                bigAxisSegment = possibleAxis;
                axisDistance = [possibleAxis longitude];
            }
            
        }
    }
    
    // Is it an horizontal or vertical oval?
    CGPoint center = [bigAxisSegment midPoint];
    float deltaAngle = fabs([bigAxisSegment angleDeg]) - 90.0;
    
    if (fabs([bigAxisSegment angleDeg]) < 10.0 || fabs(deltaAngle) < 10.0) {
        // Get the points Max, Min for create the CGRect
        minX = [[listPoints objectAtIndex:0]CGPointValue];
        maxX = [[listPoints objectAtIndex:0]CGPointValue];
        minY = [[listPoints objectAtIndex:0]CGPointValue];
        maxY = [[listPoints objectAtIndex:0]CGPointValue];
        
        for (NSValue *pointValue in listPoints) {
            CGPoint point = [pointValue CGPointValue];
            
            if (point.x > maxX.x)
                maxX = point;
            if (point.y > maxY.y)
                maxY = point;
            if (point.x < minX.x)
                minX = point;
            if (point.y < minY.y)
                minY = point;
        }
        CGRect ovalRect = CGRectMake( minX.x, minY.y, (maxX.x - minX.x), (maxY.y - minY.y));
        
        // Build the Oval
        CGFloat smallAxisDistance = .0;
        CGFloat bigAxisDistance = .0;
        if (fabs(deltaAngle) < 10.0) {
            smallAxisDistance = maxX.x - minX.x;
            bigAxisDistance = maxY.y - minY.y;
        }
        else {
            bigAxisDistance = maxX.x - minX.x;
            smallAxisDistance = maxY.y - minY.y;
        }
        
        // And Check error
        CGFloat error = .0;
        CGFloat a = bigAxisDistance * 0.5;
        CGFloat b = smallAxisDistance * 0.5;
        if (fabs([bigAxisSegment angleDeg]) > 45.0) {
            b = bigAxisDistance * 0.5;
            a = smallAxisDistance * 0.5;
        }
        
        for (NSValue *pointValue in listPoints) {
            CGPoint pointOrig = [pointValue CGPointValue];
            // Cambio de sistema de coordenadas (translacion)
            CGPoint point = CGPointMake(pointOrig.x - center.x, pointOrig.y - center.y);
            
            // Error usando formular elemental de elipse: x2/a2 + y2/b2 = 1
            CGFloat errorTemp = (pow(point.x, 2)/pow(a, 2)) + (pow(point.y, 2)/pow(b, 2));
            CGFloat finalError = fabs(1 - errorTemp);
            if (finalError > error)
                error = finalError;
        }
        
        NSLog(@"ErrorA: %f <? %f == oval at 90deg to screen", error, ovaltoleracetypeA);
        // If the error is higher than tolerance, It isn't a oval
        if (error > ovaltoleracetypeA){
            // nope, let's see if a slightly
            // offset oval is better...
        }else{
            // It's a oval and add to the shape list
            SYShape *shape = [[SYShape alloc]initWithBezierTolerance:toleranceValue];
            shape.isClosedCurve = YES;
            [shape addCircle:ovalRect];
            
            return shape;
        }
    }
    
    // Looking for the small axis
    SYSegment *smallAxisSegment = nil; CGFloat angleMax = 10000.0;
    
    CGFloat avgDistance = 0;
    for (NSValue *pointValue in listPoints) {
        CGPoint pointB = [pointValue CGPointValue];
        SYSegment *possibleAxis = [[SYSegment alloc]initWithPoint:center andPoint:pointB];
        
        // Busca aquel segmento que más se acerque a 90º
        // con respecto al eje mayor.
        float deltaAngle = fabs([bigAxisSegment angleDeg] - [possibleAxis angleDeg]);
        float angle = fabs(deltaAngle - 90.0);
        
        if (angle < angleMax) {
            smallAxisSegment = possibleAxis;
            angleMax = angle;
        }
        
        avgDistance += abs([bigAxisSegment distanceToPoint:pointB] / (float)[listPoints count]);
    }
    NSLog(@"average distance from large axis: %f", avgDistance);
    
    SYVector* vector = [SYVector vectorWithPoint:bigAxisSegment.startPoint andPoint:bigAxisSegment.endPoint];
    vector = [[vector perpendicular] normal];
    
    smallAxisSegment = [[SYSegment alloc] initWithPoint:[vector pointFromPoint:bigAxisSegment.midPoint distance:-avgDistance*2]
                                               andPoint:[vector pointFromPoint:bigAxisSegment.midPoint distance:avgDistance*2]];

    NSLog(@"angle of large axis: %f", [bigAxisSegment angleDeg]);
    NSLog(@"angle of small axis: %f", [smallAxisSegment angleDeg]);
    

    
    // Maybe it's almost a circle
    float bigAxisLongitude = [bigAxisSegment longitude];
    float smallAxisLongitude = [smallAxisSegment longitude];
    
    if (smallAxisLongitude/bigAxisLongitude > 0.80) {
        
        // Get the points Max, Min for create the CGRect
        minX = [bigAxisSegment pointSt];
        maxX = [bigAxisSegment pointFn];
        minY = [[listPoints objectAtIndex:0]CGPointValue];
        maxY = [[listPoints objectAtIndex:0]CGPointValue];
        
        // PROBAR SI ES UN OVALO O NO
        CGFloat error = .0;
        CGFloat a = bigAxisLongitude * 0.5;
        CGFloat b = smallAxisLongitude * 0.5;
        
        for (NSValue *pointValue in listPoints) {
            CGPoint pointOrig = [pointValue CGPointValue];
            // Cambio de sistema de coordenadas (translacion)
            CGPoint point = CGPointMake(pointOrig.x - center.x, pointOrig.y - center.y);
            
            CGFloat denominator = sqrt(pow(b * point.x, 2) + pow(a * point.y, 2));
            CGFloat x = (a * b * point.x)/denominator;
            CGFloat y = (a * b * point.y)/denominator;
            
            CGFloat distance = sqrt(pow(point.x - x, 2) + pow(point.y - y, 2));
            if (distance > error)
                error = distance;
            
        }
        
        // It isn't a circle
        NSLog(@"error %f <? 30.0 == oval", error);
        if (error > 30.0) {
            // nope, so let's see if we can get an
            // oval of any direction
        }else{
            // It's a circle and add to the shape list
            SYShape *shape = [[SYShape alloc]initWithBezierTolerance:toleranceValue];
            shape.isClosedCurve = YES;
            [shape addArc:CGPointMake(center.x, center.y)
                   radius:bigAxisLongitude*0.5
               startAngle:0.0
                 endAngle:2*M_PI
                clockwise:YES];
            
            return shape;
        }
    }
    
    // Get max and min XY
    SYSegment *newSegment = [[SYSegment alloc]initWithPoint:[bigAxisSegment pointSt] andPoint:[bigAxisSegment pointFn]];
    [newSegment setMiddlePointToDegree:90.0];
    minY = [newSegment pointSt];
    maxY = [newSegment pointFn];
    minX = CGPointMake([newSegment midPoint].x - smallAxisLongitude * 0.5, [newSegment midPoint].y);
    maxX = CGPointMake([newSegment midPoint].x + smallAxisLongitude * 0.5, [newSegment midPoint].y);
    
    // Transform, rotate a around the midpoint
    float angleRad = M_PI_2 - [bigAxisSegment angleRad];
    CGPoint pivotalPoint = CGPointMake([bigAxisSegment midPoint].x, [bigAxisSegment midPoint].y);
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(.0, -(maxY.y - minY.y)));
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(-pivotalPoint.x, -pivotalPoint.y));
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeRotation(angleRad));
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(pivotalPoint.x, pivotalPoint.y));
    
    // Test if it's an oval or not
    CGFloat error = .0;
    
    CGFloat a = [bigAxisSegment longitude] * 0.5;
    CGFloat b = [smallAxisSegment longitude] * 0.5;
    
    NSLog(@"big axis: %f", [bigAxisSegment longitude]);
    NSLog(@"small axis: %f", [smallAxisSegment longitude]);
    
    for (NSValue *pointValue in listPoints) {
        
        CGPoint pointOrig = [pointValue CGPointValue];
        
        // Project point over the axis
        SYSegment *lineToPoint = [[SYSegment alloc]initWithPoint:center andPoint:pointOrig];
        CGFloat projBigAxis = cosf([lineToPoint angleRad]-[bigAxisSegment angleRad]);
        CGFloat projSmallAxis = sinf([lineToPoint angleRad]-[bigAxisSegment angleRad]);
        
        CGFloat errorTemp = sqrt(1/(pow(projBigAxis / a, 2) + pow(projSmallAxis / b, 2)));
        
//        NSLog(@"theta: %f", [lineToPoint angleRad]-[smallAxisSegment angleRad]);
//        NSLog(@"dist to point: %f  dist to oval: %f   percErr: %f", [lineToPoint longitude], errorTemp, [lineToPoint longitude] / errorTemp);
        
        CGFloat errorPercent = [lineToPoint longitude] / errorTemp;
        
        CGFloat finalError = fabs(1 - errorPercent);
        if (finalError > error)
            error = finalError;
    }
    
    NSLog(@"ErrorB: %f <? %f == oval", error, ovaltoleracetypeB);
    if (error > ovaltoleracetypeB) {
        return nil;
    }
    
    // Create arc
    SYShape *shape = [[SYShape alloc]initWithBezierTolerance:toleranceValue];
    shape.isClosedCurve = YES;
    [shape addCircleWithRect:CGRectMake(minX.x, maxY.y, (maxX.x - minX.x), (maxY.y - minY.y))
                andTransform:transform];
    
    return shape;
    
}// drawOvalCirclePainted



- (CGFloat) getTotalLongitude
{
    CGFloat totalLongitude = .0;
    
    for (NSUInteger i = 1 ; i < [listPoints count] ; i++) {
        CGPoint pointStart = [[listPoints objectAtIndex:i-1]CGPointValue];
        CGPoint pointEnd = [[listPoints objectAtIndex:i]CGPointValue];
        
        SYSegment *segment = [[SYSegment alloc]initWithPoint:pointStart andPoint:pointEnd];
        totalLongitude += [segment longitude];
    }
    
    return totalLongitude;
    
}// getTotalLongitude

#pragma mark - Cloud Points Methods

- (void) addPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;
{
    // Add points
    NSValue *pointAValue = [NSValue valueWithCGPoint:pointA];
    NSValue *pointBValue = [NSValue valueWithCGPoint:pointB];
    if (![[listPoints lastObject]isEqualToValue:pointAValue]) {
        [listPoints addObject:pointAValue];
        
        // Get Max/Min
        if (pointA.x > maxX.x)
            maxX = pointA;
        if (pointA.x < minX.x)
            minX = pointA;
        if (pointA.y > maxY.y)
            maxY = pointA;
        if (pointA.y < minY.y)
            minY = pointA;
    }
    
    if (![[listPoints lastObject]isEqualToValue:pointBValue]) {
        [listPoints addObject:pointBValue];
        
        // Get Max/Min
        if (pointB.x > maxX.x)
            maxX = pointB;
        if (pointB.x < minX.x)
            minX = pointB;
        if (pointB.y > maxY.y)
            maxY = pointB;
        if (pointB.y < minY.y)
            minY = pointB;
    }
    
    // Calculate keyPoints
    if ([listPoints count] > 3) {
        CGFloat deltaXF = pointB.x - pointA.x;
        CGFloat deltaYF = pointB.y - pointA.y;
        
        // VARIACION X SEGUN CAMBIOS DE DIRECCION
        if (isDeltaXPos == 0) {
            if (deltaXF > limitDistace) {
                isDeltaXPos = 1;
                return;
            }
            else if (deltaXF < -limitDistace) {
                isDeltaXPos = -1;
                return;
            }
            
            if (deltaXF > limitDistace) {
                isDeltaXPos = 1;
                return;
            }
            else if (deltaXF < -limitDistace) {
                isDeltaXPos = -1;
                return;
            }
        }
        else {
            if (deltaXF > limitDistace && isDeltaXPos == -1) {
                if (![[pointKeyArray lastObject]isEqual:[NSValue valueWithCGPoint:pointA]])
                    [pointKeyArray addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaXPos = 1;
                return;
            }
            else if (deltaXF < -limitDistace && isDeltaXPos == 1) {
                if (![[pointKeyArray lastObject]isEqual:[NSValue valueWithCGPoint:pointA]])
                    [pointKeyArray addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaXPos = -1;
                return;
            }
            
            if (deltaXF > limitDistace && isDeltaXPos == -1) {
                if (![[pointKeyArray lastObject]isEqual:[NSValue valueWithCGPoint:pointA]])
                    [pointKeyArray addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaXPos = 1;
                return;
            }
            else if (deltaXF < -limitDistace && isDeltaXPos == 1) {
                if (![[pointKeyArray lastObject]isEqual:[NSValue valueWithCGPoint:pointA]])
                    [pointKeyArray addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaXPos = -1;
                return;
            }
        }
        
        // Variacion Y
        if (isDeltaYPos == 0) {
            if (deltaYF > limitDistace) {
                isDeltaYPos = 1;
                return;
            }
            else if (deltaYF < -limitDistace) {
                isDeltaYPos = -1;
                return;
            }
            
            if (deltaYF > limitDistace) {
                isDeltaYPos = 1;
                return;
            }
            else if (deltaYF < -limitDistace) {
                isDeltaYPos = -1;
                return;
            }
        }
        else {
            if (deltaYF > limitDistace && isDeltaYPos == -1) {
                if (![[pointKeyArray lastObject]isEqual:[NSValue valueWithCGPoint:pointA]])
                    [pointKeyArray addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaYPos = 1;
                return;
            }
            else if (deltaYF < -limitDistace && isDeltaYPos == 1) {
                if (![[pointKeyArray lastObject]isEqual:[NSValue valueWithCGPoint:pointA]])
                    [pointKeyArray addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaYPos = -1;
                return;
            }
            
            if (deltaYF > limitDistace && isDeltaYPos == -1) {
                if (![[pointKeyArray lastObject]isEqual:[NSValue valueWithCGPoint:pointA]])
                    [pointKeyArray addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaYPos = 1;
                return;
            }
            else if (deltaYF < -limitDistace && isDeltaYPos == 1) {
                if (![[pointKeyArray lastObject]isEqual:[NSValue valueWithCGPoint:pointA]])
                    [pointKeyArray addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaYPos = -1;
                return;
            }
        }
        
        // ANGLES
        NSValue *vertexValue = [listPoints objectAtIndex:[listPoints count]-3];
        CGFloat angle = [self getAngleBetweenVertex:pointA
                                          andPointA:pointB
                                          andPointB:[vertexValue CGPointValue]];
        
        CGFloat angleDeg = (angle / M_PI_2) * 90.0;
        if (angleDeg < 170.0) {
            // A or B was adding to the pointKeyPoint...
            if ([[pointKeyArray lastObject]isEqual:pointAValue] || [[pointKeyArray lastObject]isEqual:pointBValue]) {
                // we don't need add vertex
            }
            else {
                if (![[pointKeyArray lastObject]isEqual:vertexValue])
                    [pointKeyArray addObject:vertexValue];
            }
        }
    }
    
}// addPoint:andPoint:


- (void) addLastPoint:(CGPoint) lastPoint
{
    // Add the first and the last point to key points
    [listPoints addObject:[NSValue valueWithCGPoint:lastPoint]];
    [pointKeyArray addObject:[NSValue valueWithCGPoint:lastPoint]];
    [pointKeyArray insertObject:[listPoints objectAtIndex:0] atIndex:0];
    
}// addLastPoint:


- (NSDictionary *) reducePointsKey
{
    NSMutableArray *pointsToFit = [NSMutableArray arrayWithArray:listPoints];       // Points to follow replacing keypoints for the final key points
    NSMutableArray *indexKeyPoints = [NSMutableArray array];                        // Index for all key points
    
    // --------------------------------------------------------------------------
    // Reduce Points
    // --------------------------------------------------------------------------
    
    // Get radius to reduce point cloud
    CGFloat maxDeltaX = maxX.x - minX.x;
    CGFloat maxDeltaY = maxY.y - minY.y;
    CGFloat radiusCloud = sqrtf(powf(maxDeltaX, 2) + powf(maxDeltaY, 2)) * 0.038;
    
    // Point cloud simplification algorithm (using radiusCloud)
    NSMutableArray *reducePointKeyArray = [NSMutableArray arrayWithArray:pointKeyArray];
    
    for (int i = 0 ; i < [reducePointKeyArray count] ; i++) {
        id pointID = [reducePointKeyArray objectAtIndex:i];
        
        if ((NSNull *) pointID != [NSNull null]) {
            CGPoint point = [pointID CGPointValue];
            
            // Take the neighbors points for which compose the cloud points
            NSMutableArray *localCloudPoint = [NSMutableArray array];
            [localCloudPoint addObject:pointID];
            
            NSInteger firstIndex = -1;
            
            for (int j = i+1 ; j < [pointKeyArray count] ; j++) {
                
                CGPoint nextPoint = [[pointKeyArray objectAtIndex:j]CGPointValue];
                CGFloat distance = [self distanceBetweenPoint:point andPoint:nextPoint];
                
                if (distance < radiusCloud) {
                    [localCloudPoint addObject:[pointKeyArray objectAtIndex:j]];
                    [reducePointKeyArray replaceObjectAtIndex:j withObject:[NSNull null]];
                    
                    // Take the first index for the cloud points
                    NSUInteger indexToRemove = [pointsToFit indexOfObject:[pointKeyArray objectAtIndex:j]];
                    if (indexToRemove == NSNotFound)
                        NSLog(@"error reducing key points");
                    else {
                        [pointsToFit replaceObjectAtIndex:indexToRemove withObject:[NSNull null]];
                        if (firstIndex == -1)
                            firstIndex = indexToRemove;
                    }
                }
                else
                    break;
            }
            
            if ([localCloudPoint count] > 1) {
                
                NSUInteger indexMidPoint = (NSUInteger)[localCloudPoint count] * 0.5;
                
                // If the point is the first o last point, it will be the point key
                if ([[localCloudPoint objectAtIndex:0]isEqual:[pointsToFit objectAtIndex:0]])
                    indexMidPoint = 0;
                else if ([[localCloudPoint lastObject]isEqual:[pointsToFit lastObject]])
                    indexMidPoint = [localCloudPoint count]-1;
                // else will be the index in the middle
                
                // Replace all the point from the cloud for the mid point
                NSValue *midPoint = [localCloudPoint objectAtIndex:indexMidPoint];
                [reducePointKeyArray replaceObjectAtIndex:i withObject:midPoint];
                
                // Replace the new point into pointsToFit
                if (firstIndex != -1)
                    [pointsToFit replaceObjectAtIndex:firstIndex withObject:midPoint];
            }
        }
    }
    
    // Clean all NSNull
    NSMutableArray *cleanerArray  = [NSMutableArray arrayWithArray:reducePointKeyArray];
    reducePointKeyArray = [NSMutableArray array];
    for (id keyPoint in cleanerArray) {
        if ((NSNull *) keyPoint != [NSNull null])
            [reducePointKeyArray addObject:keyPoint];
    }
    
    // Remove points aligned (step A)
    // --------------------------------------------------------------------------
    NSMutableArray *edgePoints = [NSMutableArray array];
    if ([reducePointKeyArray count] > 0) {
        [edgePoints addObject:[reducePointKeyArray objectAtIndex:0]];
        
        for (int i = 0 ; i+2 < [reducePointKeyArray count] ; i++) {
            
            CGPoint pointKeyA = [[reducePointKeyArray objectAtIndex:i]CGPointValue];
            CGPoint pointKeyB = [[reducePointKeyArray objectAtIndex:i+1]CGPointValue];
            CGPoint pointKeyC = [[reducePointKeyArray objectAtIndex:i+2]CGPointValue];
            
            SYSegment *segment = [[SYSegment alloc]initWithPoint:pointKeyA andPoint:pointKeyC];
            CGFloat longitude = [segment longitude];
            
            if ([segment distanceToPoint:pointKeyB] < longitude * 0.12) {
                [reducePointKeyArray replaceObjectAtIndex:i+1 withObject:[NSNull null]];
                i = i+1;
            }
            
        }
    }
    
    
    // Clean all NSNull
    cleanerArray  = [NSMutableArray arrayWithArray:reducePointKeyArray];
    reducePointKeyArray = [NSMutableArray array];
    for (id keyPoint in cleanerArray) {
        if ((NSNull *) keyPoint != [NSNull null])
            [reducePointKeyArray addObject:keyPoint];
    }
    
    
    // Remove key points if the index into list points between them are < 5
    // --------------------------------------------------------------------------
    // For the first point
    if ([reducePointKeyArray count] > 2) {
        NSValue *pointValueKeyA = [reducePointKeyArray objectAtIndex:0];
        NSValue *pointValueKeyB = [reducePointKeyArray objectAtIndex:1];
        
        NSUInteger indexKeyPointA = [pointsToFit indexOfObject:pointValueKeyA];
        NSUInteger indexKeyPointB = [pointsToFit indexOfObject:pointValueKeyB];
        
        NSUInteger numberOfPoints = indexKeyPointB - indexKeyPointA;
        if (numberOfPoints < 6)
            [reducePointKeyArray removeObject:pointValueKeyB];
    }
    
    // For the others points
    // since [count] is an NSUIntenter, then the
    // right hand side evaluates to max unsigned int,
    // so the left handside is always less than the rhs,
    // if the reducePointKeyArray count is zero
    for (int i = 0 ; (i+2) < (int)([reducePointKeyArray count]-1) ; i++) {
        NSValue *pointValueKeyA = [reducePointKeyArray objectAtIndex:i];
        NSValue *pointValueKeyB = [reducePointKeyArray objectAtIndex:i+1];
        
        NSUInteger indexKeyPointA = [pointsToFit indexOfObject:pointValueKeyA];
        NSUInteger indexKeyPointB = [pointsToFit indexOfObject:pointValueKeyB];
        
        NSUInteger numberOfPoints = indexKeyPointB - indexKeyPointA;
        if (numberOfPoints < 6)
            [reducePointKeyArray removeObject:pointValueKeyB];
    }
    
    
    // Clean all NSNull
    cleanerArray  = [NSMutableArray arrayWithArray:reducePointKeyArray];
    reducePointKeyArray = [NSMutableArray array];
    for (id keyPoint in cleanerArray) {
        if ((NSNull *) keyPoint != [NSNull null])
            [reducePointKeyArray addObject:keyPoint];
    }
    
    // Identify the keypoints indexes
    cleanerArray  = [NSMutableArray arrayWithArray:pointsToFit];
    pointsToFit = [NSMutableArray array];
    for (id keyPoint in cleanerArray) {
        if ((NSNull *) keyPoint != [NSNull null])
            [pointsToFit addObject:keyPoint];
    }
    for (NSValue *keyPoint in reducePointKeyArray) {
        NSUInteger index = [pointsToFit indexOfObject:keyPoint];
        [indexKeyPoints addObject:[NSNumber numberWithInteger:index]];
    }
    
    recentlyReducedKeyPoints = [NSDictionary dictionaryWithObjectsAndKeys:pointsToFit, @"pointsToFit",
            indexKeyPoints, @"indexKeyPoints",
            [NSArray arrayWithArray:listPoints], @"listPoints",
            reducePointKeyArray, @"reducePointKeyArray", nil];
    
    return recentlyReducedKeyPoints;
}// reducePointsKey


#pragma mark - Geometric calculations

- (CGFloat) distanceBetweenPoint:(CGPoint) point1 andPoint:(CGPoint) point2
{
    // Rewrite your TCChartView method ObjC native
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    
    return sqrt(pow(dx,2) + pow(dy,2));
    
}// distanceBetweenPoint:andPoint:


- (CGFloat) getAngleBetweenVertex:(CGPoint) vertex andPointA:(CGPoint) pointA andPointB:(CGPoint) pointB
{
    // Rewrite your TCChartView method ObjC native
    CGFloat P12 = [self distanceBetweenPoint:vertex andPoint:pointA];
    CGFloat P13 = [self distanceBetweenPoint:vertex andPoint:pointB];
    CGFloat P23 = [self distanceBetweenPoint:pointA andPoint:pointB];
    
    CGFloat num = P12 * P12 + P13 * P13 - P23 * P23;
    CGFloat den = 2 * P12 * P13;
    CGFloat total = num / den;
    CGFloat ret = acosf(total);
    
    return ret;
    
}// getAngleBetweenVertex:andPointA:andPointB:




@end
