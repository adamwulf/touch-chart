//
//  TCViewController.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 28/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TCViewController.h"
#import "SYVectorView.h"
#import "SYGeometry.h"
#import "SYSegment.h"
#import "SYBezierController.h"
#import "SYPaintView.h"

#import "SYUnitTestController.h"


@interface TCViewController () {
    
    // Array Data
    NSMutableArray *listPoints; // All points
    NSMutableArray *pointKeyArray;
    
    // Cartesian values max, min
    CGPoint maxX, maxY;
    CGPoint minX, minY;
    
    // States
    NSInteger isDeltaXPos;
    NSInteger isDeltaYPos;
    
}

@end


@implementation TCViewController

#define limitDistace 2.99
#define numberFakePoints 8.0


#pragma mark - Lifecycle Methods

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Alert name cases, set round corner
    [[selectCaseNameView layer] setMasksToBounds:YES];
    [[selectCaseNameView layer]setCornerRadius:4.0];
    [unitController updateListPointStored];
    
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
    
    [unitController release];
    unitController = nil;
    
    [openCurveButton release];
    openCurveButton = nil;
    
    [ovalCircleButton release];
    ovalCircleButton = nil;
    
    [polygonsButton release];
    polygonsButton = nil;
    
}// viewDidUnload


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    
}// shouldAutorotateToInterfaceOrientation:


- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    
    [selectCaseNameView setAlpha:.0];
    [vectorView setNeedsDisplay];
    
}// willRotateToInterfaceOrientation:duration:


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    
    // Set message view position
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        [selectCaseNameView setFrame:CGRectMake(240.0, 382.0, 287.0, 179.0)];
    else
        [selectCaseNameView setFrame:CGRectMake(369.0, 217.0, 287.0, 179.0)];
    
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
    [unitController release];
    
    [openCurveButton release];
    [ovalCircleButton release];
    [polygonsButton release];
    
}// dealloc



#pragma mark - Unit Test Methods

- (IBAction) switchShowTable:(id)sender
{
    if ([tableBase isHidden]) {
        [tableBase setHidden:NO];
        [UIView animateWithDuration:0.2 animations:^{
            [tableBase setAlpha:1.0];
        }];
    }
    else {
        [UIView animateWithDuration:0.2 animations:^{
            [tableBase setAlpha:.0];
        }completion:^(BOOL finished){
            [tableBase setHidden:YES];
        }];
    }
    
}// switchShowTable


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
        return;
    }
    
    // Set message view position
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        [selectCaseNameView setFrame:CGRectMake(240.0, 382.0, 287.0, 179.0)];
    else
        [selectCaseNameView setFrame:CGRectMake(369.0, 217.0, 287.0, 179.0)];
    
    
    [nameTextField becomeFirstResponder];
    [selectCaseNameView setAlpha:.0];
    [selectCaseNameView setHidden:NO];
    [UIView animateWithDuration:0.4 animations:^{
        [selectCaseNameView setAlpha:1.0];
    }];
    
}// saveCase:


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
    
    // Create dictionary with all data about the last drawing
    NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjectsAndKeys:listPoints, @"listPoints", pointKeyArray, @"pointKeyArray", [NSValue valueWithCGPoint:maxX], @"maxX", [NSValue valueWithCGPoint:maxY], @"maxY", [NSValue valueWithCGPoint:minX], @"minX", [NSValue valueWithCGPoint:minY], @"minY", nil];
    [unitController saveListPoints:dataDictionary forKey:[nameTextField text]];
    
}// save


- (IBAction) cancelCase:(id)sender
{
    [nameTextField resignFirstResponder];
    [UIView animateWithDuration:0.4 animations:^{
        [selectCaseNameView setAlpha:.0];
    }completion:^(BOOL finished){
        [selectCaseNameView setHidden:YES];
    }];
    
}// cancelCase



#pragma mark - Button Draw Modes

- (IBAction) switchDrawModes:(id)sender
{
    switch ([sender tag]) {
        case 1:
            openCurveButton.selected = YES;
            ovalCircleButton.selected = NO;
            polygonsButton.selected = NO;
            break;
        case 2:
            openCurveButton.selected = NO;
            ovalCircleButton.selected = YES;
            polygonsButton.selected = NO;
            break;
        case 3:
            openCurveButton.selected = NO;
            ovalCircleButton.selected = NO;
            polygonsButton.selected = YES;
            break;
        default:
            break;
    }
    
}// switchDrawModes

