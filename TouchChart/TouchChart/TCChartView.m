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


//
// http://stackoverflow.com/questions/1211212/how-to-calculate-an-angle-from-three-points
CGFloat GetAngle(CGPoint vertex, CGPoint point2, CGPoint point3){
    
    // cos-1((P122 + P132 - P232)/(2 * P12 * P13))
    
    CGFloat P12 = DistanceBetweenTwoPoints(vertex, point2);
    CGFloat P13 = DistanceBetweenTwoPoints(vertex, point3);
    CGFloat P23 = DistanceBetweenTwoPoints(point2, point3);

    
    CGFloat num = P12 * P12 + P13 * P13 - P23 * P23;
    CGFloat den = 2 * P12 * P13;
    CGFloat total = num / den;
    CGFloat ret = acosf(total);
    return ret;
};


/*
;;

Public Function GetAngle(ByVal Ax As Single, ByVal Ay As _
                         Single, ByVal Bx As Single, ByVal By As Single, ByVal _
                         Cx As Single, ByVal Cy As Single) As Single
Dim dot_product As Single
Dim cross_product As Single

' Get the dot product and cross product.
dot_product = DotProduct(Ax, Ay, Bx, By, Cx, Cy)
cross_product = CrossProductLength(Ax, Ay, Bx, By, Cx, _
                                   Cy)

' Calculate the angle.
GetAngle = ATan2(cross_product, dot_product)
End Function 


*/



-(void) cleanPointsALot{
    if([points count] < 3) return;
    debug_NSLog(@"===== cleaning %d points", [points count]);
    
    for(int i=0;i<[points count];i++){
        int prev = ([points count] + i - 1) % [points count];
        NSValue* v1 = [points objectAtIndex:prev];
        CGPoint p1 = [v1 CGPointValue];
        NSValue* v2 = [points objectAtIndex:i];
        CGPoint p2 = [v2 CGPointValue];
        
        // check how far away the point is from straight across
        CGPoint p3 = CGPointMake(p2.x, p1.y);
        CGFloat angle = GetAngle(p1, p2, p3);
        if(angle / M_PI < 0.08){
            // pretty straight!
            [points removeObjectAtIndex:i];
            [points insertObject:[NSValue valueWithCGPoint:p3] atIndex:i];
        }
        
        // check up/down
        p3 = CGPointMake(p1.x, p2.y);
        angle = GetAngle(p1, p2, p3);
        if(angle / M_PI < 0.08){
            // pretty straight!
            [points removeObjectAtIndex:i];
            [points insertObject:[NSValue valueWithCGPoint:p3] atIndex:i];
        }
    }
    [self cleanPoints];
}



-(IBAction) cleanPoints{
    if([points count] < 3) return;
    debug_NSLog(@"===== cleaning %d points", [points count]);
    for(int i=2;i<[points count];i++){
        
        NSValue* v1 = [points objectAtIndex:i-2];
        CGPoint p1 = [v1 CGPointValue];
        NSValue* v2 = [points objectAtIndex:i-1];
        CGPoint p2 = [v2 CGPointValue];
        NSValue* v3 = [points objectAtIndex:i];
        CGPoint p3 = [v3 CGPointValue];
        
        CGFloat angle = GetAngle(p2, p1, p3);
        
        if(angle / M_PI > 0.80){
            [points removeObjectAtIndex:i-1];
            i--;
        }
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
    
    
    CGPoint lastValidPoint = [[lineOfPoints lastObject] CGPointValue];
    CGPoint pointOnFirstLine = [[lineOfPoints objectAtIndex:0] CGPointValue];
    CGPoint potentialPoint = point;
    

    CGFloat angle = GetAngle(lastValidPoint, pointOnFirstLine, potentialPoint);
    
    NSLog(@"angle between is hopefully near pi, maybe -pi: %f vs %f", angle, angle/M_PI);
    
    if(ABS(angle/M_PI) > 0.90){
        return YES;
    }
    return NO;
    
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
    [self cleanPointsALot];
    [self setNeedsDisplay];
}



-(void) drawRect:(CGRect)rect{
    if([points count] >= 1 || [pointsInThisLine count] > 1){
        CGContextRef context    = UIGraphicsGetCurrentContext();
        
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        

        
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

    
        
        // and now draw the Path!
        CGContextStrokePath(context);
    
    
        for(int i=0;i<[points count];i++){
            [self drawDotAt:[[points objectAtIndex:i] CGPointValue]];
        }
        
    }
}

-(void) drawDotAt:(CGPoint)currPoint{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    // (3) Create the gradient to paint the anchor points.
    CGFloat colors [] = { 
        0.4, 0.8, 1.0, 1.0, 
        0.0, 0.0, 1.0, 1.0
    };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    // (4) Set up the stroke for drawing the border of each of the anchor points.
    CGContextSetLineWidth(context, 1);
    CGContextSetShadow(context, CGSizeMake(0.5, 0.5), 1);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGRect currRect = CGRectMake(currPoint.x-5, currPoint.y-5, 10, 10);
    
    // (5) Fill each anchor point using the gradient, then stroke the border.
    CGContextSaveGState(context);
    CGContextAddEllipseInRect(context, currRect);
    CGContextClip(context);
    CGPoint startPoint = CGPointMake(CGRectGetMidX(currRect), CGRectGetMinY(currRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(currRect), CGRectGetMaxY(currRect));
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    CGContextStrokeEllipseInRect(context, CGRectInset(currRect, 1, 1));

    CGGradientRelease(gradient), gradient = NULL;
    CGContextRestoreGState(context);

}





@end
