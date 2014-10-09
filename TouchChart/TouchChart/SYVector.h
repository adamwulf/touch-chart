//
//  MMVector.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/11/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYVector : NSObject

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;

+(SYVector*) vectorWithPoint:(CGPoint)p1 andPoint:(CGPoint)p2;

+(SYVector*) vectorWithX:(CGFloat)x andY:(CGFloat)y;

+(SYVector*) vectorWithAngle:(CGFloat)angle;

-(id) initWithPoint:(CGPoint)p1 andPoint:(CGPoint)p2;

-(id) initWithX:(CGFloat)x andY:(CGFloat)y;

-(SYVector*) normal;

-(SYVector*) normalizedTo:(CGFloat)someLength;

-(SYVector*) perpendicular;

-(SYVector*) flip;

-(CGFloat) magnitude;

-(CGFloat) angle;

-(CGPoint) pointFromPoint:(CGPoint)point distance:(CGFloat)distance;

-(SYVector*) averageWith:(SYVector*)vector;

-(SYVector*) addVector:(SYVector*)vector;

-(SYVector*) rotateBy:(CGFloat)angle;

-(SYVector*) mirrorAround:(SYVector*)normal;

-(CGPoint) mirrorPoint:(CGPoint)point aroundPoint:(CGPoint)startPoint;

-(CGFloat) angleBetween:(SYVector*)otherVector;

-(CGPoint) asCGPoint;
@end
