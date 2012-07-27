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

- (NSDictionary *) getCubicBezierPointsForListPoint:(NSArray *) listPoints
{    
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
    
    //float numberPointsF = (float)[listPoints count];
    for (NSUInteger j = 1; j < 3; j++) {
        float indexF = (float) round(step * (j));
        NSUInteger index = (NSUInteger) indexF;
        cValue[j] = c[index];
        cPoint[j] = CGPointMake([[listPoints objectAtIndex:index]CGPointValue].x,
                                [[listPoints objectAtIndex:index]CGPointValue].y);
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
    //NSLog(@"Matriz B:\n%lf\n%lf", B[0], B[1]);
    //NSLog(@"Matriz A:\n%lf   %lf\n%f   %lf", A[0], A[1], A[2], A[3]);
    int N = 2;
    int nrhs = 1;
    int lda = 2;
    int ipiv[2];
    int ldb = 2;
    int info;
    dgesv_(&N, &nrhs, A, &lda, &ipiv, B, &ldb, &info);
    //NSLog(@"Solucion: %lf %lf\n\n", B[0], B[1]);
    
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
    //NSLog(@"Matriz B:\n%lf\n%lf", B[0], B[1]);
    //NSLog(@"Matriz A:\n%lf   %lf\n%lf   %lf", A[0], A[2], A[1], A[3]);
    N = 2;
    nrhs = 1;
    lda = 2;
    ldb = 2;
    dgesv_(&N, &nrhs, A, &lda, &ipiv, B, &ldb, &info);
    //NSLog(@"Solucion: %lf %lf\n\n", B[0], B[1]);
    
    // Store solutions
    P1 = CGPointMake(P1.x, B[0]);
    P2 = CGPointMake(P2.x, B[1]);
    
    // Statistics Curve Fit
    CGFloat percentage = .0;
    for (NSUInteger i = 1 ; i < [listPoints count] ; i++) {
        CGPoint originalPaintedPoint = [[listPoints objectAtIndex:i]CGPointValue];
        CGFloat t = c[i];
        
        // Point from fast bezier
        CGFloat fastBezierPointX = powf(1-t, 3) * cPoint[0].x + 3 * powf(1-t, 2) * t * P1.x + 3 * (1-t) * powf(t, 2) * P2.x + powf(t, 3) * cPoint[3].x;
        CGFloat fastBezierPointY = powf(1-t, 3) * cPoint[0].y + 3 * powf(1-t, 2) * t * P1.y + 3 * (1-t) * powf(t, 2) * P2.y + powf(t, 3) * cPoint[3].y;
        CGPoint fastBezierPoint = CGPointMake(fastBezierPointX, fastBezierPointY);
                
        SYSegment *segment = [[SYSegment alloc]initWithPoint:originalPaintedPoint andPoint:fastBezierPoint];
        percentage += [segment longitude] / totalLongitude;
        [segment release];
    }
    
    // Save the points to the array to paint
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSValue valueWithCGPoint:cPoint[0]], @"t0Point",
                          [NSValue valueWithCGPoint:P1], @"cPointA",
                          [NSValue valueWithCGPoint:P2], @"cPointB",
                          [NSValue valueWithCGPoint:cPoint[3]], @"t3Point",
                          [NSValue valueWithCGPoint:cPoint[1]], @"t1Point",
                          [NSValue valueWithCGPoint:cPoint[2]], @"t2Point",
                          [NSNumber numberWithFloat:percentage*10.0], @"percentage", nil];
    
    return dict;
    
}// getCubicBezierPointsForListPoint:


- (NSDictionary *) getCubicBezierPointsForListPoint:(NSArray *) listPoints andConvertFromView:(UIView *) viewtoConvert
{
    NSDictionary *dict = [self getCubicBezierPointsForListPoint:listPoints];
    
    // Store solutions
    CGPoint cPoint[4] = {[[dict valueForKey:@"t0Point"]CGPointValue],
        [[dict valueForKey:@"t1Point"]CGPointValue],
        [[dict valueForKey:@"t2Point"]CGPointValue],
        [[dict valueForKey:@"t3Point"]CGPointValue]};
    CGPoint P1 = [[dict valueForKey:@"cPointA"]CGPointValue];
    CGPoint P2 = [[dict valueForKey:@"cPointB"]CGPointValue];
    
    // Convert points to draw axis
    cPoint[0] = CGPointMake(cPoint[0].x, viewtoConvert.bounds.size.height - cPoint[0].y);
    cPoint[1] = CGPointMake(cPoint[1].x, viewtoConvert.bounds.size.height - cPoint[1].y);
    cPoint[2] = CGPointMake(cPoint[2].x, viewtoConvert.bounds.size.height - cPoint[2].y);
    cPoint[3] = CGPointMake(cPoint[3].x, viewtoConvert.bounds.size.height - cPoint[3].y);        
    P1 = CGPointMake(P1.x, viewtoConvert.bounds.size.height - P1.y);
    P2 = CGPointMake(P2.x, viewtoConvert.bounds.size.height - P2.y);
    
    // Save the points to the array to paint
    NSDictionary *convertPoint = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSValue valueWithCGPoint:cPoint[0]], @"t0Point",
                                  [NSValue valueWithCGPoint:P1], @"cPointA",
                                  [NSValue valueWithCGPoint:P2], @"cPointB",
                                  [NSValue valueWithCGPoint:cPoint[3]], @"t3Point",
                                  [NSValue valueWithCGPoint:cPoint[1]], @"t1Point",
                                  [NSValue valueWithCGPoint:cPoint[2]], @"t2Point", nil];
    
    return convertPoint;
    
}// getCubicBezierPointsForListPoint:andConvertFromView:


