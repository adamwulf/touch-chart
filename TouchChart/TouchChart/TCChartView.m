//
//  TCChartView.m
//  TouchChart
//
//  Created by Adam Wulf on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TCChartView.h"
#import "Constants.h"

@implementation TCChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

CGFloat DistanceBetweenTwoPoints(CGPoint point1,CGPoint point2)
{
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy );
};






-(IBAction) cleanPoints{
    if([points count] < 3) return;
    debug_NSLog(@"===== cleaning %d points", [points count]);
    CGFloat prevSlope;
    for(int i=1;i<[points count];i++){
        NSValue* v1 = [points objectAtIndex:i-1];
        CGPoint p1 = [v1 CGPointValue];
        NSValue* v2 = [points objectAtIndex:i];
        CGPoint p2 = [v2 CGPointValue];
        CGFloat slope = (p2.y - p1.y) / (p2.x - p1.x);
        if(slope < .1 && slope > -.1) slope = 0;
        if(slope < -20) slope = -20;
        if(slope > 20) slope = 20;
        if(i != 1){
            CGFloat diff = ABS(slope) - ABS(prevSlope);
//            if(prevSlope == 0){
//                diff = slope;
//            }
            if(diff > -5 && diff < 5){
                // same slope, basically
                // remove a point
                [points removeObjectAtIndex:i-1];
                i--;
            }else if(DistanceBetweenTwoPoints(p1, p2) < 20){
                [points removeObjectAtIndex:i-1];
                i--;
            }
        }
        prevSlope = slope;
    }
    debug_NSLog(@"===== done cleaning %d points", [points count]);
    [self setNeedsDisplay];
}


-(void) awakeFromNib{
    points = [[NSMutableArray alloc] init];
    pointsInThisLine = [[NSMutableArray alloc] init];
}

-(BOOL) isPoint:(CGPoint)point inSlopeOfLine:(NSMutableArray*)lineOfPoints{
    if([lineOfPoints count] < 2) return YES;
    
    CGFloat avgSlope = 0;
    BOOL wasMaxFloat = NO;
    BOOL wasMinFloat = NO;
    for(int i=1; i<[lineOfPoints count];i++){
        NSValue* v1 = [lineOfPoints objectAtIndex:i-1];
        NSValue* v2 = [lineOfPoints objectAtIndex:i];
        CGPoint p1 = [v1 CGPointValue];
        CGPoint p2 = [v2 CGPointValue];
        CGFloat slope = (p2.y - p1.y) / (p2.x - p1.x);
        if(slope < MAXFLOAT && slope > -MAXFLOAT){
            avgSlope += slope;
        }else if(slope >= MAXFLOAT){
            avgSlope += 20;
        }else if(slope <= -MAXFLOAT){
            avgSlope += -20;
        }
    }
    if(avgSlope == 0 && wasMaxFloat){
        avgSlope = MAXFLOAT;
    }else if(avgSlope == 0 && wasMinFloat){
        avgSlope = -MAXFLOAT;
    }
    avgSlope = avgSlope / ([lineOfPoints count] - 1);
    if(avgSlope > 20){
        avgSlope = MAXFLOAT;
    }else if(avgSlope < -20){
        avgSlope = -MAXFLOAT;
    }
    
    
    int index = MAX((int)[lineOfPoints count] - 5, (int)0);
    NSValue* lastV = [lineOfPoints objectAtIndex:index];
    CGPoint lastP = [lastV CGPointValue];
    CGFloat slope = (point.y - lastP.y) / (point.x - lastP.x);
    if(slope > 20) slope = 20;
    if(slope < -20) slope = -20;
    
    
    CGFloat diff = ABS(slope - avgSlope) / ABS(avgSlope);
    if(avgSlope == 0){
        diff = slope;
    }
    
    debug_NSLog(@"slope of line: %f vs %f = %f", avgSlope, slope, diff);
    debug_NSLog(@"log of slopes: %f vs %f = %f", log(avgSlope), log(slope), diff);
    
    if(diff > -0.5 && diff < 0.5){
        // it's ok, it's the same line
        return YES;
    }else{
        // it's a different line
        return NO;
    }
}




- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [points removeAllObjects];
    [pointsInThisLine removeAllObjects];
	[super touchesCancelled:touches withEvent:event];
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [points removeAllObjects];
    [points addObject:[NSValue valueWithCGPoint:[[touches anyObject] locationInView:self]]];
    [pointsInThisLine addObject:[NSValue valueWithCGPoint:[[touches anyObject] locationInView:self]]];
	[super touchesBegan:touches withEvent:event];
	debug_NSLog(@"touch began");
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if([self isPoint:[[touches anyObject] locationInView:self] inSlopeOfLine:pointsInThisLine]){
        CGPoint newP = [[touches anyObject] locationInView:self];
        if(DistanceBetweenTwoPoints([[pointsInThisLine lastObject] CGPointValue], newP) < 4){
            [pointsInThisLine removeLastObject];
        }
        [pointsInThisLine addObject:[NSValue valueWithCGPoint:newP]];
    }else{
        [points addObject:[NSValue valueWithCGPoint:[[touches anyObject] locationInView:self]]];
        [pointsInThisLine removeAllObjects];
        [pointsInThisLine addObject:[NSValue valueWithCGPoint:[[touches anyObject] locationInView:self]]];
    }
	[super touchesMoved:touches withEvent:event];
    [self cleanPoints];
    [self setNeedsDisplay];
	debug_NSLog(@"touch moved: points: %d", [points count]);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [points addObject:[pointsInThisLine lastObject]];
    [pointsInThisLine removeAllObjects];
	debug_NSLog(@"touch ended");
	[super touchesEnded:touches withEvent:event];
    [self cleanPoints];
    [self setNeedsDisplay];
}



-(void) drawRect:(CGRect)rect{
    CGContextRef context    = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 2.0);
    
    if([points count] >= 1 || [pointsInThisLine count] > 1){
        NSValue* start = [points objectAtIndex:0];
        CGPoint startP = [start CGPointValue];
        
        CGContextMoveToPoint(context, startP.x, startP.y); //start at this point
        
        for(int i=1;i<[points count];i++){
            NSValue* v = [points objectAtIndex:i];
            CGPoint p = [v CGPointValue];
            CGContextAddLineToPoint(context, p.x, p.y); //draw to this point
        }
        
        if([pointsInThisLine count]){
            NSValue* v = [pointsInThisLine lastObject];
            CGPoint p = [v CGPointValue];
            CGContextAddLineToPoint(context, p.x, p.y); //draw to this point
        }
        
        CGContextAddLineToPoint(context, startP.x, startP.y); //draw to this point
    }

    // and now draw the Path!
    CGContextStrokePath(context);
}



@end
