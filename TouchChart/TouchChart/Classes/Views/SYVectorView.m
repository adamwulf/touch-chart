//
//  SYVectorView.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 14/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import "SYVectorView.h"
#import "SYGeometry.h"
#import "SYShape.h"

@implementation SYVectorView

#define pointSize 14.0
#define pointBlueWidth 1.5

@synthesize shapeList;

- (void) awakeFromNib
{
    self.shapeList = [NSMutableArray array];
    
}// awakeFromNib


#pragma mark - Shapes List Management

- (void) addShape:(SYShape *)shape
{
    [shapeList addObject:shape];
    
}// addShape


- (IBAction) clear:(id)sender
{
    self.shapeList = [NSMutableArray array];
    [self setNeedsDisplay];
    
}// clear


- (void) drawRect: (CGRect)rect
{
    // draw the path
    UIColor *colorFillPoints = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1.0];
    UIColor *colorStrokePoints = [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
    
    for (SYShape *shape in shapeList) {
        for (SYGeometry *geometry in [shape geometries]) {
            if ([geometry geometryType] == LinesType) {
                
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
                
                for (int i = 0; i < [[geometry pointArray]count] ; i++) {
                    CGPoint point = [[[geometry pointArray]objectAtIndex:i]CGPointValue];
                    
                    // create a oval bezier path using the rect
                    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x - (pointSize * 0.5), point.y - (pointSize * 0.5), pointSize, pointSize)];
                    [path setLineWidth:1.5];
                    
                    // draw the path
                    [colorFillPoints set];
                    [path fill];
                    
                    [colorStrokePoints set];
                    [path stroke];
                }
            }
            else if ([geometry geometryType] == BezierType) {
                
                NSDictionary *dictPoints = [geometry.pointArray objectAtIndex:0];
                CGPoint startPoint = [[dictPoints valueForKey:@"t0Point"]CGPointValue];
                CGPoint endPoint = [[dictPoints valueForKey:@"t3Point"]CGPointValue];
                
                CGPoint firstCP = [[dictPoints valueForKey:@"cPointA"]CGPointValue];
                CGPoint secondCP = [[dictPoints valueForKey:@"cPointB"]CGPointValue];
                
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
                path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(startPoint.x - (pointSize * 0.5), startPoint.y - (pointSize * 0.5), pointSize, pointSize)];
                [path setLineWidth:pointBlueWidth];
                
                // draw the path
                [colorFillPoints set];
                [path fill];
                
                [colorStrokePoints set];
                [path stroke];
                
                
                // End points
                path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(endPoint.x - (pointSize * 0.5), endPoint.y - (pointSize * 0.5), pointSize, pointSize)];
                [path setLineWidth:pointBlueWidth];
                
                // draw the path
                [colorFillPoints set];
                [path fill];
                
                [colorStrokePoints set];
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
                
                
                for (int i = 1 ; i < [geometry.pointArray count] ; i++) {
                    
                    NSDictionary *dictPoints = [geometry.pointArray objectAtIndex:i];
                    
                    CGPoint startPoint = [[dictPoints valueForKey:@"t0Point"]CGPointValue];
                    CGPoint endPoint = [[dictPoints valueForKey:@"t3Point"]CGPointValue];
                    
                    CGPoint firstCP = [[dictPoints valueForKey:@"cPointA"]CGPointValue];
                    CGPoint secondCP = [[dictPoints valueForKey:@"cPointB"]CGPointValue];
                    
                    // Bezier lines
                    UIBezierPath * path = [UIBezierPath bezierPath];
                    [path moveToPoint: startPoint];
                    
                    [path addCurveToPoint: endPoint
                            controlPoint1: firstCP
                            controlPoint2: secondCP];
                    
                    [path setLineWidth:[geometry lineWidth]];
                    [[UIColor clearColor] set];
                    [path fill];
                    
                    [colorStrokePoints set];
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
                    
                    
                    // Start points
                    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(startPoint.x - 5.0, startPoint.y - 5.0, 10.0, 10.0)];
                    [path setLineWidth:pointBlueWidth];
                    
                    [colorFillPoints set];
                    [path fill];
                    
                    [colorStrokePoints set];
                    [path stroke];
                    
                    
                    // End points
                    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(endPoint.x - 5.0, endPoint.y - 5.0, 10.0, 10.0)];
                    [path setLineWidth:pointBlueWidth];
                    
                    [colorFillPoints set];
                    [path fill];
                    
                    [colorStrokePoints set];
                    [path stroke];
                    
                }
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
    }
    
}// drawRect:


- (void) dealloc
{
    [shapeList release];
    [super dealloc];
    
}// dealloc

@end
