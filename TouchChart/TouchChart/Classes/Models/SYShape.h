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

@property (nonatomic, assign) BOOL closeCurve;
@property (nonatomic, assign) BOOL openCurve;

// Adding Elements
- (void) addPoint:(CGPoint) keyPoint;
- (void) addKeyPoint:(CGPoint) keyPoint;
- (void) addPolygonalFromSegment:(SYSegment *) segment;
- (void) addCurve:(NSArray *) curvePoints;
- (void) addCircle:(CGRect) circleRect;
- (void) addCircleWithRect:(CGRect) rect andTransform:(CGAffineTransform) transform;
- (void) addArc:(CGPoint) midPoint radius:(NSUInteger) radius startAngle:(CGFloat) startAngle endAngle:(CGFloat) endAngle clockwise:(BOOL) clockwise;

// Modify shape
- (void) snapLinesAngles;
- (void) checkCloseShape;

// Replace Elements
- (void) replaceElementAtIndex:(NSUInteger) index withElement:(id) element;
- (void) replaceLastElementWithElement:(id) element;

- (SYGeometry *) getElement:(NSUInteger) index;
- (SYGeometry *) getLastElement;

// Get elements
- (NSArray *) geometries;

// Other Methods
- (CGPoint) midPointBetweenPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;

@end