#pragma mark - Management Operations

- (void) importCase:(NSDictionary *) dict
{
    // Clear Paint
    [paintView clearPaint];
    
    // Init all the data and set ready them
    maxX = [[dict valueForKey:@"maxX"]CGPointValue];
    maxY = [[dict valueForKey:@"maxY"]CGPointValue];
    minX = [[dict valueForKey:@"minX"]CGPointValue];
    minY = [[dict valueForKey:@"minY"]CGPointValue];
    
    // Create new point list
    [listPoints release];
    [pointKeyArray release];
    listPoints = [[NSMutableArray alloc]initWithArray:[dict valueForKey:@"listPoints"]];
    pointKeyArray = [[NSMutableArray alloc]initWithArray:[dict valueForKey:@"pointKeyArray"]];
    
    // Analyze a recognize the figure
    [self getFigurePainted];
    
}// importCase


// Clean Data
- (void) resetData
{
    // Init all the data and set ready them
    maxX = CGPointZero;
    maxY = CGPointZero;
    minX = CGPointZero;
    minY = CGPointZero;
    
    // Create new point list
    [listPoints release];
    [pointKeyArray release];
    listPoints = [[NSMutableArray alloc]init];
    pointKeyArray = [[NSMutableArray alloc]init];
    
}// resetData


#pragma mark - Calculate Shapes

- (void) getFigurePainted
{
    // If it doesn't draw, just touch, exit
    if ([listPoints count] < 5)
        return;
    
    if ([openCurveButton isSelected])
        [self drawOpenShape];
    else if ([ovalCircleButton isSelected])
        [self drawOvalCirclePainted];
    else
        [self drawLineCurvesMixedPainted];
    
    [vectorView setNeedsDisplay];
    
}// getFigurePainted


