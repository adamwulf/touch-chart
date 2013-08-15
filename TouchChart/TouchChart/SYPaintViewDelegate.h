//
//  SYPaintViewDelegate.h
//  TouchChart
//
//  Created by Adam Wulf on 8/15/13.
//
//

#import <Foundation/Foundation.h>

@protocol SYPaintViewDelegate <NSObject>

- (void) addPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;
- (void) addLastPoint:(CGPoint) lastPoint;
-(void) resetData;

@end
