//
//  TCViewController.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 28/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import "TCViewController.h"
#import "SYVectorView.h"
#import "SYSegment.h"
#import "SYBezier.h"
#import "SYBezierController.h"
#import "SYPaintView.h"
#import "SYSaveMessageView.h"
#import "SYShape.h"

@interface TCViewController () {
    
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

// Calculate Shapes
- (void) buildShapeClose:(BOOL) isCloseShape;

// Analyze Shape
- (BOOL) isRectangle;
- (BOOL) isRotateRectangle;
- (BOOL) drawOvalCirclePainted;

// Geometric calculations
- (CGFloat) distanceBetweenPoint:(CGPoint) point1 andPoint:(CGPoint) point2;
- (CGFloat) getAngleBetweenVertex:(CGPoint) vertex andPointA:(CGPoint) pointA andPointB:(CGPoint) pointB;
- (CGFloat) distanceFrom:(CGPoint) pointTest toLineBuildForPoint:(CGPoint) pointKey andPoint:(CGPoint) pointNextKey;
- (BOOL) point:(CGPoint)pointA andPoint:(CGPoint)pointB isAlignedWithPoint:(CGPoint)pointC;

// Other Helper Methods
- (NSDictionary *) reducePointsKey;

@end


@implementation TCViewController

#define limitDistace 2.99
#define ovaltoleracetypeA 0.4
#define ovaltoleracetypeB 0.73
#define toleranceRect 0.16
#define bezierTolerance 0.01
#define rotateRectangleAngleTolerance 10.0

#pragma mark - Lifecycle Methods

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Hide table
    [tableBase setAlpha:.0];
    [tableBase setHidden:YES];
    
}// viewDidLoad


- (void) viewDidUnload
{
    [super viewDidUnload];
    
    [paintView release];
    paintView = nil;
    
    [vectorView release];
    vectorView = nil;
    
}// viewDidUnload


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    
}// shouldAutorotateToInterfaceOrientation:


- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{    
    [selectCaseNameView setAlpha:.0];
    [vectorView setNeedsDisplay];
    
}// willRotateToInterfaceOrientation:duration:


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    
    // Set message view position
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        [selectCaseNameView setFrame:CGRectMake(240.0, 382.0, selectCaseNameView.frame.size.width, selectCaseNameView.frame.size.height)];
    else
        [selectCaseNameView setFrame:CGRectMake(369.0, 217.0, selectCaseNameView.frame.size.width, selectCaseNameView.frame.size.height)];
    
    [selectCaseNameView setNeedsDisplay];
    
    [UIView animateWithDuration:0.3 animations:^{
        [selectCaseNameView setAlpha:1.0];
    }];
    
}// didRotateFromInterfaceOrientation:


- (void) dealloc
{
    [super dealloc];
    
    [paintView release];
    [vectorView release];
    
}// dealloc



#pragma mark - Unit Test Methods

- (IBAction) selectName:(id)sender
{
    if ([listPoints count] < 5) {
        // Avisa del error obtenido
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Draw Something"
                                                        message:@"You must draw a valid shape before"
                                                       delegate:self
                                              cancelButtonTitle:@"Accept"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    // Set message view position
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        [selectCaseNameView setFrame:CGRectMake(240.0, 382.0, selectCaseNameView.frame.size.width, selectCaseNameView.frame.size.height)];
    else
        [selectCaseNameView setFrame:CGRectMake(369.0, 217.0, selectCaseNameView.frame.size.width, selectCaseNameView.frame.size.height)];
    
    
    [nameTextField becomeFirstResponder];
    [selectCaseNameView setAlpha:.0];
    [selectCaseNameView setHidden:NO];
    [UIView animateWithDuration:0.4 animations:^{
        [selectCaseNameView setAlpha:1.0];
    }];
    
}// selectName:


- (IBAction) saveCase:(id)sender
{
    // If the user doesn't write name
    if ([[nameTextField text]length] == 0 || [listPoints count] < 5)
        return;
    
    // Store new case
    [nameTextField resignFirstResponder];
    [UIView animateWithDuration:0.4 animations:^{
        [selectCaseNameView setAlpha:.0];
    }completion:^(BOOL finished){
        [selectCaseNameView setHidden:YES];
        nameTextField.text = @"";
    }];
    
    // Send notification to Test controller
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:paintView.allPoints, @"allPoints", nameTextField.text, @"name", nil];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"saveListPoints" object:self userInfo:d];
        
}// saveCase:


- (IBAction) cancelCase:(id)sender
{
    [nameTextField resignFirstResponder];
    [UIView animateWithDuration:0.4 animations:^{
        [selectCaseNameView setAlpha:.0];
    }completion:^(BOOL finished){
        [selectCaseNameView setHidden:YES];
    }];
    
}// cancelCase


#pragma mark - Unit Test Operations

- (void) importCase:(NSArray *) allPoints
{
    // Clear Paint
    [paintView clearPaint];
    
    // Init Data
    [self resetData];
    
    for (NSUInteger i = 1 ; i < [allPoints count]-1 ; i++) {
        // Add these new points
        CGPoint touchPreviousLocation = [[allPoints objectAtIndex:i-1]CGPointValue];
        CGPoint touchLocation = [[allPoints objectAtIndex:i]CGPointValue];
        [self addPoint:touchPreviousLocation andPoint:touchLocation];
    }
    
    CGPoint touchLocation = [[allPoints lastObject]CGPointValue];
    [self addLastPoint:touchLocation];
    
    // Analyze a recognize the figure
    [self getFigurePainted];
    
}// importCase


#pragma mark - Management Operations

- (void) resetData
{
    // Init all the data and set ready them
    maxX = CGPointZero;
    maxY = CGPointZero;
    minX = CGPointMake(10000, 10000);
    minY = CGPointMake(10000, 10000);
    
    // Create new point list
    [listPoints release];
    [pointKeyArray release];
    listPoints = [[NSMutableArray alloc]init];
    pointKeyArray = [[NSMutableArray alloc]init];
    
    isDeltaXPos = 0;
    isDeltaYPos = 0;
    
}// resetData


#pragma mark - Calculate Shapes

- (IBAction) rebuildShape:(id)sender
{
    continuityLabel.text = [NSString stringWithFormat:@"%4.2f",[continuitySlider value]];
    toleranceLabel.text = [NSString stringWithFormat:@"%4.6f",[toleranceSlider value]*0.0001];
    
    [vectorView.shapeList removeLastObject];
    [self getFigurePainted];
    
}// rebuildShape


- (void) getFigurePainted
{
    // If it doesn't draw, just touch, exit
    if ([listPoints count] < 5)
        return;
    
    // Is the painted shape closed (almost closed)?
    // --------------------------------------------------------------------------
    // Get radius to reduce point cloud
    CGFloat maxDeltaX = maxX.x - minX.x;
    CGFloat maxDeltaY = maxY.y - minY.y;
    
    CGFloat deltaX = [[listPoints objectAtIndex:0]CGPointValue].x - [[listPoints lastObject]CGPointValue].x;
    CGFloat deltaY = [[listPoints objectAtIndex:0]CGPointValue].y - [[listPoints lastObject]CGPointValue].y;
    CGFloat delta = sqrtf(powf(maxDeltaX, 2) + powf(maxDeltaY, 2));
    if (delta < 5.0)
        return;
    CGFloat ratioDistanceX = deltaX / maxDeltaX;
    CGFloat ratioDistanceY = deltaY / maxDeltaY;
        
    // It's open, do nothing, exit
    if (fabs(ratioDistanceX) > 0.22 || fabs(ratioDistanceY) > 0.22)
        [self buildShapeClose:NO];
    else {
        // If the resulting points number is insufficient, exit
        if ([pointKeyArray count] < 2)
            return;
        
        [self buildShapeClose:YES];
    }

    [vectorView setNeedsDisplay];
    
}// getFigurePainted