- (void) drawOpenShape
{
    for (NSValue *pointValue in pointKeyArray)
        [self drawPoint:[pointValue CGPointValue]];
    
    NSMutableArray *pointsToFit = [NSMutableArray arrayWithArray:listPoints];       // Points to follow replacing keypoints for the final key points
    NSMutableArray *indexKeyPoints = [NSMutableArray array];                        // Index for all key points
    
    // --------------------------------------------------------------------------
    // Reduce Points
    // --------------------------------------------------------------------------
    
    // Get radius to reduce point cloud
    CGFloat maxDeltaX = maxX.x - minX.x;
    CGFloat maxDeltaY = maxY.y - minY.y;
    CGFloat radiusCloud = sqrtf(powf(maxDeltaX, 2) + powf(maxDeltaY, 2)) * 0.05;
    
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
                
                /*
                // Get the key point for this local cloud point
                CGFloat xMid = .0; CGFloat yMid = .0; CGFloat countF = (CGFloat) [localCloudPoint count];
                for (NSValue *pointCloudValue in localCloudPoint) {
                    CGPoint pointCloud = [pointCloudValue CGPointValue];
                    xMid += pointCloud.x;
                    yMid += pointCloud.y;
                }
                
                // Replace all the point from the cloud for the mid point
                NSValue *midPoint = [NSValue valueWithCGPoint:CGPointMake(xMid/countF, yMid/countF)];
                [reducePointKeyArray replaceObjectAtIndex:i withObject:midPoint];
                
                // Replace the new point into pointsToFit
                if (firstIndex != -1)
                    [pointsToFit replaceObjectAtIndex:firstIndex withObject:midPoint];
                 */
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

    for (NSValue *pointValue in reducePointKeyArray)
        [self drawKeyPoint:[pointValue CGPointValue]];
    
    // We have the correct keypoints now and its index into a points list.
    // We can start to study the stretch between key points (line or curve)
    for (NSUInteger i = 1; i < [indexKeyPoints count]; i++) {
        
        // Build stretch
        NSUInteger fromIndex = [[indexKeyPoints objectAtIndex:i-1]integerValue];
        NSUInteger toIndex = [[indexKeyPoints objectAtIndex:i]integerValue];
        
        CGPoint firstPoint = [[pointsToFit objectAtIndex:fromIndex]CGPointValue];
        CGPoint lastPoint = [[pointsToFit objectAtIndex:toIndex]CGPointValue];
        SYSegment *segment = [[SYSegment alloc]initWithPoint:firstPoint andPoint:lastPoint];
        
        CGFloat sumDistance = .0;
        for (NSUInteger j = fromIndex; j < toIndex; j++) {
            CGPoint firstPoint = [[pointsToFit objectAtIndex:j]CGPointValue];
            sumDistance += [segment distanceToPoint:firstPoint];
        }
        CGFloat errorRatio = sumDistance / (toIndex-fromIndex);
        
        
        // Bezier Methods
        // Get the bezier for that stretch
        NSRange theRange = NSMakeRange(fromIndex, toIndex - fromIndex + 1);
        NSArray *stretch = [pointsToFit subarrayWithRange:theRange];
        
        SYBezierController *bezierController = [[SYBezierController alloc]init];
        NSDictionary *result = [bezierController getCubicBezierPointsForListPoint:stretch];
        [bezierController release];
        [self drawBezierCurveWithPoints:result];
        
        // Is line or curve? (Are aligned the control points?)
        CGPoint controlPoint1 = [[result valueForKey:@"cPointA"]CGPointValue];
        CGPoint controlPoint2 = [[result valueForKey:@"cPointB"]CGPointValue];
        CGFloat bezierRatioError = [[result valueForKey:@"errorRatio"]floatValue];
        CGFloat bezierRatio = (([segment distanceToPoint:controlPoint1]/[segment longitude]) + ([segment distanceToPoint:controlPoint2]/[segment longitude])) * 0.5;
        [segment release];
        NSLog(@"%u - %u   :   ratioSumError: %f -  RatioBezier: %f con error de %f", fromIndex, toIndex, errorRatio, bezierRatio, bezierRatioError);
        
        
        // Estimate curve or line reading the parameters calculated
        // If the bezier is fit to the shape well...
        if (bezierRatioError < 0.23) {
            
            if (bezierRatio < 0.033)
                NSLog(@"%u - %u   :   LINEA", fromIndex, toIndex);
            else if (bezierRatio > 0.06)
                NSLog(@"%u - %u   :   CURVA", fromIndex, toIndex);
            else if (errorRatio < 2.1)
                NSLog(@"%u - %u   :   LINEA", fromIndex, toIndex);
            else
                NSLog(@"%u - %u   :   CURVA", fromIndex, toIndex);
            
        }
        else if (errorRatio < 2.1)
            NSLog(@"%u - %u   :   LINEA", fromIndex, toIndex);
        else
            NSLog(@"%u - %u   :   CURVA", fromIndex, toIndex);
         
    }
    
}// drawOpenCurve




- (void) drawBezierPathPainted
{
    for (NSValue *pointValue in pointKeyArray)
        [self drawPoint:[pointValue CGPointValue]];
    
    for (NSValue *pointValue in [self reducePointsKey])
        [self drawKeyPoint:[pointValue CGPointValue]];
    
    /*
     // Create bezier curve
     SYBezierController *bezierController = [[SYBezierController alloc]init];
     NSArray *curves = [bezierController getBestCurveForListPoint:listPoints tolerance:0.01];
     [bezierController release];
     if (!curves)
     return;
     
     [self drawBezierCurveWithPoints:curves];
     */
    
    /*
     for (NSUInteger i = 0 ; i < [listPoints count] ; i++)
     [self drawPoint:[[listPoints objectAtIndex:i]CGPointValue]];
     */
}// getBezierPathPainted