- (NSArray *) getCubicBezierPointsForListPoint:(NSArray *) listPoints
                                       splitIn:(NSUInteger) ntimes
{
    if (ntimes == 0)
        return nil;
    
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
        
        [curves addObject:[self getCubicBezierPointsForListPoint:splitList]];
    }
    
    return curves;
    
}// getCubicBezierPointsForListPoint:splitIn:


- (NSArray *) getCubicBezierPointsForListPoint:(NSArray *) listPoints
                                       splitIn:(NSUInteger) ntimes
                            andConvertFromView:(UIView *) viewtoConvert
{
    if (ntimes == 0)
        return nil;
    
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
        
        NSDictionary *dict = [self getCubicBezierPointsForListPoint:splitList];
        
        // Store solutions
        CGPoint cPoint[4] = {[[dict valueForKey:@"t0Point"]CGPointValue],
            [[dict valueForKey:@"t1Point"]CGPointValue],
            [[dict valueForKey:@"t2Point"]CGPointValue],
            [[dict valueForKey:@"t3Point"]CGPointValue]};
        CGPoint P1 = [[dict valueForKey:@"cPointA"]CGPointValue];
        CGPoint P2 = [[dict valueForKey:@"cPointB"]CGPointValue];
        
        // Continuity
        if (i != 0) {
            
            // Compare with the previous curve
            NSMutableDictionary *curve = [NSMutableDictionary dictionaryWithDictionary:[curves objectAtIndex:i-1]];
            
            // Get the last control point in the last curve stored.
            // I have to do the inverse conversion
            CGPoint controlPointEndPrevious = CGPointMake([[curve valueForKey:@"cPointB"]CGPointValue].x, viewtoConvert.bounds.size.height - [[curve valueForKey:@"cPointB"]CGPointValue].y);
            
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
            
            // Direct conversion
            controlPointEndPrevious = CGPointMake(controlPointEndPreviousX, viewtoConvert.bounds.size.height - controlPointEndPreviousY);
            
            // Modify the values in previous dict object
            [curve setValue:[NSValue valueWithCGPoint:controlPointEndPrevious] forKey:@"cPointB"];
            [curves replaceObjectAtIndex:i-1 withObject:curve];
            
            // Store normally
            P1 = CGPointMake(controlPointStartCurrentX, controlPointStartCurrentY);
            
        }
        
        // Convert points to draw axis
        cPoint[0] = CGPointMake(cPoint[0].x, viewtoConvert.bounds.size.height - cPoint[0].y);
        cPoint[1] = CGPointMake(cPoint[1].x, viewtoConvert.bounds.size.height - cPoint[1].y);
        cPoint[2] = CGPointMake(cPoint[2].x, viewtoConvert.bounds.size.height - cPoint[2].y);
        cPoint[3] = CGPointMake(cPoint[3].x, viewtoConvert.bounds.size.height - cPoint[3].y);        
        P1 = CGPointMake(P1.x, viewtoConvert.bounds.size.height - P1.y);
        P2 = CGPointMake(P2.x, viewtoConvert.bounds.size.height - P2.y);
        
        // Save the points to the array to paint
        NSDictionary *convertPoint = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSValue valueWithCGPoint:cPoint[0]], @"t0Point",
                                      [NSValue valueWithCGPoint:P1], @"cPointA",
                                      [NSValue valueWithCGPoint:P2], @"cPointB",
                                      [NSValue valueWithCGPoint:cPoint[3]], @"t3Point",
                                      [NSValue valueWithCGPoint:cPoint[1]], @"t1Point",
                                      [NSValue valueWithCGPoint:cPoint[2]], @"t2Point",
                                      [NSNumber numberWithFloat:[[dict valueForKey:@"percentage"]floatValue]], @"percentage", nil];
        
        [curves addObject:convertPoint];
    }
    
    return curves;
    
}// getCubicBezierPointsForListPoint:splitIn:andConvertFromView:


- (NSArray *) getBestCurveForListPoint:(NSArray *) listPoints
                             tolerance:(CGFloat) percentage
                    andConvertFromView:(UIView *) viewtoConvert
{
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
    
    // We start loop looking for the minimize curves number
    NSArray *curves = nil;
    for (NSUInteger i = 2; i < 9; i++) {
        
        curves = [self getCubicBezierPointsForListPoint:listPoints splitIn:i andConvertFromView:viewtoConvert];
        
        CGFloat sumPercentage = .0;
        for (NSDictionary *curve in curves)
            sumPercentage += [[curve valueForKey:@"percentage"]floatValue];
        
        NSLog(@"Para %u hay un %f", i, sumPercentage);
        
        if (sumPercentage <= percentage)
            return curves;        
    }
    
    return curves;
    
}// getBestCurveForListPoint:tolerance:andConvertFromView:

@end