- (void) buildShapeClose:(BOOL) isCloseShape
{
    // Reduce Points
    // --------------------------------------------------------------------------
    NSDictionary *dataDict = [self reducePointsKey];
    NSMutableArray *pointsToFit = [dataDict valueForKey:@"pointsToFit"];            // Points to follow replacing keypoints for the final key points
    NSMutableArray *indexKeyPoints = [dataDict valueForKey:@"indexKeyPoints"];      // Index for all key points
    
    // Is a rotate rectangle?
    if ([self isRotateRectangle]) {
        SYShape *shape = [[SYShape alloc]initWithBezierTolerance:[toleranceSlider value]*0.0001];
        
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
        [vectorView addShape:shape];
        
        [shape release];
        return;
    }
    // If it's a rectangle 0 or 90º
    else if ([self isRectangle] && [indexKeyPoints count] == 5) {
        SYShape *shape = [[SYShape alloc]initWithBezierTolerance:[toleranceSlider value]*0.0001];
        [shape addRectangle:CGRectMake(minX.x, minY.y, maxX.x - minX.x, maxY.y - minY.y)];
        
        // Add shape to the canvas
        [vectorView addShape:shape];
        
        [shape release];
        return;
    }
    
    // We have the correct keypoints now and its index into a points list.
    // We can start to study the stretch between key points (line or curve)
    SYShape *shape = [[SYShape alloc]initWithBezierTolerance:[toleranceSlider value]*0.0001];
    [shape setCloseCurve:isCloseShape];
    BOOL needsCheckOval = YES;
    
    for (NSUInteger i = 1; i < [indexKeyPoints count]; i++) {
        // Build stretch
        NSUInteger fromIndex = [[indexKeyPoints objectAtIndex:i-1]integerValue];
        NSUInteger toIndex = [[indexKeyPoints objectAtIndex:i]integerValue];
        
        CGPoint firstPoint = [[pointsToFit objectAtIndex:fromIndex]CGPointValue];
        CGPoint lastPoint = [[pointsToFit objectAtIndex:toIndex]CGPointValue];
        
        // Get the points for that stretch
        if (fromIndex > toIndex) { return; }
        NSRange theRange = NSMakeRange(fromIndex, toIndex - fromIndex + 1);
        NSArray *stretch = [pointsToFit subarrayWithRange:theRange];
        
        // If there are only 4 points,
        // it's possible that the estimation won't be right
        if ([stretch count] < 4) {
            SYSegment *segment = [[SYSegment alloc]initWithPoint:firstPoint andPoint:lastPoint];
            [shape addPolygonalFromSegment:segment];
            [segment release];
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
                [fromStartToStudyPoint release];
                [fromStudyPointToEnd release];
                
                CGFloat minumumLongitude = [segment longitude] * 0.25;
                if (maxCurvature < [segment distanceToPoint:aPoint] && longitudeToStart > minumumLongitude && longitudeToEnd > minumumLongitude)
                    maxCurvature = [segment distanceToPoint:aPoint];
                
                CGPoint previousPoint = [[pointsToFit objectAtIndex:j-1]CGPointValue];
                SYSegment *segmentCalculateLongitude = [[SYSegment alloc]initWithPoint:previousPoint andPoint:aPoint];
                longitude += [segmentCalculateLongitude longitude];
                [segmentCalculateLongitude release];
            }
            
            CGFloat ratioTotalCurvature = sumDistance / longitude;
            
            
            // Bezier
            // ---------------------------------------------------------
            SYBezierController *bezierController = [[SYBezierController alloc]init];
            NSArray *result = [bezierController buildBestBezierForListPoint:stretch tolerance:[toleranceSlider value]*0.0001/*bezierTolerance*/];
            [bezierController release];
            
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
            
            [segment release];
        }
    }
    
    // Try to fit with a oval
    if (isCloseShape && needsCheckOval && [self drawOvalCirclePainted]) {
        [shape release];
        return;
    }
    
    // Just snap
    if ([self isRectangle])
        [shape snapLinesAngles];
    
    // It's closed (almost closed), do closed perfectly
    if (isCloseShape)
        [shape checkCloseShape];
    
    // Force continuity modifying the control points
    [shape forceContinuity:[continuitySlider value]];
    
    // Add shape to the canvas
    [vectorView addShape:shape];
    [shape release];
    
}// buildShapeClose:


#pragma mark - Analyze Shape

- (BOOL) isRectangle
{
    // Reduce Points
    // --------------------------------------------------------------------------
    NSDictionary *dataDict = [self reducePointsKey];
    NSMutableArray *pointsToFit = [dataDict valueForKey:@"pointsToFit"];            // Points to follow replacing keypoints for the final key points
    NSMutableArray *indexKeyPoints = [dataDict valueForKey:@"indexKeyPoints"];      // Index for all key points

    for (NSUInteger i = 0; i < [indexKeyPoints count]; i++) {
        // Build stretch
        NSUInteger index = [[indexKeyPoints objectAtIndex:i]integerValue];
        CGPoint keyPoint = [[pointsToFit objectAtIndex:index]CGPointValue];
        
        // Check Rectangle 0 or 90 degree
        float testXA = fabs((keyPoint.x - minX.x)/(maxX.x - minX.x));
        float testYA = fabs((keyPoint.y - minY.y)/(maxY.y - minY.y));

        if (!(testXA < toleranceRect || testXA > 1-toleranceRect))
            return NO;
        if (!(testYA < toleranceRect || testYA > 1-toleranceRect))
            return NO;
    }
    
    return YES;
    
}// isRectangle


- (BOOL) isRotateRectangle
{
    // Reduce Points
    // --------------------------------------------------------------------------
    NSDictionary *dataDict = [self reducePointsKey];
    NSMutableArray *pointsToFit = [dataDict valueForKey:@"pointsToFit"];            // Points to follow replacing keypoints for the final key points
    NSMutableArray *indexKeyPoints = [dataDict valueForKey:@"indexKeyPoints"];      // Index for all key points
    if ([indexKeyPoints count] != 5)
        return NO;
    
    // Get the four segments
    NSUInteger indexA = [[indexKeyPoints objectAtIndex:0]integerValue];
    CGPoint keyPointA = [[pointsToFit objectAtIndex:indexA]CGPointValue];
    NSUInteger indexB = [[indexKeyPoints objectAtIndex:1]integerValue];
    CGPoint keyPointB = [[pointsToFit objectAtIndex:indexB]CGPointValue];
    NSUInteger indexC = [[indexKeyPoints objectAtIndex:2]integerValue];
    CGPoint keyPointC = [[pointsToFit objectAtIndex:indexC]CGPointValue];
    NSUInteger indexD = [[indexKeyPoints objectAtIndex:3]integerValue];
    CGPoint keyPointD = [[pointsToFit objectAtIndex:indexD]CGPointValue];
    NSUInteger indexE = [[indexKeyPoints objectAtIndex:4]integerValue];
    CGPoint keyPointE = [[pointsToFit objectAtIndex:indexE]CGPointValue];
    
    SYSegment *segmentAB = [[SYSegment alloc]initWithPoint:keyPointA andPoint:keyPointB];
    SYSegment *segmentBC = [[SYSegment alloc]initWithPoint:keyPointB andPoint:keyPointC];
    SYSegment *segmentCD = [[SYSegment alloc]initWithPoint:keyPointC andPoint:keyPointD];
    SYSegment *segmentDE = [[SYSegment alloc]initWithPoint:keyPointD andPoint:keyPointE];
    
    CGFloat angleAB = [segmentAB angleDeg];
    if (angleAB > 180.0)
        angleAB -=180.0;
    CGFloat angleBC = [segmentBC angleDeg];
    if (angleBC > 180.0)
        angleBC -=180.0;
    CGFloat angleCD = [segmentCD angleDeg];
    if (angleCD > 180.0)
        angleCD -=180.0;
    CGFloat angleDE = [segmentDE angleDeg];
    if (angleDE > 180.0)
        angleDE -=180.0;

    [segmentAB release];
    [segmentBC release];
    [segmentCD release];
    [segmentDE release];
    
    // Are the segments parallels?
    if (fabs(angleAB - angleCD) > rotateRectangleAngleTolerance ||
        fabs(angleBC - angleDE) > rotateRectangleAngleTolerance) {
        return NO;
    }
    
    // Are the angles in segment contiguous between 85/95 degrees?
    if (angleAB > angleBC) {
        if (fabs(angleAB - angleCD) > 90.0 + rotateRectangleAngleTolerance) {   return NO;  }
    }
    else {
        if (fabs(angleBC - angleAB) > 90.0 + rotateRectangleAngleTolerance) {   return NO;  }
    }
    
    if (angleCD > angleDE) {
        if (fabs(angleCD - angleDE) > 90.0 + rotateRectangleAngleTolerance) {   return NO;  }
    }
    else {
        if (fabs(angleDE - angleCD) > 90.0 + rotateRectangleAngleTolerance) {   return NO;  }
    }
    
    // Angles correct, It's a rectangle
    return YES;
    
}// isRotateRectangle


