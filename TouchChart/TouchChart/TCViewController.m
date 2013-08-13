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
#import "SYSaveMessageView.h"

#import "SYShape.h"

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
#define ovaltolerace 1.8


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
    
    [openShapeButton release];
    openShapeButton = nil;
    
    [closeShapeButton release];
    closeShapeButton = nil;
    
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
    
    [openShapeButton release];
    [closeShapeButton release];
    
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
    
    [paintView saveCase:nameTextField.text];
    
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
            openShapeButton.selected = YES;
            closeShapeButton.selected = NO;
            break;
        case 2:
            openShapeButton.selected = NO;
            closeShapeButton.selected = YES;
            break;
        case 3:
            openShapeButton.selected = NO;
            closeShapeButton.selected = NO;
            break;
        default:
            break;
    }
    
}// switchDrawModes


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
    
    // Is the painted shape closed (almost closed)?
    // --------------------------------------------------------------------------
    // Get radius to reduce point cloud
    CGFloat maxDeltaX = maxX.x - minX.x;
    CGFloat maxDeltaY = maxY.y - minY.y;
    
    CGFloat deltaX = [[listPoints objectAtIndex:0]CGPointValue].x - [[listPoints lastObject]CGPointValue].x;
    CGFloat deltaY = [[listPoints objectAtIndex:0]CGPointValue].y - [[listPoints lastObject]CGPointValue].y;
    CGFloat distance = sqrtf(powf(deltaX, 2) + powf(deltaY, 2));
    CGFloat delta = sqrtf(powf(maxDeltaX, 2) + powf(maxDeltaY, 2));
    if (delta < 5.0)
        return;
    CGFloat ratioDistance = distance / delta;
        
    // It's open, do nothing, exit
    if (fabs(ratioDistance) > 0.25)
        [self drawOpenShape];
    else {
        // If the resulting points number is insufficient, exit
        if ([pointKeyArray count] <= 2)
            return;
        
        [self drawCloseShape];
    }
    
    /*
    if ([openShapeButton isSelected])
        [self drawOpenShape];
    else
        [self drawCloseShape];
    */
    [vectorView setNeedsDisplay];
    
}// getFigurePainted