- (void) drawOvalCirclePainted
{
    //TEMPORAL
    vectorView.shapeList = [[NSMutableArray alloc]init];
    
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
    
    // If horizontal or vertical oval, we don't need rotate it
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
        //CGRect ovalRect = CGRectMake( minX.x, maxY.y, (maxX.x - minX.x), (maxY.y - minY.y));
        CGRect ovalRect = CGRectMake( minX.x, minY.y, (maxX.x - minX.x), (maxY.y - minY.y));
        return [self drawCircle:ovalRect];
    }
    
    // Looking for the small axis
    CGPoint center = [bigAxisSegment midPoint];
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
        
        // Create arc
        return [self drawArc:CGPointMake(center.x, center.y)
                      radius:bigAxisLongitude*0.5
                  startAngle:.0
                    endAngle:360.0
                   clockwise:YES];
    }
    
    // Get max and min XY
    SYSegment *newSegment = [[SYSegment alloc]initWithPoint:[bigAxisSegment pointSt] andPoint:[bigAxisSegment pointFn]];
    [newSegment setMiddlePointToDegree:90.0];
    minY = [newSegment pointSt];
    maxY = [newSegment pointFn];
    minX = CGPointMake([newSegment midPoint].x - smallAxisLongitude * 0.5, [newSegment midPoint].y);
    maxX = CGPointMake([newSegment midPoint].x + smallAxisLongitude * 0.5, [newSegment midPoint].y);
    
    // Transform, rotate a around the midpoint
    float angleRad = [bigAxisSegment angleRad] - M_PI_2;
    CGPoint pivotalPoint = CGPointMake([bigAxisSegment midPoint].x, [bigAxisSegment midPoint].y);
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(.0, -(maxY.y - minY.y)));
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(-pivotalPoint.x, -pivotalPoint.y));
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeRotation(angleRad));
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(pivotalPoint.x, pivotalPoint.y));
    
    [self drawCircleWithTransform:transform];
    
    [newSegment release];
    [bigAxisSegment release];
    [smallAxisSegment release];
    
}// drawOvalCirclePainted


- (void) drawLineCurvesMixedPainted
{
    
    
    /*
     // Is the painted shape closed (almost closed)?
     // --------------------------------------------------------------------------
     CGFloat deltaX = [[listPoints objectAtIndex:0]CGPointValue].x - [[listPoints lastObject]CGPointValue].x;
     CGFloat deltaY = [[listPoints objectAtIndex:0]CGPointValue].y - [[listPoints lastObject]CGPointValue].y;
     CGFloat ratioXClose = deltaX / maxDeltaX;
     CGFloat ratioYClose = deltaY / maxDeltaY;
     
     // It's open, do nothing, exit
     if (fabs(ratioXClose) > 0.25 || fabs(ratioYClose) > 0.25)
     return;
     
     // It's closed (almost closed), do closed perfectly
     CGPoint firstPoint = [[finalArray objectAtIndex:0]CGPointValue];
     CGPoint lastPoint = [[finalArray lastObject]CGPointValue];
     CGPoint midPoint = [self midPointBetweenPoint:firstPoint andPoint:lastPoint];
     [finalArray replaceObjectAtIndex:0 withObject:[NSValue valueWithCGPoint:midPoint]];
     [finalArray removeLastObject];
     
     // Clean all NSNull
     finalArray = [NSMutableArray array];
     for (id keyPoint in pointKeyArray) {
     if ((NSNull *) keyPoint != [NSNull null]) {
     CGPoint newCGPoint = [keyPoint CGPointValue];
     NSValue *newPoint = [NSValue valueWithCGPoint:CGPointMake(newCGPoint.x, newCGPoint.y)];
     [finalArray addObject:newPoint];
     }
     }
     
     // If the resulting points number is insufficient, exit
     pointKeyArray  = [[NSMutableArray alloc]initWithArray:finalArray];
     if ([pointKeyArray count] < 2)
     return;
     
     
     // Remove points aligned (step B)
     // -----------------------------------------------------------------------
     NSMutableArray *pointAlign = [NSMutableArray arrayWithArray:pointKeyArray];
     for (int i = 0 ; i < [pointKeyArray count]; i++) {
     
     BOOL isBreak = NO;
     CGPoint pointA = [[pointAlign objectAtIndex:i]CGPointValue];
     CGPoint pointB = [[pointAlign objectAtIndex:i+1]CGPointValue];
     CGPoint pointC = CGPointZero;
     
     // Is it the last point?... take the first
     if (i+2 == [pointAlign count]) {
     pointC = [[pointAlign objectAtIndex:0]CGPointValue];
     isBreak = YES;
     }
     else
     pointC = [[pointAlign objectAtIndex:i+2]CGPointValue];
     
     CGFloat angleRad = fabsf([self getAngleBetweenVertex:pointB andPointA:pointA andPointB:pointC]);
     
     // Is it aligned
     if (angleRad > 2.4) { // casi 180º grados
     [pointAlign removeObjectAtIndex:i+1];
     i--;
     
     // If the resulting points number is insufficient, exit
     if ([pointAlign count] < 3)
     return;
     }
     
     if (isBreak)
     break;
     }
     
     // Clean all NSNull
     pointKeyArray  = [[NSMutableArray alloc]init];
     for (id point in pointAlign) {
     if ((NSNull *) point != [NSNull null])
     [pointKeyArray addObject:point];
     }
     
     
     // Snap Angles
     // ----------------------------------------------------------------
     // Build segment array
     NSMutableArray *segmentsArray  = [NSMutableArray array];
     for (int i = 0 ; i < [pointKeyArray count]; i++) {
     BOOL isBreak = NO;
     CGPoint pointA = [[pointKeyArray objectAtIndex:i]CGPointValue];
     CGPoint pointB = CGPointZero;
     
     // Is it the last point?... take the first
     if (i+1 == [pointKeyArray count]) {
     pointB = [[pointKeyArray objectAtIndex:0]CGPointValue];
     isBreak = YES;
     }
     else
     pointB = [[pointKeyArray objectAtIndex:i+1]CGPointValue];
     
     SYSegment *segment = [[SYSegment alloc]initWithPoint:pointA andPoint:pointB];
     [segmentsArray addObject:segment];
     
     if (isBreak)
     break;
     }
     
     // Snap all the segments
     for (SYSegment *segment in segmentsArray) {
     if ([segment isSnapAngle])
     [segment snapAngleChangingFinalPoint];
     }
     
     
     // Take the intersection between the segments (it will be key points)
     for (int i = 0 ; i < [segmentsArray count]; i++) {
     BOOL isBreak = NO;
     SYSegment *segmentA = [segmentsArray objectAtIndex:i];
     SYSegment *segmentB = nil;
     
     // Is it the last point?... take the first
     if (i+1 == [segmentsArray count]) {
     segmentB = [segmentsArray objectAtIndex:0];
     isBreak = YES;
     }
     else
     segmentB = [segmentsArray objectAtIndex:i+1];
     
     // Get the intersection point
     CGPoint intersectPoint = [segmentA pointIntersectWithSegment:segmentB];
     
     [segmentA setPointFn:intersectPoint];
     [segmentB setPointSt:intersectPoint];
     
     if (isBreak)
     break;
     }
     
     // Get the final key points
     pointKeyArray = [[NSMutableArray alloc]init];
     SYSegment *segment = [segmentsArray objectAtIndex:0];
     [pointKeyArray  addObject:[NSValue valueWithCGPoint:[segment pointSt]]];
     
     for (SYSegment *segment in segmentsArray)
     [pointKeyArray addObject:[NSValue valueWithCGPoint:[segment pointFn]]];
     
     [self drawPolygonal:pointKeyArray];
     */
}// drawLineCurvesMixedPainted


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


