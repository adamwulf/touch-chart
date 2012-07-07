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
            
            if([geometry.pointArray count] >= 4) {
                
                CGPoint startPoint = [[[geometry pointArray]objectAtIndex:0]CGPointValue];
                CGPoint endPoint = [[[geometry pointArray]objectAtIndex:3]CGPointValue];
                
                CGPoint firstCP = [[[geometry pointArray]objectAtIndex:1]CGPointValue];
                CGPoint secondCP = [[[geometry pointArray]objectAtIndex:2]CGPointValue];
                
                // Drawing code            
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
