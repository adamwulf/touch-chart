//
//  MMVector.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/11/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "SYVector.h"

// http://stackoverflow.com/questions/7854043/drawing-rectangle-between-two-points-with-arbitrary-width

@implementation SYVector{
    CGFloat x;
    CGFloat y;
}

@synthesize x, y;

+(SYVector*) vectorWithPoint:(CGPoint)p1 andPoint:(CGPoint)p2{
    return [[SYVector alloc] initWithPoint:p1 andPoint:p2];
}

+(SYVector*) vectorWithX:(CGFloat)x andY:(CGFloat)y{
    return [[SYVector alloc] initWithX:x andY:y];
}

+(SYVector*) vectorWithAngle:(CGFloat)angle{
    return [[SYVector alloc] initWithX:cosf(angle) andY:sinf(angle)];
}

-(id) initWithPoint:(CGPoint)p1 andPoint:(CGPoint)p2{
    if(self = [super init]){
        x = p2.x - p1.x;
        y = p2.y - p1.y;
    }
    return self;
}

-(id) initWithX:(CGFloat)_x andY:(CGFloat)_y{
    if(self = [super init]){
        x = _x;
        y = _y;
    }
    return self;
}

-(CGFloat) angle{
    CGFloat theta = atanf(y / x);
    BOOL isYNeg = y < 0;
    BOOL isXNeg = x < 0;
    
    // adjust the angle depending on which quadrant it's in
    if(isYNeg && isXNeg){
        theta -= M_PI;
    }else if(!isYNeg && isXNeg){
        theta += M_PI;
    }
    return theta;
}

-(SYVector*) normal{
    // just divide our x and y by our length
    CGFloat length = sqrt(x * x + y * y);
    return [SYVector vectorWithX:(x / length) andY:(y / length)];
}

-(SYVector*) normalizedTo:(CGFloat)someLength{
    return [SYVector vectorWithX:(x / someLength) andY:(y / someLength)];
}

-(SYVector*) perpendicular{
    // perp just swaps the x and y
    return [SYVector vectorWithX:-y andY:x];
}

-(CGFloat) magnitude{
    return sqrtf(self.x * self.x + self.y*self.y);
}

-(SYVector*) flip{
    // perp just swaps the x and y
    return [SYVector vectorWithX:-x andY:-y];
}

-(CGPoint) pointFromPoint:(CGPoint)point distance:(CGFloat)distance{
    return CGPointMake(point.x + x * distance,
                       point.y + y * distance);
}

-(SYVector*) averageWith:(SYVector*)vector{
    return [SYVector vectorWithX:(x + vector.x)/2 andY:(y + vector.y)/2];
}

-(SYVector*) addVector:(SYVector*)vector{
    return [SYVector vectorWithX:x + vector.x andY:y + vector.y];
}

-(SYVector*) rotateBy:(CGFloat)angle{
    CGFloat xprime = x * cosf(angle) - y * sinf(angle);
    CGFloat yprime = x * sinf(angle) + y * cosf(angle);
    return [SYVector vectorWithX:xprime andY:yprime];
}

-(SYVector*) mirrorAround:(SYVector*)normal{
    CGFloat dotprod =-x*normal.x-y*normal.y;
    CGFloat xprime =x+2*normal.x*dotprod;
    CGFloat yprime =y+2*normal.y*dotprod;
	return [SYVector vectorWithX:xprime andY:yprime];
}


-(CGPoint) mirrorPoint:(CGPoint)point aroundPoint:(CGPoint)startPoint{
    CGFloat dx,dy,a,b;
    CGFloat x2,y2;
    
    dx  = self.x;
    dy  = self.y;
    
    CGFloat x0 = startPoint.x;
    CGFloat y0 = startPoint.y;
           
    a   = (dx * dx - dy * dy) / (dx * dx + dy*dy);
    b   = 2 * dx * dy / (dx*dx + dy*dy);

    x2  = a * (point.x - x0) + b*(point.y - y0) + x0;
    y2  = b * (point.x - x0) - a*(point.y - y0) + y0;
    
    return CGPointMake(x2, y2);
}

-(CGFloat) angleBetween:(SYVector*)otherVector{
    // angle with +ve x-axis, in the range (−π, π]
    float thetaA = atan2(otherVector.x, otherVector.y);
    float thetaB = atan2(self.x, self.y);
    
    float thetaAB = thetaB - thetaA;
    
    // get in range (−π, π]
    while (thetaAB <= - M_PI)
        thetaAB += 2 * M_PI;
    
    while (thetaAB > M_PI)
        thetaAB -= 2 * M_PI;
    
    return thetaAB;
    
//    CGFloat scaler = self.x * otherVector.x + self.y * otherVector.y;
//    return acosf(scaler / (self.magnitude * otherVector.magnitude));
}

-(CGPoint) asCGPoint{
    return CGPointMake(self.x, self.y);
}

-(NSString*) description{
    return [@"[MMVector: " stringByAppendingFormat:@"%f %f]", self.x, self.y];
}

-(BOOL) isEqual:(id)object{
    if(object == self){
        return YES;
    }
    if([object isKindOfClass:[SYVector class]]){
        return self.x == [(SYVector*)object x] && self.y == [(SYVector*)object y];
    }
    return NO;
}

@end