- (CGFloat) getTotalLongitude
{
    CGFloat totalLongitude = .0;
    
    for (NSUInteger i = 1 ; i < [listPoints count] ; i++) {
        CGPoint pointStart = [[listPoints objectAtIndex:i-1]CGPointValue];
        CGPoint pointEnd = [[listPoints objectAtIndex:i]CGPointValue];
        
        SYSegment *segment = [[SYSegment alloc]initWithPoint:pointStart andPoint:pointEnd];
        totalLongitude += [segment longitude];
        [segment release];
    }
    
    return totalLongitude;
    
}// getTotalLongitude


- (NSArray *) reducePointsKey
{
    // Get radius to reduce point cloud
    CGFloat maxDeltaX = maxX.x - minX.x;
    CGFloat maxDeltaY = maxY.y - minY.y;
    CGFloat radiusCloud = sqrtf(powf(maxDeltaX, 2) + powf(maxDeltaY, 2)) * 0.05;
    
    // Point cloud simplification algorithm (using radiusCloud)
    // --------------------------------------------------------------------------
    NSMutableArray *reducePointKeyArray = [NSMutableArray arrayWithArray:pointKeyArray];
    NSMutableArray *indexKeyPoints = [NSMutableArray array];
    
    for (int i = 0 ; i < [reducePointKeyArray count] ; i++) {
        id pointID = [reducePointKeyArray objectAtIndex:i];
        
        if ((NSNull *) pointID != [NSNull null]) {
            CGPoint point = [pointID CGPointValue];
            [indexKeyPoints addObject:[NSNumber numberWithInt:i]];
            
            // Take the neighbors points for which compose the cloud points
            NSMutableArray *localCloudPoint = [NSMutableArray array];
            [localCloudPoint addObject:pointID];
            
            for (int j = i+1 ; j < [pointKeyArray count] ; j++) {
                CGPoint nextPoint = [[pointKeyArray objectAtIndex:j]CGPointValue];
                CGFloat distance = [self distanceBetweenPoint:point andPoint:nextPoint];
                
                if (distance < radiusCloud) {
                    [localCloudPoint addObject:[pointKeyArray objectAtIndex:j]];
                    [reducePointKeyArray replaceObjectAtIndex:j withObject:[NSNull null]];
                }
                else
                    break;
            }
            
            // Get the key point for this local cloud point
            CGFloat xMid = .0; CGFloat yMid = .0; CGFloat countF = (CGFloat) [localCloudPoint count];
            for (NSValue *pointCloudValue in localCloudPoint) {
                CGPoint pointCloud = [pointCloudValue CGPointValue];
                xMid += pointCloud.x;
                yMid += pointCloud.y;
            }
            
            // Replace all the point from the cloud for the mid point
            NSValue *midPoint = [NSValue valueWithCGPoint:CGPointMake(xMid/countF, yMid/countF)];
            [reducePointKeyArray replaceObjectAtIndex:i withObject:midPoint];
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
                [indexKeyPoints replaceObjectAtIndex:i+1 withObject:[NSNull null]];
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
    
    // Clean all NSNull
    cleanerArray  = [NSMutableArray arrayWithArray:indexKeyPoints];
    indexKeyPoints = [NSMutableArray array];
    for (id keyPoint in cleanerArray) {
        if ((NSNull *) keyPoint != [NSNull null])
            [indexKeyPoints addObject:keyPoint];
    }
    
    return [NSArray arrayWithArray:reducePointKeyArray];
    
}// reducePointsKey


#pragma mark - Geometric calculations

// Return shape/curve contour longitude (aprox)
- (CGFloat) lengthFromPointList
{
    // If there isn't enough points, exit
    if ([listPoints count] < 2)
        return .0;
    
    CGFloat longitude = .0;
    for (int i = 1 ; i < [listPoints count] ; i++) {
        CGPoint startSegment = [[listPoints objectAtIndex:i-1]CGPointValue];
        CGPoint endSegment = [[listPoints objectAtIndex:i]CGPointValue];
        
        SYSegment *segment = [[SYSegment alloc]initWithPoint:startSegment andPoint:endSegment];
        longitude += [segment longitude];
        
    }
    
    return longitude;
    
}// lengthFromPointList


// Rewrite your TCChartView method ObjC native
- (CGFloat) distanceBetweenPoint:(CGPoint) point1 andPoint:(CGPoint) point2
{
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    
    return sqrt(pow(dx,2) + pow(dy,2));
    
}// distanceBetweenPoint:andPoint:


// Rewrite your TCChartView method ObjC native
- (CGFloat) getAngleBetweenVertex:(CGPoint) vertex andPointA:(CGPoint) pointA andPointB:(CGPoint) pointB
{
    // cos-1((P122 + P132 - P232)/(2 * P12 * P13))
    
    CGFloat P12 = [self distanceBetweenPoint:vertex andPoint:pointA];
    CGFloat P13 = [self distanceBetweenPoint:vertex andPoint:pointB];
    CGFloat P23 = [self distanceBetweenPoint:pointA andPoint:pointB];
    
    CGFloat num = P12 * P12 + P13 * P13 - P23 * P23;
    CGFloat den = 2 * P12 * P13;
    CGFloat total = num / den;
    CGFloat ret = acosf(total);
    
    return ret;
    
}// getAngleBetween


- (CGPoint) midPointBetweenPoint:(CGPoint) pointA andPoint:(CGPoint) pointB
{
    CGFloat xPoint = (pointA.x + pointB.x) / 2;
    CGFloat yPoint = (pointA.y + pointB.y) / 2;
    CGPoint result = CGPointMake(xPoint, yPoint);
    
    return result;
    
}// midPointBetween:andPoint:


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


- (BOOL) point:(CGPoint)pointA andPoint:(CGPoint)pointC isAlignedWithPoint:(CGPoint)pointB withDistance:(float) ratio
{
    // Ecuacion de la recta y = mx + d
    // -------------------------------
    // Se calcula distancia
    float dist = [self distanceFrom:pointC toLineBuildForPoint:pointA andPoint:pointB];
    
    // Si esta alineado responde si
    if (dist < ratio)
        return YES;
    
    // Si no NO
    return NO;
    
}// point:andPoint:isAlignedWithPoint:



#pragma mark - Auxiliar calculations

- (NSUInteger) getFactorial:(NSUInteger) intNumber
{
    NSUInteger result = 1;
    
    for (NSUInteger i = 0; i < intNumber ; i++)
        result = result * (intNumber-i);
    
    return result;
    
}// getFactorial:


#pragma mark - Draw Geometric Methods

- (void) drawBezierCurveWithPoints:(NSDictionary *) data
{
    SYGeometry *shapeToAdd = [self createBezierCurveWithPoints:data];
    if (shapeToAdd)
        [vectorView.shapeList addObject:shapeToAdd];
    
}// drawBezierCurveWithPoints:


- (void) drawBezierCurvesWithPoints:(NSArray *) arrayData
{
    //TEMPORAL
    vectorView.shapeList = [[NSMutableArray alloc]init];
    
    SYGeometry *shapeToAdd = [self createBezierCurvesWithPoints:arrayData];
    if (shapeToAdd)
        [vectorView.shapeList addObject:shapeToAdd];
    
}// drawBezierCurvesWithPoints:


- (void) drawPolygonal:(NSArray *) pointKeyList
{
    //TEMPORAL
    vectorView.shapeList = [[NSMutableArray alloc]init];
    
    SYGeometry *shapeToAdd = [self createPolygonal:pointKeyList];
    if (shapeToAdd)
        [vectorView.shapeList addObject:shapeToAdd];
    
}// drawPolygonal:


- (void) drawPolygonalFromSegment:(SYSegment *) segment
{
    //TEMPORAL
    vectorView.shapeList = [[NSMutableArray alloc]init];
    
    SYGeometry *shapeToAdd = [self createPolygonalFromSegment:segment];
    if (shapeToAdd)
        [vectorView.shapeList addObject:shapeToAdd];
    
}// drawPolygonalFromSegment:


- (void) drawSquare:(CGRect) squareRect
{
    //TEMPORAL
    vectorView.shapeList = [[NSMutableArray alloc]init];
    
    SYGeometry *shapeToAdd = [self createSquare:squareRect];
    if (shapeToAdd)
        [vectorView.shapeList addObject:shapeToAdd];
    
}// drawPolygonalFromSegment:


- (void) drawDiamond:(CGRect) diamondRect
{
    //TEMPORAL
    vectorView.shapeList = [[NSMutableArray alloc]init];
    
    SYGeometry *shapeToAdd = [self createDiamond:diamondRect];
    if (shapeToAdd)
        [vectorView.shapeList addObject:shapeToAdd];
    
}// drawDiamond:


- (void) drawCircle:(CGRect) circleRect
{
    //TEMPORAL
    vectorView.shapeList = [[NSMutableArray alloc]init];
    
    SYGeometry *shapeToAdd = [self createCircle:circleRect];
    if (shapeToAdd)
        [vectorView.shapeList addObject:shapeToAdd];
    
}// drawDiamond:


- (void) drawPoint:(CGPoint) point
{
    SYGeometry *shapeToAdd = [self createPoint:point];
    if (shapeToAdd)
        [vectorView.shapeList addObject:shapeToAdd];
    
}// drawPoint:


- (void) drawKeyPoint:(CGPoint) point
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = CircleType;
    geometry.rectGeometry = CGRectMake(point.x - 4.0, point.y - 4.0, 8.0, 8.0);
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor redColor];
    geometry.strokeColor = [UIColor redColor];
    
    if (geometry)
        [vectorView.shapeList addObject:geometry];
    
}// drawKeyPoint:


- (void) drawCircleWithTransform:(CGAffineTransform) transform
{
    //TEMPORAL
    vectorView.shapeList = [[NSMutableArray alloc]init];
    
    SYGeometry *shapeToAdd = [self createCircleWithTransform:transform];
    if (shapeToAdd)
        [vectorView.shapeList addObject:shapeToAdd];
    
}// drawCircleWithTransform:


- (void) drawArc:(CGPoint) midPoint radius:(NSUInteger) radius startAngle:(CGFloat) startAngle endAngle:(CGFloat) endAngle clockwise:(BOOL) clockwise
{
    //TEMPORAL
    vectorView.shapeList = [[NSMutableArray alloc]init];
    
    SYGeometry *shapeToAdd = [self createArc:midPoint radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];
    if (shapeToAdd)
        [vectorView.shapeList addObject:shapeToAdd];
    
}// drawArc:radius:startAngle:endAngle:clockwise:



#pragma mark - Create Geometric Methods

- (SYGeometry *) createBezierCurveWithPoints:(NSDictionary *) data
{
    // Draw the resulting shape
    SYGeometry *geometry = [[[SYGeometry alloc]init]autorelease];
    
    // Geometry parameters
    geometry.geometryType = BezierType;
    geometry.pointArray = [NSArray arrayWithObject:data];
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    return geometry;
    
}// createBezierCurveWithPoints


