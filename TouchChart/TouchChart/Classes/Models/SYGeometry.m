//
//  SYGeometry.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 16/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SYGeometry.h"
#import "SYBezier.h"
#import "SYSegment.h"

@implementation SYGeometry

@synthesize geometryType;
@synthesize pointArray;

@synthesize lineWidth;
@synthesize fillColor;
@synthesize strokeColor;


- (NSString *) description
{
    NSMutableString *desc = [NSMutableString string];
    
    if (self.geometryType == SquareType)
        [desc appendString:@"type: Square"];
    else if (self.geometryType == CircleType)
        [desc appendFormat:@"type: CircleType: (%f, %f)", rectGeometry.origin.x, rectGeometry.origin.y];
    else if (self.geometryType == LinesType)
        [desc appendString:@"type: LinesType"];
    else if (self.geometryType == BezierType)
        [desc appendString:@"type: BezierType"];
    else if (self.geometryType == ArcType)
        [desc appendString:@"type: ArcType"];
    
    return [NSString stringWithString:desc];
}// description


- (id) init
{
    self = [super init];
    
    if (self) {
        // Draw properties
        lineWidth = 4.0;
        self.fillColor = [UIColor clearColor];
        self.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
                
        // Transforms
        transform = CGAffineTransformIdentity; 
    }
    
    return self;
    
}// init

- (id) initCircleInRect:(CGRect)rect andTransform:(CGAffineTransform)_transform{
    if (self = [self init]) {
        // Draw properties
        geometryType = CircleType;
        rectGeometry = rect;
        transform = _transform;
    }
    
    return self;
}


- (id) initCircleInRect:(CGRect)rect
{
    return [self initCircleInRect:rect andTransform:CGAffineTransformIdentity];
}// init

- (id) initSquareInRect:(CGRect)rect
{
    if (self = [self init]) {
        // Draw properties
        geometryType = SquareType;
        rectGeometry = rect;
        pointArray = [NSArray arrayWithObjects:
                               [NSValue valueWithCGPoint:CGPointMake(rect.origin.x, rect.origin.y)],
                               [NSValue valueWithCGPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y)],
                               [NSValue valueWithCGPoint:CGPointMake(rect.origin.x, rect.origin.y + rect.size.height)],
                               [NSValue valueWithCGPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)],
                               nil];
    }
    
    return self;
    
}// init


- (id) initWithSegmentFrom:(CGPoint)point1 to:(CGPoint)point2
{
    if (self = [self init]) {
        // Draw properties
        geometryType = LinesType;
        pointArray = [NSArray arrayWithObjects:
                           [NSValue valueWithCGPoint:point1],
                           [NSValue valueWithCGPoint:point2],
                           nil];
    }
    
    return self;
    
}// init

- (id) initWithSegment:(SYSegment*) segment
{
    return [self initWithSegmentFrom:segment.pointSt to:segment.pointFn];
}// init

- (id) initWithBezierCurves:(NSArray*)curves
{
    if (self = [self init]) {
        // Draw properties
        geometryType = BezierType;
        pointArray = curves;
    }
    
    return self;
    
}// init

- (id) initWithRotatedRectangleFrom:(CGPoint)point1 to:(CGPoint)point2 to:(CGPoint)point3 to:(CGPoint)point4
{
    if (self = [self init]) {
        // Draw properties
        geometryType = LinesType;
        pointArray = [NSArray arrayWithObjects:
                           [NSValue valueWithCGPoint:point1],
                           [NSValue valueWithCGPoint:point2],
                           [NSValue valueWithCGPoint:point3],
                           [NSValue valueWithCGPoint:point4],
                           nil];
    }
    
    return self;
    
}// init


- (id) initArcWithMidPoint:(CGPoint) midPoint radius:(CGFloat) radius startAngle:(CGFloat) startAngle endAngle:(CGFloat) endAngle andClockWise:(BOOL) clockwise
{
    if (self = [self init]) {
        // Draw properties
        geometryType = ArcType;
        
        arcMidPoint = midPoint;
        arcRadius = radius;
        arcStartAngle = startAngle;
        arcEndAngle = endAngle;
        arcClockwise = clockwise;
    }
    
    return self;
    
}// init



#pragma mark - Bezier Path

-(UIBezierPath*) bezierPath{
    if ([self geometryType] == LinesType) {
        CGPoint pointA = [[[self pointArray]objectAtIndex:0]CGPointValue];
        
        // Drawing code
        UIBezierPath * path = [UIBezierPath bezierPath];
        [path moveToPoint:pointA];
        
        for (int i = 0; i < [[self pointArray]count] ; i++) {
            CGPoint pointB = [[[self pointArray]objectAtIndex:i]CGPointValue];
            [path addLineToPoint:pointB];
        }
        
        [path setLineWidth:[self lineWidth]];
        return path;
    }else if ([self geometryType] == BezierType) {
        
        SYBezier *bezier = [self.pointArray objectAtIndex:0];
        // Bezier lines
        UIBezierPath * path = [UIBezierPath bezierPath];
        [path moveToPoint: bezier.t0Point];
        
        [path addCurveToPoint: bezier.t3Point
                controlPoint1: bezier.cPointA
                controlPoint2: bezier.cPointB];
        
        [path setLineWidth:[self lineWidth]];
        
        CGPoint lastEndingPoint = bezier.t3Point;
        for (int i = 1 ; i < [self.pointArray count] ; i++) {
            
            SYBezier *bezier = [self.pointArray objectAtIndex:i];
            
            // Bezier lines
            if(!CGPointEqualToPoint(bezier.t0Point, lastEndingPoint)){
                // we only need to move to if our start isn't where
                // we left off on the previous bezier
                [path moveToPoint: bezier.t0Point];
            }
            [path addCurveToPoint: bezier.t3Point
                    controlPoint1: bezier.cPointA
                    controlPoint2: bezier.cPointB];
            lastEndingPoint = bezier.t3Point;
        }
        return path;
    }
    else if ([self geometryType] == CircleType) {
        // create a oval bezier path using the rect
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rectGeometry];
        [path setLineWidth:[self lineWidth]];
        [path applyTransform:transform];
        
        return path;
    }
    else if ([self geometryType] == ArcType) {
        
        // Drawing code
        UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:arcMidPoint
                                                             radius:arcRadius
                                                         startAngle:arcStartAngle
                                                           endAngle:arcEndAngle
                                                          clockwise:arcClockwise];
        
        [path setLineWidth:[self lineWidth]];
        
//        [path applyTransform:[self transform]];
        
        return path;
    }
    else if ([self geometryType] == SquareType) {
        
        // Drawing code
        UIBezierPath * path = [UIBezierPath bezierPathWithRect:rectGeometry];
        [path setLineWidth:[self lineWidth]];
        
        return path;
    }
    return nil;
}




@end
