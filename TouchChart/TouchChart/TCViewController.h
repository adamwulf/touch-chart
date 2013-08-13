//
//  TCViewController.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 28/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYSaveMessageView;
@class SYUnitTestController;
@class SYPaintView;
@class SYVectorView;
@class SYSegment;
@class SYGeometry;
@class SYTableBase;
@class SYShape;

@interface TCViewController : UIViewController {
    
    // Views
    IBOutlet SYPaintView *paintView;
    IBOutlet SYVectorView *vectorView;
    
    // UI IBOutlets
    IBOutlet UIButton *openShapeButton;
    IBOutlet UIButton *closeShapeButton;
    
    IBOutlet SYSaveMessageView *selectCaseNameView;
    IBOutlet UITextField *nameTextField;
    IBOutlet SYTableBase *tableBase;

}

// Button Draw Modes
- (IBAction) switchDrawModes:(id)sender;

// Unit Test Methods
- (IBAction) switchShowTable:(id)sender;
- (void) drawOpenShape;
- (IBAction) selectName:(id)sender;
- (IBAction) saveCase:(id)sender;
- (IBAction) cancelCase:(id)sender;


// Management Data Operations
- (void) importCase:(NSArray *) allPoints;
- (void) resetData;
- (void) addPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;
- (void) addLastPoint:(CGPoint) lastPoint;

- (NSDictionary *) reducePointsKey;
- (void) snapLinesAnglesForShape:(SYShape *)shape;

// Basic Geometric calculations
- (CGFloat) distanceFrom:(CGPoint) pointTest toLineBuildForPoint:(CGPoint) pointKey andPoint:(CGPoint) pointNextKey;
- (CGFloat) distanceBetweenPoint:(CGPoint) point1 andPoint:(CGPoint) point2;
- (CGFloat) getAngleBetweenVertex:(CGPoint) vertex andPointA:(CGPoint) pointA andPointB:(CGPoint) pointB;
- (BOOL) point:(CGPoint)pointA andPoint:(CGPoint)pointB isAlignedWithPoint:(CGPoint)pointC;
- (BOOL) point:(CGPoint)pointA andPoint:(CGPoint)pointC isAlignedWithPoint:(CGPoint)pointB withDistance:(float) ratio;

// Auxiliar calculations
- (NSUInteger) getFactorial:(NSUInteger) intNumber;

// Analyze and Recognizer Geometry Methods
- (void) getFigurePainted;
- (BOOL) drawOvalCirclePainted;

// Draw Geometric Methods
- (void) drawBezierCurveWithPoints:(NSDictionary *) data;
- (void) drawBezierCurvesWithPoints:(NSArray *) arrayData;
- (void) drawPolygonal:(NSArray *) pointKeyList;
- (void) drawPolygonalFromSegment:(SYSegment *) segment;
- (void) drawSquare:(CGRect) squareRect;
- (void) drawDiamond:(CGRect) diamondRect;
- (void) drawCircle:(CGRect) circleRect;
- (void) drawPoint:(CGPoint) point;
- (void) drawCircleWithTransform:(CGAffineTransform) transform;
- (void) drawArc:(CGPoint) midPoint radius:(NSUInteger) radius startAngle:(CGFloat) startAngle endAngle:(CGFloat) endAngle clockwise:(BOOL) clockwise;

// Create Geometric Methods
- (SYGeometry *) createBezierCurveWithPoints:(NSDictionary *) data;
- (SYGeometry *) createBezierCurvesWithPoints:(NSArray *) arrayData;
- (SYGeometry *) createPolygonal:(NSArray *) pointKeyList;
- (SYGeometry *) createPolygonalFromSegment:(SYSegment *) segment;
- (SYGeometry *) createSquare:(CGRect) squareRect;
- (SYGeometry *) createDiamond:(CGRect) diamondRect;
- (SYGeometry *) createCircle:(CGRect) rect;
- (SYGeometry *) createCircleWithTransform:(CGAffineTransform) transform;
- (SYGeometry *) createArc:(CGPoint) midPoint radius:(NSUInteger) radius startAngle:(CGFloat) startAngle endAngle:(CGFloat) endAngle clockwise:(BOOL) clockwise;

@end