- (SYGeometry *) createBezierCurvesWithPoints:(NSArray *) arrayData
{
    // Draw the resulting shape
    SYGeometry *geometry = [[[SYGeometry alloc]init]autorelease];
    
    // Geometry parameters
    geometry.geometryType = BezierType;
    geometry.pointArray = [NSArray arrayWithArray:arrayData];
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    return geometry;
    
}// createBezierCurvesWithPoints


- (SYGeometry *) createPolygonal:(NSArray *) pointKeyList
{
    // Draw the resulting shape
    SYGeometry *geometry = [[[SYGeometry alloc]init]autorelease];
    
    // Geometry parameters
    geometry.geometryType = LinesType;
    
    // Origin XY conversion
    NSMutableArray *finalArray = [NSMutableArray array];
    for (id keyPoint in pointKeyList) {
        if ((NSNull *) keyPoint != [NSNull null]) {
            NSValue *newPoint = [NSValue valueWithCGPoint:[keyPoint CGPointValue]];
            [finalArray addObject:newPoint];
        }
    }
    
    geometry.pointArray = [[NSArray alloc]initWithArray:finalArray];
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    return geometry;
    
}// createPolygonal:


- (SYGeometry *) createPolygonalFromSegment:(SYSegment *) segment
{
    // Draw the resulting shape
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = LinesType;
    geometry.pointArray = [[NSArray alloc]initWithObjects:[NSValue valueWithCGPoint:[segment pointSt]],
                           [NSValue valueWithCGPoint:[segment pointFn]], nil];
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    return geometry;
    
}// createPolygonalFromSegment


