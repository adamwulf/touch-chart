//
//  SYVectorView.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 14/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import "SYVectorView.h"
#import "SYGeometry.h"

@implementation SYVectorView

#define pointBlueSize 14.0

@synthesize shapeList;

- (void) awakeFromNib
{
    self.shapeList = [NSMutableArray array];
    
}// awakeFromNib


- (void) drawRect: (CGRect)rect
{
    for (SYGeometry *geometry in shapeList) {
        if ([geometry geometryType] == DiamondType) {
            
            CGRect rectGeometry = [geometry rectGeometry];
            
            UIBezierPath * path = [UIBezierPath bezierPath];
            [path setLineWidth:[geometry lineWidth]];
            
            [path  moveToPoint:CGPointMake(rectGeometry.origin.x + rectGeometry.size.width * 0.5 , rectGeometry.origin.y)];
            [path  addLineToPoint:CGPointMake(rectGeometry.origin.x + rectGeometry.size.width , rectGeometry.origin.y + rectGeometry.size.height * 0.5)];
            [path  addLineToPoint:CGPointMake(rectGeometry.origin.x + rectGeometry.size.width * 0.5 , rectGeometry.origin.y + rectGeometry.size.height)];
            [path  addLineToPoint:CGPointMake(rectGeometry.origin.x, rectGeometry.origin.y + rectGeometry.size.height * 0.5)];
            [path  addLineToPoint:CGPointMake(rectGeometry.origin.x + rectGeometry.size.width * 0.5 , rectGeometry.origin.y)];
            
            [[geometry fillColor] set];
            [path fill];
            
            [[geometry strokeColor] set]; 
            [path stroke];
            
            [path applyTransform:[geometry transform]];
        }
        else if ([geometry geometryType] == CircleType) {
            // create a oval bezier path using the rect
            UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:[geometry rectGeometry]];
            [path setLineWidth:[geometry lineWidth]];	

            [path applyTransform:[geometry transform]];
            
            // draw the path
            [[geometry fillColor] set];
            [path fill];
            
            [[geometry strokeColor] set]; 
            [path stroke];
            
            
        }
        else if ([geometry geometryType] == SquareType) {
            // Drawing code            
            UIBezierPath * path = [UIBezierPath bezierPathWithRect:[geometry rectGeometry]];
            [path setLineWidth:[geometry lineWidth]];
            
            [[geometry fillColor] set];
            [path fill];
            
            [[geometry strokeColor] set]; 
            [path stroke];
            
            [path applyTransform:[geometry transform]];
        }
        else if ([geometry geometryType] == TriangleType) {
            
            CGPoint pointA = [[[geometry pointArray]objectAtIndex:0]CGPointValue];
            CGPoint pointB = [[[geometry pointArray]objectAtIndex:1]CGPointValue];
            CGPoint pointC = [[[geometry pointArray]objectAtIndex:2]CGPointValue];
            
            // Drawing code            
            UIBezierPath * path = [UIBezierPath bezierPath];
            [path moveToPoint:pointA];
            [path addLineToPoint:pointB];
            [path addLineToPoint:pointC];
            [path setLineWidth:[geometry lineWidth]];
            
            [[geometry fillColor] set];
            [path fill];
            
            [[geometry strokeColor] set]; 
            [path stroke];
            
            [path applyTransform:[geometry transform]];
        }
        else if ([geometry geometryType] == LinesType) {
            
            CGPoint pointA = [[[geometry pointArray]objectAtIndex:0]CGPointValue];
            
            // Drawing code            
            UIBezierPath * path = [UIBezierPath bezierPath];
            [path moveToPoint:pointA];
            
            for (int i = 0; i < [[geometry pointArray]count] ; i++) {
                CGPoint pointB = [[[geometry pointArray]objectAtIndex:i]CGPointValue];
                [path addLineToPoint:pointB];
            }
            [path addLineToPoint:pointA];
            
            [path setLineWidth:[geometry lineWidth]];
            [[geometry fillColor] set];
            [path fill];
            
            [[geometry strokeColor] set]; 
            [path stroke];
            
            [path applyTransform:[geometry transform]];
            
            for (int i = 0; i < [[geometry pointArray]count] ; i++) {
                CGPoint point = [[[geometry pointArray]objectAtIndex:i]CGPointValue];
                
                // create a oval bezier path using the rect
                UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x - (pointBlueSize * 0.5), point.y - (pointBlueSize * 0.5), pointBlueSize, pointBlueSize)];
                [path setLineWidth:1.5];	
                
                // draw the path
                [[UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1.0] set];
                [path fill];
                
                [[UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0] set]; 
                [path stroke];
            }
        }
        else if ([geometry geometryType] == BezierType) {

            for (NSDictionary *dictPoints in geometry.pointArray) {
                CGPoint startPoint = [[dictPoints valueForKey:@"t0Point"]CGPointValue];
                CGPoint endPoint = [[dictPoints valueForKey:@"t3Point"]CGPointValue];
                
                CGPoint firstCP = [[dictPoints valueForKey:@"cPointA"]CGPointValue];
                CGPoint secondCP = [[dictPoints valueForKey:@"cPointB"]CGPointValue];
                
                CGPoint t1Point = [[dictPoints valueForKey:@"t1Point"]CGPointValue];
                CGPoint t2Point = [[dictPoints valueForKey:@"t2Point"]CGPointValue];
                
                // Bezier lines           
                UIBezierPath * path = [UIBezierPath bezierPath];
                [path moveToPoint: startPoint];
                
                [path addCurveToPoint: endPoint
                        controlPoint1: firstCP
                        controlPoint2: secondCP];
                
                [path setLineWidth:[geometry lineWidth]];
                [[geometry fillColor] set];
                [path fill];
                
                [[geometry strokeColor] set]; 
                [path stroke];
                
                
                // Start points            
                path = [UIBezierPath bezierPathWithRect:CGRectMake(startPoint.x - 5.0, startPoint.y - 5.0, 10.0, 10.0)];
                [path setLineWidth:[geometry lineWidth]];
                
                [[geometry fillColor] set];
                [path fill];
                
                [[geometry strokeColor] set]; 
                [path stroke];
                            
                
                // End points            
                path = [UIBezierPath bezierPathWithRect:CGRectMake(endPoint.x - 5.0, endPoint.y - 5.0, 10.0, 10.0)];
                [path setLineWidth:[geometry lineWidth]];
                
                [[geometry fillColor] set];
                [path fill];
                
                [[geometry strokeColor] set]; 
                [path stroke];

                
                // Control Point 1            
                path = [UIBezierPath bezierPathWithRect:CGRectMake(firstCP.x - 2.5, firstCP.y - 2.5, 5.0, 5.0)];
                [path setLineWidth:1.0];
                
                [[UIColor clearColor] set];
                [path fill];
                
                [[UIColor grayColor] set]; 
                [path stroke];
                
                
                // Line P0 - C1            
                path = [UIBezierPath bezierPath];
                [path moveToPoint:startPoint];
                [path addLineToPoint:firstCP];
                
                [path setLineWidth:1.0];
                [[UIColor grayColor] set];
                [path fill];
                
                [[UIColor grayColor] set]; 
                [path stroke];

                
                // Control Point 2            
                path = [UIBezierPath bezierPathWithRect:CGRectMake(secondCP.x - 2.5, secondCP.y - 2.5, 5.0, 5.0)];
                [path setLineWidth:1.0];
                
                [[UIColor clearColor] set];
                [path fill];
                
                [[UIColor grayColor] set]; 
                [path stroke];

                
                // Line P3 - C2            
                path = [UIBezierPath bezierPath];
                [path moveToPoint:endPoint];
                [path addLineToPoint:secondCP];
                
                [path setLineWidth:1.0];
                [[UIColor grayColor] set];
                [path fill];
                
                [[UIColor grayColor] set]; 
                [path stroke];
                
                
                // t1 point
                path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(t1Point.x - 2.5, t1Point.y - 2.5, 5.0, 5.0)];
                [path setLineWidth:1.0];	
                                
                // draw the path
                [[UIColor orangeColor] set];
                [path fill];
                
                [[UIColor orangeColor] set]; 
                [path stroke];
                
                
                // t2 point
                path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(t2Point.x - 2.5, t2Point.y - 2.5, 5.0, 5.0)];
                [path setLineWidth:1.0];	
                
                // draw the path
                [[UIColor orangeColor] set];
                [path fill];
                
                [[UIColor orangeColor] set]; 
                [path stroke];
            }
        }
        else if ([geometry geometryType] == ArcType) {
            
            // Drawing code            
            UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:[geometry midPoint]
                                                                 radius:[geometry radius]
                                                             startAngle:[geometry startAngle]
                                                               endAngle:[geometry endAngle]
                                                              clockwise:[geometry clockwise]];

            [path setLineWidth:[geometry lineWidth]];
            [[geometry fillColor] set];
            [path fill];
            
            [[geometry strokeColor] set]; 
            [path stroke];
            
            [path applyTransform:[geometry transform]];
        }
    }
    
}// drawRect:


- (void) dealloc
{
    [shapeList release];
    [super dealloc];
    
}// dealloc

@end