- (void) drawOpenShape
{
    NSDictionary *dataDict = [self reducePointsKey];
    
    NSMutableArray *pointsToFit = [dataDict valueForKey:@"pointsToFit"];            // Points to follow replacing keypoints for the final key points
    NSMutableArray *indexKeyPoints = [dataDict valueForKey:@"indexKeyPoints"];      // Index for all key points
    
    // We have the correct keypoints now and its index into a points list.
    // We can start to study the stretch between key points (line or curve)
    SYShape *shape = [[SYShape alloc]init];
    shape.openCurve = YES;
    NSMutableArray *previousCurves = [NSMutableArray array];
    
    for (NSUInteger i = 1; i < [indexKeyPoints count]; i++) {
        // Build stretch
        NSUInteger fromIndex = [[indexKeyPoints objectAtIndex:i-1]integerValue];
        NSUInteger toIndex = [[indexKeyPoints objectAtIndex:i]integerValue];
        
        CGPoint firstPoint = [[pointsToFit objectAtIndex:fromIndex]CGPointValue];
        CGPoint lastPoint = [[pointsToFit objectAtIndex:toIndex]CGPointValue];
        
        // Get the points for that stretch
        NSRange theRange = NSMakeRange(fromIndex, toIndex - fromIndex + 1);
        NSArray *stretch = [pointsToFit subarrayWithRange:theRange];
        
        // If there are only 4 points,
        // it's possible that the estimation won't be right
        if ([stretch count] < 4) {

            if ([previousCurves count] != 0) {
                [shape addCurve:previousCurves];
                previousCurves = [NSMutableArray array];
            }
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
            
            CGFloat ratioSumDistance = sumDistance / longitude;
            
            
            // Bezier
            // ---------------------------------------------------------
            SYBezierController *bezierController = [[SYBezierController alloc]init];
            NSArray *result = [bezierController getBestCurveForListPoint:stretch tolerance:0.01];
            [bezierController release];
            
            // Is line or curve? (Are aligned the control points?)
            CGPoint controlPoint1 = [[[result objectAtIndex:0] valueForKey:@"cPointA"]CGPointValue];
            CGPoint controlPoint2 = [[[result objectAtIndex:0] valueForKey:@"cPointB"]CGPointValue];
            CGFloat bezierRatioError = [[[result objectAtIndex:0] valueForKey:@"errorRatio"]floatValue];
            CGFloat alignedCPRatio = (([segment distanceToPoint:controlPoint1]/[segment longitude]) + ([segment distanceToPoint:controlPoint2]/[segment longitude])) * 0.5;
            //NSLog(@"%u - %u : longitude: %f  |  maxCurvature: %f  |  ratioSumDistance: %f  |  alignedCPRatio: %f  |  bezierRatioError: %f", fromIndex, toIndex, longitude, maxCurvature, ratioSumDistance, alignedCPRatio, bezierRatioError);
            
            // Estimate curve or line reading the parameters calculated
            // If the bezier is fit to the shape well...
            if (longitude > 65.0) {
                if (maxCurvature < 6.3) {
                    //NSLog(@"%u - %u   :   LINEA", fromIndex, toIndex);
                    if ([previousCurves count] != 0) {
                        [shape addCurve:previousCurves];
                        previousCurves = [NSMutableArray array];
                    }
                    [shape addPolygonalFromSegment:segment];
                }
                else {
                    //NSLog(@"%u - %u   :   CURVA", fromIndex, toIndex);
                    if ([previousCurves count] != 0)
                        [previousCurves removeLastObject];  // The first object from stretch is the same than the last in the previous stretch
                    [previousCurves addObjectsFromArray:stretch];
                }
            }
            else if (bezierRatioError < 0.29) {
                if (alignedCPRatio < 0.037) {
                    //NSLog(@"%u - %u   :   LINEA", fromIndex, toIndex);
                    if ([previousCurves count] != 0) {
                        [shape addCurve:previousCurves];
                        previousCurves = [NSMutableArray array];
                    }
                    [shape addPolygonalFromSegment:segment];
                }
                else if (alignedCPRatio > 0.18) {
                    //NSLog(@"%u - %u   :   CURVA", fromIndex, toIndex);
                    if ([previousCurves count] != 0)
                        [previousCurves removeLastObject];  // The first object from stretch is the same than the last in the previous stretch
                    [previousCurves addObjectsFromArray:stretch];
                }
                else if (ratioSumDistance < 1.0) {
                    //NSLog(@"%u - %u   :   LINEA", fromIndex, toIndex);
                    if ([previousCurves count] != 0) {
                        [shape addCurve:previousCurves];
                        previousCurves = [NSMutableArray array];
                    }
                    [shape addPolygonalFromSegment:segment];
                }
                else {
                     //NSLog(@"%u - %u   :   CURVA", fromIndex, toIndex);
                    if ([previousCurves count] != 0)
                        [previousCurves removeLastObject];  // The first object from stretch is the same than the last in the previous stretch
                    [previousCurves addObjectsFromArray:stretch];
                }
                
            }
            else if (ratioSumDistance < 2.1) {
                //NSLog(@"%u - %u   :   LINEA", fromIndex, toIndex);
                if ([previousCurves count] != 0) {
                    [shape addCurve:previousCurves];
                    previousCurves = [NSMutableArray array];
                }
                [shape addPolygonalFromSegment:segment];
            }
            else {
                //NSLog(@"%u - %u   :   CURVA", fromIndex, toIndex);
                if ([previousCurves count] != 0)
                    [previousCurves removeLastObject];  // The first object from stretch is the same than the last in the previous stretch
                [previousCurves addObjectsFromArray:stretch];
            }
            
            [segment release];
        }
    }
    
    // If finish with curve, it should add this last stretch
    if ([previousCurves count] != 0)
        [shape addCurve:previousCurves];
    
    [shape snapLinesAngles];
    [vectorView addShape:shape];
    
    [shape release];
    
}// drawOpenCurve