- (SYGeometry *) createSquare:(CGRect) squareRect
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = SquareType;
    geometry.rectGeometry = squareRect;
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor whiteColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    return geometry;
    
}// createSquare


- (SYGeometry *) createDiamond:(CGRect) diamondRect
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = DiamondType;
    geometry.rectGeometry = diamondRect;
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor whiteColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    return geometry;
    
}// createDiamond


- (SYGeometry *) createCircle:(CGRect) rect
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = CircleType;
    geometry.rectGeometry = rect;
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    return geometry;
    
}// createCircle:


- (SYGeometry *) createPoint:(CGPoint) point
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = CircleType;
    geometry.rectGeometry = CGRectMake( point.x - 2.5, point.y - 2.5, 5.0, 5.0);
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    return geometry;
    
}// createPoint:


- (SYGeometry *) createCircleWithTransform:(CGAffineTransform) transform
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = CircleType;
    geometry.rectGeometry = CGRectMake(minX.x, maxY.y, (maxX.x - minX.x), (maxY.y - minY.y));
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    geometry.transform = transform;
    
    return geometry;
    
}// createCircleWithTransform


- (SYGeometry *) createArc:(CGPoint) midPoint radius:(NSUInteger) radius startAngle:(CGFloat) startAngle endAngle:(CGFloat) endAngle clockwise:(BOOL) clockwise
{
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
    
    return geometry;
    
}// createArc:endAngle:

@end