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


- (NSString *) description
{
    NSMutableString *desc = [NSMutableString string];
    if (self.geometryType == SquareType)
         [desc appendString:@"\nGeometryType: Square"];
    if (self.geometryType == CircleType)
        [desc appendString:@"\nGeometryType: Circle"];
    if (self.geometryType == DiamondType)
        [desc appendString:@"\nGeometryType: DiamondType"];
    if (self.geometryType == TriangleType)
        [desc appendString:@"\nGeometryType: TriangleType"];
    if (self.geometryType == LinesType)
        [desc appendString:@"\nGeometryType: LinesType"];
    if (self.geometryType == BezierType)
        [desc appendString:@"\nGeometryType: BezierType"];
    if (self.geometryType == ArcType)
        [desc appendString:@"\nGeometryType: ArcType"];
    
    [desc appendFormat:@"\nPoint Array: %@", pointArray];
    [desc appendFormat:@"\nLine Width: %f", lineWidth];
    [desc appendFormat:@"\nColor fill: %@", fillColor];
    [desc appendFormat:@"\nColor Stroke: %@", strokeColor];
    
    return desc;
    
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