- (void) drawCloseShape
{
    /*
    // Is the painted shape closed (almost closed)?
    // --------------------------------------------------------------------------
    // Get radius to reduce point cloud
    CGFloat maxDeltaX = maxX.x - minX.x;
    CGFloat maxDeltaY = maxY.y - minY.y;
    
    CGFloat deltaX = [[listPoints objectAtIndex:0]CGPointValue].x - [[listPoints lastObject]CGPointValue].x;
    CGFloat deltaY = [[listPoints objectAtIndex:0]CGPointValue].y - [[listPoints lastObject]CGPointValue].y;
    CGFloat ratioXClose = deltaX / maxDeltaX;
    CGFloat ratioYClose = deltaY / maxDeltaY;
    
    // It's open, do nothing, exit
    if (fabs(ratioXClose) > 0.25 || fabs(ratioYClose) > 0.25)
        return;

    // If the resulting points number is insufficient, exit
    if ([pointKeyArray count] < 2)
        return;*/
    
    // Reduce Points
    // --------------------------------------------------------------------------
    NSDictionary *dataDict = [self reducePointsKey];
    NSMutableArray *pointsToFit = [dataDict valueForKey:@"pointsToFit"];            // Points to follow replacing keypoints for the final key points
    NSMutableArray *indexKeyPoints = [dataDict valueForKey:@"indexKeyPoints"];      // Index for all key points
    
    // We have the correct keypoints now and its index into a points list.
    // We can start to study the stretch between key points (line or curve)
    SYShape *shape = [[SYShape alloc]init];
    shape.closeCurve = YES;
    NSMutableArray *previousCurves = [NSMutableArray array];
    BOOL shouldCheckOval = YES;
    
    if([indexKeyPoints count] < 2){
        // not enough keypoints for a shape
        return;
    }
    
    for (NSUInteger i = 1; i < [indexKeyPoints count]; i++) {
        // Build stretch
        NSUInteger fromIndex = [[indexKeyPoints objectAtIndex:i-1]integerValue];
        NSUInteger toIndex = [[indexKeyPoints objectAtIndex:i]integerValue];
        
        CGPoint firstPoint = [[pointsToFit objectAtIndex:fromIndex]CGPointValue];
        CGPoint lastPoint = [[pointsToFit objectAtIndex:toIndex]CGPointValue];
        
        // Get the points for that stretch
        NSRange theRange = NSMakeRange(fromIndex, toIndex - fromIndex + 1);
        NSArray *stretch = [pointsToFit subarrayWithRange:theRange];
        
        // If there are only 4 points,
        // it's possible that the estimation won't be right
        if ([stretch count] < 4) {
            
            if ([previousCurves count] != 0) {
                [shape addCurve:previousCurves];
                previousCurves = [NSMutableArray array];
            }
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
            
            CGFloat ratioSumDistance = sumDistance / longitude;
            
            
            // Bezier
            // ---------------------------------------------------------
            SYBezierController *bezierController = [[SYBezierController alloc]init];
            NSArray *result = [bezierController getBestCurveForListPoint:stretch tolerance:0.01];
            [bezierController release];
            
            // Is line or curve? (Are aligned the control points?)
            CGPoint controlPoint1 = [[[result objectAtIndex:0] valueForKey:@"cPointA"]CGPointValue];
            CGPoint controlPoint2 = [[[result objectAtIndex:0] valueForKey:@"cPointB"]CGPointValue];
            CGFloat bezierRatioError = [[[result objectAtIndex:0] valueForKey:@"errorRatio"]floatValue];
            CGFloat alignedCPRatio = (([segment distanceToPoint:controlPoint1]/[segment longitude]) + ([segment distanceToPoint:controlPoint2]/[segment longitude])) * 0.5;
            //NSLog(@"%u - %u : longitude: %f  |  maxCurvature: %f  |  ratioSumDistance: %f  |  alignedCPRatio: %f  |  bezierRatioError: %f", fromIndex, toIndex, longitude, maxCurvature, ratioSumDistance, alignedCPRatio, bezierRatioError);
            
            // Estimate curve or line reading the parameters calculated
            // If the bezier is fit to the shape well...
            if (longitude > 65.0) {
                if (maxCurvature < 6.3) {
                    //NSLog(@"%u - %u   :   LINEA", fromIndex, toIndex);
                    shouldCheckOval = NO;
                    if ([previousCurves count] != 0) {
                        [shape addCurve:previousCurves];
                        previousCurves = [NSMutableArray array];
                    }
                    [shape addPolygonalFromSegment:segment];
                }
                else {
                    //NSLog(@"%u - %u   :   CURVA", fromIndex, toIndex);
                    if ([previousCurves count] != 0)
                        [previousCurves removeLastObject];  // The first object from stretch is the same than the last in the previous stretch
                    [previousCurves addObjectsFromArray:stretch];
                }
            }
            else if (bezierRatioError < 0.29) {
                if (alignedCPRatio < 0.037) {
                    //NSLog(@"%u - %u   :   LINEA", fromIndex, toIndex);
                    shouldCheckOval = NO;
                    if ([previousCurves count] != 0) {
                        [shape addCurve:previousCurves];
                        previousCurves = [NSMutableArray array];
                    }
                    [shape addPolygonalFromSegment:segment];
                }
                else if (alignedCPRatio > 0.18) {
                    //NSLog(@"%u - %u   :   CURVA", fromIndex, toIndex);
                    if ([previousCurves count] != 0)
                        [previousCurves removeLastObject];  // The first object from stretch is the same than the last in the previous stretch
                    [previousCurves addObjectsFromArray:stretch];
                }
                else if (ratioSumDistance < 1.0) {
                    //NSLog(@"%u - %u   :   LINEA", fromIndex, toIndex);
                    if ([previousCurves count] != 0) {
                        [shape addCurve:previousCurves];
                        previousCurves = [NSMutableArray array];
                    }
                    [shape addPolygonalFromSegment:segment];
                }
                else {
                    //NSLog(@"%u - %u   :   CURVA", fromIndex, toIndex);
                    if ([previousCurves count] != 0)
                        [previousCurves removeLastObject];  // The first object from stretch is the same than the last in the previous stretch
                    [previousCurves addObjectsFromArray:stretch];
                }
                
            }
            else if (ratioSumDistance < 2.1) {
                //NSLog(@"%u - %u   :   LINEA", fromIndex, toIndex);
                shouldCheckOval = NO;
                if ([previousCurves count] != 0) {
                    [shape addCurve:previousCurves];
                    previousCurves = [NSMutableArray array];
                }
                [shape addPolygonalFromSegment:segment];
            }
            else {
                //NSLog(@"%u - %u   :   CURVA", fromIndex, toIndex);
                if ([previousCurves count] != 0)
                    [previousCurves removeLastObject];  // The first object from stretch is the same than the last in the previous stretch
                [previousCurves addObjectsFromArray:stretch];
            }
            
            [segment release];
        }
    }
    
    // If finish with curve, it should add this last stretch
    if ([previousCurves count] != 0)
        [shape addCurve:previousCurves];
    
    // Try to fit with a oval
    if (shouldCheckOval && [self drawOvalCirclePainted]) {
        [shape release];
        return;
    }

    // Snap angles
    [shape snapLinesAngles];

    // It's closed (almost closed), do closed perfectly
    [shape checkCloseShape];
    
    // Add shape to the canvas
    [vectorView addShape:shape];
    [shape release];
    
}// drawCloseShape


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
    
    // If horizontal or vertical oval, we don't need rotate it
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
        
        // Check error
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
        
        // PROBAR SI ES UN OVALO O NO
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
        
        // It isn't a oval
        NSLog(@"1. Error Oval: %f", error);        
        if (error > ovaltolerace)
            return NO;
                
        // It's a oval and add to the shape list
        SYShape *shape = [[SYShape alloc]init];
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
        NSLog(@"2. Error Oval B: %f", error);
        if (error > 30.0) {
            [bigAxisSegment release];
            [smallAxisSegment release];
            return NO;
        }
        
        // It's a circle and add to the shape list
        SYShape *shape = [[SYShape alloc]init];
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
    float angleRad = [bigAxisSegment angleRad] + M_PI_2;
    CGPoint pivotalPoint = CGPointMake([bigAxisSegment midPoint].x, [bigAxisSegment midPoint].y);
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(.0, -(maxY.y - minY.y)));
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(-pivotalPoint.x, -pivotalPoint.y));
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeRotation(angleRad));
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(pivotalPoint.x, pivotalPoint.y));
    /*
    // Check error
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
    */
    // PRUEBA SI ES UN OVALO O NO
    CGFloat error = .0;
    
    CGFloat a = [bigAxisSegment longitude] * 0.5;
    CGFloat b = [smallAxisSegment longitude];
    
    for (NSValue *pointValue in listPoints) {
        
        CGPoint pointOrig = [pointValue CGPointValue];
        
        // Proyeccion del punto sobre el eje mayor y menor
        SYSegment *lineToPoint = [[SYSegment alloc]initWithPoint:center andPoint:pointOrig];
        CGFloat projBigAxis = [lineToPoint longitude] * cosf([lineToPoint angleRad]-[bigAxisSegment angleRad]);
        CGFloat projSmallAxis = [lineToPoint longitude] * cosf([lineToPoint angleRad]-[smallAxisSegment angleRad]);;
        [lineToPoint release];
        
        CGFloat errorTemp = (pow(projBigAxis, 2)/pow(a, 2)) + (pow(projSmallAxis, 2)/pow(b, 2));
        //NSLog(@"%f = %f + %f", errorTemp, pow(projBigAxis, 2)/pow(a, 2) , pow(projSmallAxis, 2)/pow(b, 2));
        CGFloat finalError = fabs(1 - errorTemp);
        if (finalError > error)
            error = finalError;
    }
    
    NSLog(@"3. Error Oval A: %f", error);
    if (error > ovaltolerace) {
        [bigAxisSegment release];
        [smallAxisSegment release];
        return NO;
    }
    
    // Create arc
    SYShape *shape = [[SYShape alloc]init];
    shape.openCurve = NO;
    [shape addCircleWithRect:CGRectMake(minX.x, maxY.y, (maxX.x - minX.x), (maxY.y - minY.y))
                andTransform:transform];
    [vectorView addShape:shape];
    [shape release];
            
    [bigAxisSegment release];
    [smallAxisSegment release];
     
    return YES;
    
}// drawOvalCirclePainted



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
    
    /*
    for (int i = 1; i < [listPoints count]; i++) {
     
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
    */
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
    
    
    // Remove key points if the normal points between them are < 5
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
    SYShape *keyPointShape = [[SYShape alloc]init];
    for (NSValue *pointValue in listPoints)
        [keyPointShape addPoint:[pointValue CGPointValue]];
    [vectorView addShape:keyPointShape];
    [keyPointShape release];
    
    // DEBUG DRAW
    SYShape *reducePointKeyArrayShape = [[SYShape alloc]init];
    for (NSValue *pointValue in reducePointKeyArray)
        [reducePointKeyArrayShape addKeyPoint:[pointValue CGPointValue]];
    [vectorView addShape:reducePointKeyArrayShape];
    [reducePointKeyArrayShape release];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:pointsToFit, @"pointsToFit", indexKeyPoints, @"indexKeyPoints", nil];    
    
}// reducePointsKey


