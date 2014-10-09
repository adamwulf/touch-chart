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
#import "SYTableBase.h"
#import "SYShape.h"

@interface TCViewController () 

@end

#define kMinTolerance 0.0000001
#define kMaxTolerance 0.01


@implementation TCViewController{
    TCShapeController* shapeController;
}

#pragma mark - Lifecycle Methods

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Hide table
    [tableBase setAlpha:.0];
    [tableBase setHidden:YES];
    
    [self resetData];
    
}// viewDidLoad


- (void) viewDidUnload
{
    [super viewDidUnload];
    
    paintView = nil;
    
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



#pragma mark - Unit Test Methods

- (IBAction) selectName:(id)sender
{
    if (![shapeController hasPointData]) {
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
    if ([[nameTextField text]length] == 0 || ![shapeController hasPointData])
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
    

//    //
//    // test case of a perfect circle
//    //
//    float steps = 20.0;
//    UIBezierPath* bezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-200, -200, 200, 200)];
//    CGFloat theta = 2*M_PI / steps;
//    
//    CGPoint lastPoint = CGPointZero;
//    for(int i=0;i<((int)steps);i++){
//        [bezierPath applyTransform:CGAffineTransformMakeRotation(theta)];
//        if(i > 0){
//            
//            CGPoint p1 = CGPointMake(lastPoint.x + 300, lastPoint.y + 300);
//            CGPoint p2 = CGPointMake(bezierPath.currentPoint.x + 300, bezierPath.currentPoint.y + 300);
//            
//            NSLog(@"p1: %f %f   p2: %f %f", p1.x, p1.y, p2.x, p2.y);
//            [shapeController addPoint:p1 andPoint:p2];
//        }
//        lastPoint = bezierPath.currentPoint;
//    }
//
//    [bezierPath applyTransform:CGAffineTransformMakeRotation(theta)];
//    CGPoint lastpoint = CGPointMake(bezierPath.currentPoint.x + 300, bezierPath.currentPoint.y + 300);
//    NSLog(@"last point: %f %f", lastpoint.x, lastpoint.y);
//    [shapeController addLastPoint:lastpoint];
//    //
//    // end test case of perfect circle
//    //
    
    
    
    for (NSUInteger i = 1 ; i < [allPoints count]-1 ; i++) {
        // Add these new points
        CGPoint touchPreviousLocation = [[allPoints objectAtIndex:i-1]CGPointValue];
        CGPoint touchLocation = [[allPoints objectAtIndex:i]CGPointValue];
        [shapeController addPoint:touchPreviousLocation andPoint:touchLocation];
    }
    
    CGPoint touchLocation = [[allPoints lastObject]CGPointValue];
    [shapeController addLastPoint:touchLocation];
    
    // Analyze a recognize the figure
    [self getFigurePainted];
    
}// importCase


#pragma mark - Calculate Shapes

-(void) resetData{
    shapeController = [[TCShapeController alloc] init];
    [self rebuildShape:nil];
}

-(float) valueOfToleranceSlider{
    double perc = [toleranceSlider value] / 100.0;
    double min = kMinTolerance;
    double delta = (kMaxTolerance-kMinTolerance);
    return (float) ((double)min + perc*delta);
}

- (IBAction) rebuildShape:(id)sender
{
    continuityLabel.text = [NSString stringWithFormat:@"%4.2f",[continuitySlider value]];
    toleranceLabel.text = [NSString stringWithFormat:@"%4.7f",[self valueOfToleranceSlider]];
    
    [vectorView.shapeList removeLastObject];
    [self getFigurePainted];
    
}// rebuildShape


- (SYShape*) getFigurePainted
{
    SYShape* possibleShape = [shapeController getFigurePaintedWithTolerance:[self valueOfToleranceSlider] andContinuity:[continuitySlider value] forceOpen:NO];
    if(possibleShape){
        [self drawRecentlyReducedKeyPoints];
        [vectorView addShape:possibleShape];
        [vectorView setNeedsDisplay];
    }
    return possibleShape;
}


- (void) drawRecentlyReducedKeyPoints{
    NSDictionary* output = [shapeController recentlyReducedKeyPoints];
    // --------------------------------------------------------------------------
    
    // DEBUG DRAW
    SYShape *keyPointShape = [[SYShape alloc]initWithBezierTolerance:[self valueOfToleranceSlider]];
    for (NSValue *pointValue in [output objectForKey:@"listPoints"])
        [keyPointShape addPoint:[pointValue CGPointValue]];
    [vectorView addDebugShape:keyPointShape];
    
    // DEBUG DRAW
    SYShape *reducePointKeyArrayShape = [[SYShape alloc]initWithBezierTolerance:[self valueOfToleranceSlider]];
    for (NSValue *pointValue in [output objectForKey:@"reducePointKeyArray"])
        [reducePointKeyArrayShape addKeyPoint:[pointValue CGPointValue]];
    [vectorView addDebugShape:reducePointKeyArrayShape];
}

#pragma mark - Cloud Points Methods

- (void) addPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;
{
    [shapeController addPoint:pointA andPoint:pointB];
}// addPoint:andPoint:


- (void) addLastPoint:(CGPoint) lastPoint
{
    [shapeController addLastPoint:lastPoint];
    
    // Analyze a recognize the figure
    [self getFigurePainted];
    
}// addLastPoint:

@end