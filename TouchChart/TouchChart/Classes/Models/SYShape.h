//
//  SYShape.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 11/09/12.
//
//

#import <Foundation/Foundation.h>

@class SYSegment;
@class SYGeometry;

@interface SYShape : NSObject

@property (readonly, assign) BOOL closeCurve;
@property (readonly, assign) BOOL openCurve;

// Init
- (id) initWithBezierTolerance:(float) toleranceSlider;

// Setter Methods
- (void) setCloseCurve: (BOOL) isCloseCurve;
- (void) setOpenCurve:(BOOL)isOpenCurve;

// Getter Methods
- (NSUInteger) geometriesCount;
- (SYGeometry *) getElement:(NSUInteger) index;
- (SYGeometry *) getLastElement;
- (NSArray *) geometries;

// Adding Elements
- (void) addPoint:(CGPoint) keyPoint;
- (void) addKeyPoint:(CGPoint) keyPoint;
- (void) addPolygonalFromSegment:(SYSegment *) segment;
- (void) addCurvesForListPoints:(NSArray *) listPoints;
- (void) addCircle:(CGRect) circleRect;
- (void) addCircleWithRect:(CGRect) rect andTransform:(CGAffineTransform) transform;
- (void) addArc:(CGPoint) midPoint radius:(NSUInteger) radius startAngle:(CGFloat) startAngle endAngle:(CGFloat) endAngle clockwise:(BOOL) clockwise;
- (void) addRectangle:(CGRect)rect;
- (void) addRotateRectangle:(NSArray *) pointArray;
//- (void) addRectangle:(CGRect) rect andTransform:(CGAffineTransform) transform;

// Replace Elements
- (void) replaceElementAtIndex:(NSUInteger) index withElement:(id) element;
- (void) replaceLastElementWithElement:(id) element;

// Modify shape
- (void) snapLinesAngles;
- (void) closeShapeIfPossible;
- (void) forceContinuity:(float) sliderValue;

@end