- (void) snapLinesAnglesForShape:(SYShape *)shape
{
    if (shape.openCurve) {
        // Single line
        if ([[shape geometries]count] == 1) {
            
            SYGeometry *geometryCurrent = [[shape geometries]objectAtIndex:0];
            
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
            // The first line
            SYGeometry *geometryCurrent = [[shape geometries]objectAtIndex:0];
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
            
            for (int i = 1 ; i < [[shape geometries]count]-1 ; i++) {
                
                SYGeometry *geometryCurrent = [[shape geometries]objectAtIndex:i];
                SYGeometry *geometryNext = [[shape geometries]objectAtIndex:i+1];
                
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
            geometryCurrent = [[shape geometries]lastObject];
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
        if ([[shape geometries]count] == 1) {
            
            SYGeometry *geometryCurrent = [[shape geometries]objectAtIndex:0];
            
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
            
            for (int i = 1 ; i < [[shape geometries]count]-1 ; i++) {
                
                SYGeometry *geometryCurrent = [[shape geometries]objectAtIndex:i];
                SYGeometry *geometryNext = [[shape geometries]objectAtIndex:i+1];
                
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
            SYGeometry *geometryCurrent = [[shape geometries]objectAtIndex:0];
            SYGeometry *geometryLast = [[shape geometries]lastObject];
            
            if (geometryCurrent.geometryType == LinesType &&
                geometryLast.geometryType == LinesType) {
                
                // Snap. Start point pivot
                CGPoint pointSt = [[geometryCurrent.pointArray objectAtIndex:0]CGPointValue];
                CGPoint pointFn = [[geometryCurrent.pointArray objectAtIndex:1]CGPointValue];
                
                SYSegment *firstSegment = [[[SYSegment alloc]initWithPoint:pointSt andPoint:pointFn]autorelease];
                if ([firstSegment isSnapAngle])
                    [firstSegment snapAngleChangingStartPoint];
                
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
    
}// snapLinesAnglesForShape:


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
        [segment release];
        
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
    vectorView.shapeList = [NSMutableArray array];
    
    SYGeometry *shapeToAdd = [self createBezierCurvesWithPoints:arrayData];
    if (shapeToAdd)
        [vectorView.shapeList addObject:shapeToAdd];
    
}// drawBezierCurvesWithPoints:


- (void) drawPolygonal:(NSArray *) pointKeyList
{
    //TEMPORAL
    vectorView.shapeList = [NSMutableArray array];
    
    SYGeometry *shapeToAdd = [self createPolygonal:pointKeyList];
    if (shapeToAdd)
        [vectorView.shapeList addObject:shapeToAdd];
    
}// drawPolygonal:


- (void) drawPolygonalFromSegment:(SYSegment *) segment
{
    //TEMPORAL
    vectorView.shapeList = [NSMutableArray array];
    
    SYGeometry *shapeToAdd = [self createPolygonalFromSegment:segment];
    if (shapeToAdd)
        [vectorView.shapeList addObject:shapeToAdd];
    
}// drawPolygonalFromSegment:


- (void) drawSquare:(CGRect) squareRect
{
    //TEMPORAL
    vectorView.shapeList = [NSMutableArray array];
    
    SYGeometry *shapeToAdd = [self createSquare:squareRect];
    if (shapeToAdd)
        [vectorView.shapeList addObject:shapeToAdd];
    
}// drawPolygonalFromSegment:


- (void) drawDiamond:(CGRect) diamondRect
{
    //TEMPORAL
    vectorView.shapeList = [NSMutableArray array];
    
    SYGeometry *shapeToAdd = [self createDiamond:diamondRect];
    if (shapeToAdd)
        [vectorView.shapeList addObject:shapeToAdd];
    
}// drawDiamond:


- (void) drawCircle:(CGRect) circleRect
{
    //TEMPORAL
    vectorView.shapeList = [NSMutableArray array];
    
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


- (void) drawCircleWithTransform:(CGAffineTransform) transform
{
    //TEMPORAL
    vectorView.shapeList = [NSMutableArray array];
    
    SYGeometry *shapeToAdd = [self createCircleWithTransform:transform];
    if (shapeToAdd)
        [vectorView.shapeList addObject:shapeToAdd];
    
}// drawCircleWithTransform:


- (void) drawArc:(CGPoint) midPoint radius:(NSUInteger) radius startAngle:(CGFloat) startAngle endAngle:(CGFloat) endAngle clockwise:(BOOL) clockwise
{
    //TEMPORAL
    vectorView.shapeList = [NSMutableArray array];
    
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
    
    geometry.pointArray = [NSArray arrayWithArray:finalArray];
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    return geometry;
    
}// createPolygonal:


- (SYGeometry *) createPolygonalFromSegment:(SYSegment *) segment
{
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
    
    return geometry;
    
}// createPolygonalFromSegment


- (SYGeometry *) createSquare:(CGRect) squareRect
{
    SYGeometry *geometry = [[[SYGeometry alloc]init]autorelease];
    
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
    SYGeometry *geometry = [[[SYGeometry alloc]init]autorelease];
    
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
    SYGeometry *geometry = [[[SYGeometry alloc]init]autorelease];
    
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
    SYGeometry *geometry = [[[SYGeometry alloc]init]autorelease];
    
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
    SYGeometry *geometry = [[[SYGeometry alloc]init]autorelease];
    
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
    SYGeometry *geometry = [[[SYGeometry alloc]init]autorelease];
    
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