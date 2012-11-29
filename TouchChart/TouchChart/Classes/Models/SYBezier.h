//
//  SYBezier.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 29/11/12.
//
//

#import <Foundation/Foundation.h>

@interface SYBezier : NSObject

@property (nonatomic, retain) NSArray *listPoints;
@property (nonatomic, assign) CGPoint t0Point;
@property (nonatomic, assign) CGPoint t1Point;
@property (nonatomic, assign) CGPoint t2Point;
@property (nonatomic, assign) CGPoint t3Point;
@property (nonatomic, assign) CGPoint cPointA;
@property (nonatomic, assign) CGPoint cPointB;
@property (nonatomic, assign) float errorRatio;

@end
