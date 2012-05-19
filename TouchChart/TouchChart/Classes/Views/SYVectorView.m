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

@synthesize shapeList;

- (void) awakeFromNib
{
    self.shapeList = [[NSMutableArray alloc]init];
    
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
        }
        else if ([geometry geometryType] == CircleType) {
            // create a oval bezier path using the rect
            UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:[geometry rectGeometry]];
            [path setLineWidth:[geometry lineWidth]];	
            
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
        }
    }

}// drawRect:


- (void) dealloc
{
    [shapeList release];
    [super dealloc];
    
}// dealloc

@end