- (BOOL) drawOvalCirclePainted
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
                [bigAxisSegment release];
                bigAxisSegment = [possibleAxis retain];
                axisDistance = [possibleAxis longitude];
            }
            
            [possibleAxis release];
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
        
        NSLog(@"Error: %f", error);
        // If the error is higher than tolerance, It isn't a oval
        if (error > ovaltoleracetypeA)
            return NO;
                
        // It's a oval and add to the shape list
        SYShape *shape = [[SYShape alloc]initWithBezierTolerance:[toleranceSlider value]*0.0001];
        shape.openCurve = NO;
        [shape addCircle:ovalRect];
        [vectorView addShape:shape];
        [shape release];
        
        return YES;
    }
    
    // Looking for the small axis
    SYSegment *smallAxisSegment = nil; CGFloat angleMax = 10000.0;
    
    for (NSValue *pointValue in listPoints) {
        CGPoint pointB = [pointValue CGPointValue];
        SYSegment *possibleAxis = [[SYSegment alloc]initWithPoint:center andPoint:pointB];
        
        // Busca aquel segmento que más se acerque a 90º
        // con respecto al eje mayor.
        float deltaAngle = fabs([bigAxisSegment angleDeg] - [possibleAxis angleDeg]);
        float angle = fabs(deltaAngle - 90.0);
        
        if (angle < angleMax) {
            [smallAxisSegment release];
            smallAxisSegment = [possibleAxis retain];
            angleMax = angle;
        }
        [possibleAxis release];
    }
    
    
    // Maybe it's almost a circle
    float bigAxisLongitude = [bigAxisSegment longitude];
    float smallAxisLongitude = [smallAxisSegment longitude] * 2.0;
    
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
        if (error > 30.0) {
            [bigAxisSegment release];
            [smallAxisSegment release];
            return NO;
        }
        
        // It's a circle and add to the shape list
        SYShape *shape = [[SYShape alloc]initWithBezierTolerance:[toleranceSlider value]*0.0001];
        shape.openCurve = NO;
        [shape addArc:CGPointMake(center.x, center.y)
               radius:bigAxisLongitude*0.5
           startAngle:.0
             endAngle:360.0
            clockwise:YES];
        [vectorView addShape:shape];
        [shape release];
        
        [bigAxisSegment release];
        [smallAxisSegment release];
        
        return YES;
    }
    
    // Get max and min XY
    SYSegment *newSegment = [[SYSegment alloc]initWithPoint:[bigAxisSegment pointSt] andPoint:[bigAxisSegment pointFn]];
    [newSegment setMiddlePointToDegree:90.0];
    minY = [newSegment pointSt];
    maxY = [newSegment pointFn];
    minX = CGPointMake([newSegment midPoint].x - smallAxisLongitude * 0.5, [newSegment midPoint].y);
    maxX = CGPointMake([newSegment midPoint].x + smallAxisLongitude * 0.5, [newSegment midPoint].y);
    [newSegment release];
    
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
    CGFloat b = [smallAxisSegment longitude];
    
    for (NSValue *pointValue in listPoints) {
        
        CGPoint pointOrig = [pointValue CGPointValue];
        
        // Project point over the axis
        SYSegment *lineToPoint = [[SYSegment alloc]initWithPoint:center andPoint:pointOrig];
        CGFloat projBigAxis = [lineToPoint longitude] * cosf([lineToPoint angleRad]-[bigAxisSegment angleRad]);
        CGFloat projSmallAxis = [lineToPoint longitude] * cosf([lineToPoint angleRad]-[smallAxisSegment angleRad]);;
        [lineToPoint release];
        
        CGFloat errorTemp = (pow(projBigAxis, 2)/pow(a, 2)) + (pow(projSmallAxis, 2)/pow(b, 2));
        CGFloat finalError = fabs(1 - errorTemp);
        if (finalError > error)
            error = finalError;
    }
    
    NSLog(@"ErrorB: %f", error);
    if (error > ovaltoleracetypeB) {
        [bigAxisSegment release];
        [smallAxisSegment release];
        return NO;
    }
    
    // Create arc
    SYShape *shape = [[SYShape alloc]initWithBezierTolerance:[toleranceSlider value]*0.0001];
    shape.openCurve = NO;
    [shape addCircleWithRect:CGRectMake(minX.x, maxY.y, (maxX.x - minX.x), (maxY.y - minY.y))
                andTransform:transform];
    [vectorView addShape:shape];
    [shape release];
            
    [bigAxisSegment release];
    [smallAxisSegment release];
     
    return YES;
    
}// drawOvalCirclePainted


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
                        NSLog(@"error");
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
            
            [segment release];
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
    for (int i = 0 ; i+2 < [reducePointKeyArray count]-1 ; i++) {
        
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
    
    // --------------------------------------------------------------------------
    
    // DEBUG DRAW
    SYShape *keyPointShape = [[SYShape alloc]initWithBezierTolerance:[toleranceSlider value]*0.0001];
    for (NSValue *pointValue in listPoints)
        [keyPointShape addPoint:[pointValue CGPointValue]];
    [vectorView addShape:keyPointShape];
    [keyPointShape release];
    
    // DEBUG DRAW
    SYShape *reducePointKeyArrayShape = [[SYShape alloc]initWithBezierTolerance:[toleranceSlider value]*0.0001];
    for (NSValue *pointValue in reducePointKeyArray)
        [reducePointKeyArrayShape addKeyPoint:[pointValue CGPointValue]];
    [vectorView addShape:reducePointKeyArrayShape];
    [reducePointKeyArrayShape release];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:pointsToFit, @"pointsToFit", indexKeyPoints, @"indexKeyPoints", nil];    
    
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


- (CGFloat) distanceFrom:(CGPoint) pointTest toLineBuildForPoint:(CGPoint) pointKey andPoint:(CGPoint) pointNextKey
{
    // Calcula pendiente
    CGFloat m = (pointNextKey.y - pointKey.y) / (pointNextKey.x - pointKey.x);
    
    // Calcula termino d
    CGFloat d = pointKey.y - (m * pointKey.x);
    
    // Se calcula distancia
    CGFloat dist = fabsf(pointTest.y - ((m * pointTest.x) + d)) / sqrtf(powf(m, 2) + 1);
    
    return dist;
    
}// distanceFrom:toLineBuildForPoint:andPoint:


- (BOOL) point:(CGPoint)pointA andPoint:(CGPoint)pointB isAlignedWithPoint:(CGPoint)pointC
{
    // Ecuacion de la recta y = mx + d
    // -------------------------------
    // Se calcula distancia
    float dist = [self distanceFrom:pointC toLineBuildForPoint:pointA andPoint:pointB];
    
    // Si esta alineado responde si
    if (dist == 0)
        return YES;
    
    // Si no NO
    return NO;
    
}// point:andPoint:isAlignedWithPoint:

@end