//
//  SYBezierController.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 24/07/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import "SYBezierController.h"
#import "SYSegment.h"

@implementation SYBezierController

#pragma mark - Getter Curves

- (NSArray *) addPointBasedQuadraticBezier:(NSArray *) listPoints
{
    // If the list has more than 3 elements, it doesn't need more points
    if ([listPoints count] != 3)
        return nil;
    
    // We get C(t)
    CGFloat c[3];
    CGFloat currentLongitude = .0;
    c[0] = .0; 
    
    for (NSUInteger i = 1 ; i < 3 ; i++) {
        CGPoint previousPoint = [[listPoints objectAtIndex:i-1]CGPointValue];
        CGPoint currentPoint = [[listPoints objectAtIndex:i]CGPointValue];
        
        SYSegment *segment = [[SYSegment alloc]initWithPoint:previousPoint andPoint:currentPoint];
        currentLongitude += [segment longitude];
        c[i] = currentLongitude;
    }
    
    // Just divide c[n]/totalLongitude
    CGFloat totalLongitude = currentLongitude;
    for (NSUInteger i = 0 ; i < 3 ; i++)
        c[i] = c[i]/totalLongitude;
    
    // Para degree 2
    // ------------------------------
    CGFloat ctX = [[listPoints objectAtIndex:1]CGPointValue].x;
    CGFloat ctY = [[listPoints objectAtIndex:1]CGPointValue].y;
    
    CGFloat t = c[1];
    
    CGFloat p0X = [[listPoints objectAtIndex:0]CGPointValue].x;
    CGFloat p0Y = [[listPoints objectAtIndex:0]CGPointValue].y;

    CGFloat p3X = [[listPoints objectAtIndex:2]CGPointValue].x;
    CGFloat p3Y = [[listPoints objectAtIndex:2]CGPointValue].y;

    // Calculate control point for the quadratic bezier
    CGFloat mt = 1-t;
    CGFloat p1X = (ctX - (pow(mt, 2) * p0X) - (pow(t, 2) * p3X)) / (2*t*mt);
    CGFloat p1Y = (ctY - (pow(mt, 2) * p0Y) - (pow(t, 2) * p3Y)) / (2*t*mt);

    // We get other point from the quadratic bezier
    t = c[1] + ((1-c[1]) * 0.5); mt = 1-t;
    CGFloat ctX2 = (pow(mt, 2) * p0X) + (2*t*mt*p1X) + (pow(t, 2)*p3X);
    CGFloat ctY2 = (pow(mt, 2) * p0Y) + (2*t*mt*p1Y) + (pow(t, 2)*p3Y);
    CGPoint ctPoint = CGPointMake(ctX2, ctY2);
    
    NSMutableArray *newListPoint = [NSMutableArray arrayWithArray:listPoints];
    [newListPoint insertObject:[NSValue valueWithCGPoint:ctPoint] atIndex:2];
    
    return newListPoint;
    
}// addPointBasedQuadraticBezier:


- (NSArray *) getCubicBezierPointsForListPoint:(NSArray *) listPoints
{
    // If the list points has 1 point, return nil
    if ([listPoints count] == 1)
        return nil;
    
    // If the list points has 2 point, return line
    else if ([listPoints count] == 2) {
        
        NSValue *pointA = [listPoints objectAtIndex:0];
        NSValue *pointB = [listPoints objectAtIndex:1];
        
        // Save the points to the array to paint
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              pointA, @"t0Point",
                              pointA, @"cPointA",
                              pointB, @"cPointB",
                              pointB, @"t3Point",
                              pointA, @"t1Point",
                              pointB, @"t2Point",
                              [NSNumber numberWithFloat:.0], @"errorRatio", nil];
        
        return [NSArray arrayWithObject:dict];
    }
    // If the list points has 3 point, return quadratic bezier
    else if ([listPoints count] == 3)
        listPoints = [self addPointBasedQuadraticBezier:listPoints];
    
    
    // We get C(t)
    CGFloat c[[listPoints count]];
    CGFloat currentLongitude = .0;
    c[0] = .0;
    
    for (NSUInteger i = 1 ; i < [listPoints count] ; i++) {
        CGPoint previousPoint = [[listPoints objectAtIndex:i-1]CGPointValue];
        CGPoint currentPoint = [[listPoints objectAtIndex:i]CGPointValue];
        
        SYSegment *segment = [[SYSegment alloc]initWithPoint:previousPoint andPoint:currentPoint];
        currentLongitude += [segment longitude];
        c[i] = currentLongitude;
    }
    
    // Just divide c[n]/totalLongitude
    CGFloat totalLongitude = currentLongitude;
    for (NSUInteger i = 0 ; i < [listPoints count] ; i++)
        c[i] = c[i]/totalLongitude;
    
    
    // Para degree 3
    // ------------------------------
    // We need 'degree-1' C(t) values
    CGFloat cValue[4];
    CGPoint cPoint[4];
    CGFloat step = (float) [listPoints count] / 3;
    
    cValue[0] = 0.0;
    cPoint[0] = [[listPoints objectAtIndex:0]CGPointValue];
    cValue[3] = 1.0;
    cPoint[3] = [[listPoints lastObject]CGPointValue];
    
    
    // If the list points has 4 point, return quadratic bezier
    if ([listPoints count] == 4) {
        cValue[1] = c[1];
        cPoint[1] = CGPointMake([[listPoints objectAtIndex:1]CGPointValue].x,
                                [[listPoints objectAtIndex:1]CGPointValue].y);
        cValue[2] = c[2];
        cPoint[2] = CGPointMake([[listPoints objectAtIndex:2]CGPointValue].x,
                                [[listPoints objectAtIndex:2]CGPointValue].y);
    }
    else {
        //float numberPointsF = (float)[listPoints count];
        for (NSUInteger j = 1; j < 3; j++) {
            float indexF = (float) round(step * (j));
            NSUInteger index = (NSUInteger) indexF;

            cValue[j] = c[index];
            cPoint[j] = CGPointMake([[listPoints objectAtIndex:index]CGPointValue].x,
                                    [[listPoints objectAtIndex:index]CGPointValue].y);
        }
    }

    
    // We need create the matrix for solve the lineal equation
    // -------------------------------------------------------
    // Terminos a0, a1...
    float a[4] = {1, 3, 3, 1};
    
    // Matrix B
    double B[2];
    for (NSUInteger j = 0; j < 2; j++)
        B[j] = cPoint[j+1].x;
    
    B[0] = cPoint[1].x - (a[0] * pow(1 - cValue[1], 3) * cPoint[0].x) - (a[3] * pow(cValue[1], 3) * cPoint[3].x);
    B[1] = cPoint[2].x - (a[0] * pow(1 - cValue[2], 3) * cPoint[0].x) - (a[3] * pow(cValue[2], 3) * cPoint[3].x);
    
    // Matrix A
    double A[4];
    A[0] = a[1] * cValue[1] * pow(1 - cValue[1], 2);
    A[2] = a[2] * pow(cValue[1], 2) * (1 - cValue[1]);
    A[1] = a[1] * cValue[2] * pow(1 - cValue[2], 2);
    A[3] = a[2] * pow(cValue[2], 2) * (1 - cValue[2]);
    
    // Resolvemos la ecuacion
    int N = 2;
    int nrhs = 1;
    int lda = 2;
    int ipiv[2];
    int ldb = 2;
    int info;
    dgesv_(&N, &nrhs, A, &lda, &ipiv, B, &ldb, &info);
    
    // Store solutions
    CGPoint P1 = CGPointMake(B[0], .0);
    CGPoint P2 = CGPointMake(B[1], .0);
    
    // Procedemos igual para coordenadas Y
    // Matrix B
    for (NSUInteger j = 0; j < 2; j++)
        B[j] = cPoint[j+1].y;
    
    B[0] = cPoint[1].y - (a[0] * pow(1 - cValue[1], 3) * cPoint[0].y) - (a[3] * pow(cValue[1], 3) * cPoint[3].y);
    B[1] = cPoint[2].y - (a[0] * pow(1 - cValue[2], 3) * cPoint[0].y) - (a[3] * pow(cValue[2], 3) * cPoint[3].y);
    
    // Matrix A
    A[0] = a[1] * cValue[1] * pow(1 - cValue[1], 2);
    A[2] = a[2] * pow(cValue[1], 2) * (1 - cValue[1]);
    A[1] = a[1] * cValue[2] * pow(1 - cValue[2], 2);
    A[3] = a[2] * pow(cValue[2], 2) * (1 - cValue[2]);
    
    // Resolvemos la ecuacion
    N = 2;
    nrhs = 1;
    lda = 2;
    ldb = 2;
    dgesv_(&N, &nrhs, A, &lda, &ipiv, B, &ldb, &info);
    
    // Store solutions
    P1 = CGPointMake(P1.x, B[0]);
    P2 = CGPointMake(P2.x, B[1]);
    if (P1.x==0 || P1.y==0 || P2.x==0 || P2.y==0)
        NSLog(@"error");
    
    // Statistics Curve Fit
    CGFloat ratio = .0;
    for (NSUInteger i = 1 ; i < [listPoints count] ; i++) {
        CGPoint originalPaintedPoint = [[listPoints objectAtIndex:i]CGPointValue];
        CGFloat t = c[i];
        
        // Point from fast bezier
        CGFloat fastBezierPointX = powf(1-t, 3) * cPoint[0].x + 3 * powf(1-t, 2) * t * P1.x + 3 * (1-t) * powf(t, 2) * P2.x + powf(t, 3) * cPoint[3].x;
        CGFloat fastBezierPointY = powf(1-t, 3) * cPoint[0].y + 3 * powf(1-t, 2) * t * P1.y + 3 * (1-t) * powf(t, 2) * P2.y + powf(t, 3) * cPoint[3].y;
        CGPoint fastBezierPoint = CGPointMake(fastBezierPointX, fastBezierPointY);
                
        SYSegment *segment = [[SYSegment alloc]initWithPoint:originalPaintedPoint andPoint:fastBezierPoint];
        ratio += [segment longitude] / totalLongitude;
        [segment release];
    }
    
    // Error medio por cada punto
    ratio /= [listPoints count];
    
    // Save the points to the array to paint
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSValue valueWithCGPoint:cPoint[0]], @"t0Point",
                          [NSValue valueWithCGPoint:P1], @"cPointA",
                          [NSValue valueWithCGPoint:P2], @"cPointB",
                          [NSValue valueWithCGPoint:cPoint[3]], @"t3Point",
                          [NSValue valueWithCGPoint:cPoint[1]], @"t1Point",
                          [NSValue valueWithCGPoint:cPoint[2]], @"t2Point",
                          [NSNumber numberWithFloat:ratio], @"errorRatio", nil];
    
    return [NSArray arrayWithObject:dict];
    
}// getCubicBezierPointsForListPoint:


- (NSArray *) getCubicBezierPointsForListPoint:(NSArray *) listPoints
                                       splitIn:(NSUInteger) ntimes
{    
    if (ntimes == 0)
        return [self getCubicBezierPointsForListPoint:listPoints];
    
    NSMutableArray *curves = [NSMutableArray array];
    NSUInteger splitParts = [listPoints count] * 1/ntimes;
        
    for (NSUInteger i = 0; i < ntimes; i++) {
        
        NSMutableArray *splitList = [NSMutableArray array];
        if (i == 0) {
            for (NSUInteger j = i * splitParts; j < ((i+1) * splitParts); j++)
                [splitList addObject:[listPoints objectAtIndex:j]];
        }
        else if (i == ntimes - 1) {
            for (NSUInteger j = (i * splitParts) - 1; j < [listPoints count]; j++)
                [splitList addObject:[listPoints objectAtIndex:j]];
        }
        else {
            for (NSUInteger j = (i * splitParts) - 1; j < ((i+1) * splitParts); j++)
                [splitList addObject:[listPoints objectAtIndex:j]];
        }
        
        // If there isn't enough points, exit
        if ([splitList count] == 3)
            splitList = [NSMutableArray arrayWithArray:[self addPointBasedQuadraticBezier:splitList]];
        else if ([splitList count] < 4)
            NSLog(@"Error");

        NSArray *array = [self getCubicBezierPointsForListPoint:splitList];
        
        // Store solutions
        CGPoint cPoint[4] = {[[[array objectAtIndex:0] valueForKey:@"t0Point"]CGPointValue],
            [[[array objectAtIndex:0] valueForKey:@"t1Point"]CGPointValue],
            [[[array objectAtIndex:0] valueForKey:@"t2Point"]CGPointValue],
            [[[array objectAtIndex:0] valueForKey:@"t3Point"]CGPointValue]};
        CGPoint P1 = [[[array objectAtIndex:0] valueForKey:@"cPointA"]CGPointValue];
        CGPoint P2 = [[[array objectAtIndex:0] valueForKey:@"cPointB"]CGPointValue];
        
        // Continuity
//      if (i != 0/* && i != ntimes-1*/) {
        /*
        if (i != 0) {
            // Compare with the previous curve
            NSMutableDictionary *curve = [NSMutableDictionary dictionaryWithDictionary:[curves objectAtIndex:i-1]];
            
            // Get the last control point in the last curve stored.
            // I have to do the inverse conversion
            CGPoint controlPointEndPrevious = CGPointMake([[curve valueForKey:@"cPointB"]CGPointValue].x,
                                                          [[curve valueForKey:@"cPointB"]CGPointValue].y);
            
            // Get pivotal (the last point in this
            CGPoint controlPointStartCurrent = P1;
            CGPoint pivotalPoint = [[splitList objectAtIndex:0]CGPointValue];
            
            // Slope for the first CP
            CGFloat deltaX1 = controlPointEndPrevious.x - pivotalPoint.x;
            CGFloat deltaY1 = controlPointEndPrevious.y - pivotalPoint.y;
            CGFloat m1 = deltaY1/deltaX1;
            
            // Slope for the second CP
            CGFloat deltaX2 = controlPointStartCurrent.x - pivotalPoint.x;
            CGFloat deltaY2 = controlPointStartCurrent.y - pivotalPoint.y;
            CGFloat m2 = deltaY2/deltaX2;
            
            // Get the average value
            CGFloat mMid = (fabsf(m1) + fabsf(m2)) * 0.5;
        }
        */
        
        if (i != 0) {
            
            // Compare with the previous curve
            NSMutableDictionary *curve = [NSMutableDictionary dictionaryWithDictionary:[curves objectAtIndex:i-1]];
            
            // Get the last control point in the last curve stored.
            // I have to do the inverse conversion
            CGPoint controlPointEndPrevious = CGPointMake([[curve valueForKey:@"cPointB"]CGPointValue].x,
                                                          [[curve valueForKey:@"cPointB"]CGPointValue].y);
            
            // Get pivotal (the last point in this
            CGPoint controlPointStartCurrent = P1;
            CGPoint pivotalPoint = [[splitList objectAtIndex:0]CGPointValue];
            
            // Regula la X
            CGFloat deltaX1 = controlPointEndPrevious.x - pivotalPoint.x;
            CGFloat deltaX2 = controlPointStartCurrent.x - pivotalPoint.x;
            CGFloat deltaFinalX = (fabsf(deltaX1) + fabsf(deltaX2)) * 0.5;

            // Regula la Y
            CGFloat deltaY1 = controlPointEndPrevious.y - pivotalPoint.y;
            CGFloat deltaY2 = controlPointStartCurrent.y - pivotalPoint.y;
            CGFloat deltaFinalY = (fabsf(deltaY1) + fabsf(deltaY2)) * 0.5;
            
            // Control Points Resultantes
            CGFloat controlPointEndPreviousX = pivotalPoint.x;
            CGFloat controlPointStartCurrentX = pivotalPoint.x;
            if (deltaX1 > .0) {
                controlPointEndPreviousX += deltaFinalX;
                controlPointStartCurrentX -= deltaFinalX;
            }
            else if (deltaX1 < .0) {
                controlPointEndPreviousX -= deltaFinalX;
                controlPointStartCurrentX += deltaFinalX;
            }
            
            CGFloat controlPointEndPreviousY = pivotalPoint.y;
            CGFloat controlPointStartCurrentY = pivotalPoint.y;
            if (deltaY1 > .0) {
                controlPointEndPreviousY += deltaFinalY;
                controlPointStartCurrentY -= deltaFinalY;
            }
            else if (deltaY1 < .0) {
                controlPointEndPreviousY -= deltaFinalY;
                controlPointStartCurrentY += deltaFinalY;
            }
            
            // Modify the values in previous dict object
            controlPointEndPrevious = CGPointMake(controlPointEndPreviousX, controlPointEndPreviousY);
            [curve setValue:[NSValue valueWithCGPoint:controlPointEndPrevious]
                     forKey:@"cPointB"];
            [curves replaceObjectAtIndex:i-1 withObject:curve];
            
            // Store normally
            P1 = CGPointMake(controlPointStartCurrentX, controlPointStartCurrentY);
         
        }

        // Save the points to the array to paint
        NSDictionary *convertPoint = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSValue valueWithCGPoint:cPoint[0]], @"t0Point",
                                      [NSValue valueWithCGPoint:P1], @"cPointA",
                                      [NSValue valueWithCGPoint:P2], @"cPointB",
                                      [NSValue valueWithCGPoint:cPoint[3]], @"t3Point",
                                      [NSValue valueWithCGPoint:cPoint[1]], @"t1Point",
                                      [NSValue valueWithCGPoint:cPoint[2]], @"t2Point",
                                      [NSNumber numberWithFloat:[[[array objectAtIndex:0] valueForKey:@"errorRatio"]floatValue]], @"errorRatio", nil];
        
        [curves addObject:convertPoint];
    }
    
    return curves;
    
}// getCubicBezierPointsForListPoint:splitIn:


- (NSArray *) getBestCurveForListPoint:(NSArray *)listPoints
                             tolerance:(CGFloat) ratioError
{
    // If there isn't enough number of points
    // we just split one time
    if ([listPoints count] < 7)
        return [self getCubicBezierPointsForListPoint:listPoints splitIn:1];

    // We get all info about the listPoints
    // We get C(t)
    CGFloat c[[listPoints count]];
    CGFloat currentLongitude = .0;
    c[0] = .0;
    
    for (NSUInteger i = 1 ; i < [listPoints count] ; i++) {
        CGPoint previousPoint = [[listPoints objectAtIndex:i-1]CGPointValue];
        CGPoint currentPoint = [[listPoints objectAtIndex:i]CGPointValue];
        
        SYSegment *segment = [[SYSegment alloc]initWithPoint:previousPoint andPoint:currentPoint];
        currentLongitude += [segment longitude];
        c[i] = currentLongitude;
        [segment release];
    }
    
    // Just divide c[n]/totalLongitude
    CGFloat totalLongitude = currentLongitude;
    for (NSUInteger i = 0 ; i < [listPoints count] ; i++)
        c[i] = currentLongitude/totalLongitude;
    
    // Limit
    NSUInteger limit = (NSUInteger) floor([listPoints count] * 0.25);    
    
    // We start loop looking for the minimize curves number
    NSUInteger splitParts = 1;
    CGFloat previousErrorRatio = 1000.0;
    for (NSUInteger i = 0; i <= limit; i++) {
        // Calculate error ratio
        CGFloat errorRatio = [self getErrorRatioListPoint:listPoints splitIn:i];

        if (errorRatio < 0.025) {
            splitParts = i;
            break;
        }
        else if (errorRatio < previousErrorRatio) {
            splitParts = i;
            previousErrorRatio = errorRatio;
        }
        
        if (errorRatio > previousErrorRatio && errorRatio > 1.0) {
            splitParts = i-1;
            break;
        }
    }
    
    // LOG
    /*
     for (NSUInteger i = 0; i <= limit; i++) {
     // Calculate error ratio
     CGFloat errorRatio = [self getErrorRatioListPoint:listPoints splitIn:i];
     NSLog(@"Para %u hay un %f", i, errorRatio);
     }
     */
    //NSLog(@"Elegido -> %u", splitParts);
    return [self getCubicBezierPointsForListPoint:listPoints splitIn:splitParts];
    
}// getBestCurveForListPoint:tolerance:


#pragma mark - Getter Parameters

- (CGFloat) getErrorRatioListPoint:(NSArray *)listPoints splitIn:(CGFloat)i
{
    NSArray *curves = [self getCubicBezierPointsForListPoint:listPoints splitIn:i];
    
    CGFloat sumRatio = .0;
    for (NSDictionary *curve in curves)
        sumRatio += [[curve valueForKey:@"errorRatio"]floatValue];
    
    return sumRatio;
    
}// getErrorRatioListPoint:splitIn:

@end