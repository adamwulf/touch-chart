//
//  SYGeometry.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 16/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SYGeometry.h"

@implementation SYGeometry

@synthesize geometryType;
@synthesize rectGeometry;
@synthesize pointArray;

@synthesize lineWidth;
@synthesize fillColor;
@synthesize strokeColor;

@synthesize transform;

-(void) dealloc
{
    [fillColor release];
    [strokeColor release];
    
    [super dealloc];
    
}// dealloc


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

#pragma mark - Setter

- (void) setArcParametersWithMidPoint:(CGPoint) midPoint radius:(CGFloat) radius startAngle:(CGFloat) startAngle endAngle:(CGFloat) endAngle andClockWise:(BOOL) clockwise
{
    arcMidPoint = midPoint;
    arcRadius = radius;
    arcStartAngle = startAngle;
    arcEndAngle = endAngle;
    arcClockwise = clockwise;
    
}// setArcParametersWithRadius:startAngle:endAngle:andClockWise:


#pragma mark - Getter

- (CGPoint) midPoint
{
    return arcMidPoint;
    
}// radius


- (CGFloat) radius
{
    return arcRadius;
    
}// radius


- (CGFloat) startAngle
{
    return arcStartAngle;
    
}// radius


- (CGFloat) endAngle
{
    return arcEndAngle;
    
}// radius


- (CGFloat) clockwise
{
    return arcClockwise;
    
}// radius

@end
