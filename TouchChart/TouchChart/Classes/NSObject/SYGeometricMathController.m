//
//  SYGeometricMathController.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 14/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import "SYGeometricMathController.h"
#import "SYGeometry.h"
#import "SYSegment.h"
#import "SYVectorView.h"

@implementation SYGeometricMathController

@synthesize pointKeyArray;

#define limitDistace 2.99

#pragma mark - Management Operations

// Clean Data
- (void) cleanData
{
    // Init all the data and set ready them
    isDeltaX = NO; isDeltaY = NO;
    angleChangeCount = 0;
    directionChangeCount = 0;
    maxX = CGPointZero;
    maxY = CGPointZero;
    minX = CGPointZero;
    minY = CGPointZero;
    
    // Create new point list
    [listPoints release];
    [listAngles release];
    listPoints = [[NSMutableArray alloc]init];
    listAngles = [[NSMutableArray alloc]init];
    
}// cleanData


- (void) addFirstPoint:(CGPoint) newPoint
{
    NSValue *point = [NSValue valueWithCGPoint:newPoint];
    [listPoints addObject:point];
    
    maxX = newPoint;
    maxY = newPoint;
    minX = newPoint;
    minY = newPoint;
    
    isDeltaXPos = 0;
    isDeltaYPos = 0;
    
    self.pointKeyArray = [[NSMutableArray alloc]init];
    
    // PRIMER PUNTO
    [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:newPoint]];
    
}// addFirstPoint:


- (void) addPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;
{
    // Add points
    NSValue *pointAValue = [NSValue valueWithCGPoint:pointA];
    NSValue *pointBValue = [NSValue valueWithCGPoint:pointB];
    if (![[listPoints lastObject]isEqualToValue:pointAValue]) {
        [listPoints addObject:pointAValue];
        
        // Get Max/Min
        if (pointA.x > maxX.x)
            maxX = pointA;
        if (pointA.x < minX.x)
            minX = pointA;
        if (pointA.y > maxY.y)
            maxY = pointA;
        if (pointA.y < minY.y)
            minY = pointA;
        
    }
    if (![[listPoints lastObject]isEqualToValue:pointBValue]) {
        [listPoints addObject:pointBValue];
        
        // Get Max/Min
        if (pointB.x > maxX.x)
            maxX = pointB;
        if (pointB.x < minX.x)
            minX = pointB;
        if (pointB.y > maxY.y)
            maxY = pointB;
        if (pointB.y < minY.y)
            minY = pointB;
    }
    
    // Calculate keyPoints
    if ([listPoints count] > 3) {
        CGFloat deltaXF = pointB.x - pointA.x;
        CGFloat deltaYF = pointB.y - pointA.y;
        
        // VARIACION SEGUN DELTAX POR RATIOS
        if (previousDeltaX != 0 && fabs(deltaXF/previousDeltaX) > limitDistace)
            [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
        else if (previousDeltaY != 0 && fabs(deltaYF/previousDeltaY) > limitDistace)
            [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
        
        if (deltaXF != 0)
            previousDeltaX = deltaXF;
        if (deltaYF != 0)
            previousDeltaY = deltaYF;
        
        
        // VARIACION X SEGUN CAMBIOS DE DIRECCION
        if (isDeltaXPos == 0) {
            if (deltaXF > limitDistace) {
                isDeltaXPos = 1;
                return;
            }
            else if (deltaXF < -limitDistace) {
                isDeltaXPos = -1;
                return;
            }
            
            if (deltaXF > limitDistace) {
                isDeltaXPos = 1;
                return;
            }
            else if (deltaXF < -limitDistace) {
                isDeltaXPos = -1;
                return;
            }
        }
        else {
            if (deltaXF > limitDistace && isDeltaXPos == -1) {
                [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaXPos = 1;
                return;
            }
            else if (deltaXF < -limitDistace && isDeltaXPos == 1) {
                [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaXPos = -1;
                return;
            }
            
            if (deltaXF > limitDistace && isDeltaXPos == -1) {
                [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaXPos = 1;
                return;
            }
            else if (deltaXF < -limitDistace && isDeltaXPos == 1) {
                [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaXPos = -1;
                return;
            }            
        }
        
        // Variacion Y
        if (isDeltaYPos == 0) {
            if (deltaYF > limitDistace) {
                isDeltaYPos = 1;
                return;
            }
            else if (deltaYF < -limitDistace) {
                isDeltaYPos = -1;
                return;
            }
            
            if (deltaYF > limitDistace) {
                isDeltaYPos = 1;
                return;
            }
            else if (deltaYF < -limitDistace) {
                isDeltaYPos = -1;
                return;
            }
        }
        else {
            if (deltaYF > limitDistace && isDeltaYPos == -1) {
                [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaYPos = 1;
                return;
            }
            else if (deltaYF < -limitDistace && isDeltaYPos == 1) {
                [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaYPos = -1;
                return;
            }
            
            if (deltaYF > limitDistace && isDeltaYPos == -1) {
                [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaYPos = 1;
                return;
            }
            else if (deltaYF < -limitDistace && isDeltaYPos == 1) {
                [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaYPos = -1;
                return;
            }            
        }
        
        // ANGLES
        NSValue *vertexValue = [listPoints objectAtIndex:[listPoints count]-4];        
        CGFloat angle = [self getAngleBetweenVertex:pointA
                                          andPointA:pointB
                                          andPointB:[vertexValue CGPointValue]];
        
        CGFloat angleDeg = (angle / M_PI_2) * 90.0;
        if (angleDeg < 170.0) {
            [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:[vertexValue CGPointValue]]];
            angleChangeCount++;
        }
    }
    
}// addPoint:andPoint:


- (void) addLastPoint:(CGPoint) lastPoint
{
    [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:lastPoint]];
    
}// addLastPoint:


#pragma mark - Geometric calculations

// Return shape/curve contour longitude (aprox)
- (CGFloat) lengthFromPointList
{
    // If there isn't enough points, exit
    if ([listPoints count] < 2)
        return .0;
    
    CGFloat longitude = .0;
    for (int i = 1 ; i < [listPoints count] ; i++) {
        CGPoint startSegment = [[listPoints objectAtIndex:i-1]CGPointValue];
        CGPoint endSegment = [[listPoints objectAtIndex:i]CGPointValue];
        
        SYSegment *segment = [[SYSegment alloc]initWithPoint:startSegment andPoint:endSegment];
        longitude += [segment longitude];
        
    }
    
    return longitude;
    
}// lengthFromPointList


// Rewrite your TCChartView method ObjC native
- (CGFloat) distanceBetweenPoint:(CGPoint) point1 andPoint:(CGPoint) point2
{
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    
    return sqrt(pow(dx,2) + pow(dy,2));
    
}// distanceBetweenPoint:andPoint:


// Rewrite your TCChartView method ObjC native
- (CGFloat) getAngleBetweenVertex:(CGPoint) vertex andPointA:(CGPoint) pointA andPointB:(CGPoint) pointB
{
    // cos-1((P122 + P132 - P232)/(2 * P12 * P13))
    
    CGFloat P12 = [self distanceBetweenPoint:vertex andPoint:pointA];
    CGFloat P13 = [self distanceBetweenPoint:vertex andPoint:pointB];
    CGFloat P23 = [self distanceBetweenPoint:pointA andPoint:pointB];
    
    CGFloat num = P12 * P12 + P13 * P13 - P23 * P23;
    CGFloat den = 2 * P12 * P13;
    CGFloat total = num / den;
    CGFloat ret = acosf(total);
    
    return ret;
    
}// getAngleBetween


- (CGPoint) midPointBetweenPoint:(CGPoint) pointA andPoint:(CGPoint) pointB
{
    CGFloat xPoint = (pointA.x + pointB.x) / 2;
    CGFloat yPoint = (pointA.y + pointB.y) / 2;
    CGPoint result = CGPointMake(xPoint, yPoint);
    
    return result;
    
}// midPointBetween:andPoint:


- (CGFloat) distanceFrom:(CGPoint) pointTest toLineBuildForPoint:(CGPoint) pointKey andPoint:(CGPoint) pointNextKey
{
    // Calcula pendiente
    CGFloat m = (pointNextKey.y - pointKey.y) / (pointNextKey.x - pointKey.x);
    
    // Calcula termino d
    CGFloat d = pointKey.y - (m * pointKey.x);
    
    // Se calcula distancia
    CGFloat dist = fabsf(pointTest.y - ((m * pointTest.x) + d)) / sqrtf(powf(m, 2) + 1);
    
    return dist;
    
}// distanceFrom:toLineBuildForPoint:andPoint:


- (BOOL) point:(CGPoint)pointA andPoint:(CGPoint)pointB isAlignedWithPoint:(CGPoint)pointC
{
    // Ecuacion de la recta y = mx + d
    // -------------------------------
    // Se calcula distancia
    float dist = [self distanceFrom:pointC toLineBuildForPoint:pointA andPoint:pointB];
    
    // Si esta alineado responde si
    if (dist == 0)
        return YES;
    
    // Si no NO
    return NO;
    
}// point:andPoint:isAlignedWithPoint:


- (BOOL) point:(CGPoint)pointA andPoint:(CGPoint)pointC isAlignedWithPoint:(CGPoint)pointB withDistance:(float) ratio
{
    // Ecuacion de la recta y = mx + d
    // -------------------------------
    // Se calcula distancia
    float dist = [self distanceFrom:pointC toLineBuildForPoint:pointA andPoint:pointB];
    
    // Si esta alineado responde si
    if (dist < ratio)
        return YES;
    
    // Si no NO
    return NO;
    
}// point:andPoint:isAlignedWithPoint:



#pragma mark - Auxiliar calculations

- (NSUInteger) getFactorial:(NSUInteger) intNumber
{
    NSUInteger result = 1;
    
    for (NSUInteger i = 0; i < intNumber ; i++)
        result = result * (intNumber-i);
    
    return result;
    
}// getFactorial:


#pragma mark - Calculate Shapes

- (void) getBezierPathPainted
{
    //TEMPORAL
    vectorView.shapeList = [[NSMutableArray alloc]init];
    NSArray *allPoint = [NSArray arrayWithArray:self.pointKeyArray];
    
    // Get radius to reduce point cloud
    CGFloat maxDeltaX = maxX.x - minX.x;
    CGFloat maxDeltaY = maxY.y - minY.y;
    CGFloat radiusCloud = sqrtf(powf(maxDeltaX, 2) + powf(maxDeltaY, 2)) * 0.10;
    
    // Point cloud simplification algorithm (using radiusCloud)
    // --------------------------------------------------------------------------
    NSMutableArray *tempKeyPointsArray = [NSMutableArray arrayWithArray:[self pointKeyArray]];
    for (int i = 0 ; i < [tempKeyPointsArray count] ; i++) {
        // Pilla el primer punto
        id pointID = [tempKeyPointsArray objectAtIndex:i];
        
        if ((NSNull *) pointID != [NSNull null]) {
            CGPoint point = [[tempKeyPointsArray objectAtIndex:i]CGPointValue];
            
            // Compara con los siguientes hasta que no haya proximidad
            for (int j = i+1 ; j < [pointKeyArray count] ; j++) {
                CGPoint nextPoint = [[pointKeyArray objectAtIndex:j]CGPointValue];
                
                CGFloat distance = [self distanceBetweenPoint:point andPoint:nextPoint];
                if (distance < radiusCloud) {
                    [tempKeyPointsArray replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:point]];
                    [tempKeyPointsArray replaceObjectAtIndex:j withObject:[NSNull null]];
                }
            }
        }
    }
    
    
    // Clean all NSNull
    self.pointKeyArray = [[NSMutableArray alloc]init];
    for (id keyPoint in tempKeyPointsArray) {
        if ((NSNull *) keyPoint != [NSNull null])
            [pointKeyArray addObject:keyPoint];
    }
    
    
    // Remove points aligned (step A)
    // -------------------------------------------------
    NSMutableArray *edgePoints = [NSMutableArray array];
    if ([pointKeyArray count] > 0) {
        [edgePoints addObject:[pointKeyArray objectAtIndex:0]];
        
        for (int i = 0 ; i+2 < [pointKeyArray count] ; i++) {
            
            CGPoint pointKeyA = [[pointKeyArray objectAtIndex:i]CGPointValue];
            CGPoint pointKeyB = [[pointKeyArray objectAtIndex:i+1]CGPointValue];
            CGPoint pointKeyC = [[pointKeyArray objectAtIndex:i+2]CGPointValue];
            
            SYSegment *segment = [[SYSegment alloc]initWithPoint:pointKeyA andPoint:pointKeyC];
            CGFloat longitude = [segment longitude];
            
            if ([segment distanceToPoint:pointKeyB] < longitude * 0.12) {
                [pointKeyArray replaceObjectAtIndex:i+1 withObject:[NSNull null]];
                i = i+1;
            }
            
            [segment release];
        }
    }
    
    // Clean all NSNull
    NSMutableArray *finalArray = [NSMutableArray array];
    for (id keyPoint in pointKeyArray) {
        if ((NSNull *) keyPoint != [NSNull null]) {
            CGPoint newCGPoint = [keyPoint CGPointValue];
            NSValue *newPoint = [NSValue valueWithCGPoint:CGPointMake(newCGPoint.x, newCGPoint.y)];
            [finalArray addObject:newPoint];
        }
    }
    self.pointKeyArray = finalArray;
    
    
    // Is the painted shape closed (almost closed)?
    // --------------------------------------------------------------------------
    SYSegment *near = [[SYSegment alloc]initWithPoint:[[listPoints objectAtIndex:0]CGPointValue]
                                             andPoint:[[listPoints lastObject]CGPointValue]];
    CGFloat ratioClose = [near longitude]/((maxDeltaX + maxDeltaY)*0.5);
    
    // It's open, do nothing, exit
    if (fabs(ratioClose) > 0.30) {
        
        NSMutableArray *bezierPointsArray = [NSMutableArray array];
        
        // We get C(t)
        CGFloat c[[listPoints count]];
        CGFloat currentLongitude = .0;
        
        for (NSUInteger i = 1 ; i < [listPoints count] ; i++) {
            CGPoint previousPoint = [[listPoints objectAtIndex:i-1]CGPointValue];
            CGPoint currentPoint = [[listPoints objectAtIndex:i]CGPointValue];
            
            SYSegment *segment = [[SYSegment alloc]initWithPoint:previousPoint andPoint:currentPoint];
            c[i-1] = currentLongitude;
            currentLongitude += [segment longitude];
            c[i] = currentLongitude;
        }
        
        // Just divide c[n]/totalLongitude
        CGFloat totalLongitude = currentLongitude;
        for (NSUInteger i = 0 ; i < [listPoints count] ; i++)
            c[i] = currentLongitude/totalLongitude;

        
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
        
        float numberPointsF = (float)[listPoints count];
        for (NSUInteger j = 1; j < 3; j++) {
            float indexF = (float) round(step * (j));
            NSUInteger index = (NSUInteger) indexF;
            cValue[j] = indexF/numberPointsF;
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
        NSLog(@"Matriz B:\n%lf\n%lf", B[0], B[1]);
        NSLog(@"Matriz A:\n%lf   %lf\n%f   %lf", A[0], A[1], A[2], A[3]);
        int N = 2;
        int nrhs = 1;
        int lda = 2;
        int ipiv[2];
        int ldb = 2;
        int info;
        dgesv_(&N, &nrhs, A, &lda, &ipiv, B, &ldb, &info);
        NSLog(@"Solucion: %lf %lf\n\n", B[0], B[1]);
        
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
        NSLog(@"Matriz B:\n%lf\n%lf", B[0], B[1]);
        NSLog(@"Matriz A:\n%lf   %lf\n%lf   %lf", A[0], A[2], A[1], A[3]);
        N = 2;
        nrhs = 1;
        lda = 2;
        ldb = 2;
        dgesv_(&N, &nrhs, A, &lda, &ipiv, B, &ldb, &info);
        NSLog(@"Solucion: %lf %lf\n\n", B[0], B[1]);
        
        // Store solutions
        P1 = CGPointMake(P1.x, B[0]);
        P2 = CGPointMake(P2.x, B[1]);
        
        // Convert points to draw axis
        cPoint[0] = CGPointMake(cPoint[0].x, vectorView.bounds.size.height - cPoint[0].y);
        cPoint[1] = CGPointMake(cPoint[1].x, vectorView.bounds.size.height - cPoint[1].y);
        cPoint[2] = CGPointMake(cPoint[2].x, vectorView.bounds.size.height - cPoint[2].y);
        cPoint[3] = CGPointMake(cPoint[3].x, vectorView.bounds.size.height - cPoint[3].y);        
        P1 = CGPointMake(P1.x, vectorView.bounds.size.height - P1.y);
        P2 = CGPointMake(P2.x, vectorView.bounds.size.height - P2.y);
        
        // Save the points to the array to paint
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGPoint:cPoint[0]], @"t0Point",
                              [NSValue valueWithCGPoint:P1], @"cPointA",
                              [NSValue valueWithCGPoint:P2], @"cPointB",
                              [NSValue valueWithCGPoint:cPoint[3]], @"t3Point",
                              [NSValue valueWithCGPoint:cPoint[1]], @"t1Point",
                              [NSValue valueWithCGPoint:cPoint[2]], @"t2Point", nil];
        [bezierPointsArray addObject:dict]; 
        
        [self createBezierCurveWithPoints:bezierPointsArray];
        
        
        
        
        
        
        
        
        
        
        
        
        /*
        // We are going to test the best bezier curve. We start with cubic degree and then increase it
        for (NSUInteger degree = 3; degree < 8; degree++) {

            // We need 'degree-1' C(t) values
            CGFloat cValue[degree-1];
            CGPoint cPoint[degree-1];
            CGFloat step = (float) [listPoints count] / degree;
            
            for (NSUInteger j = 0; j < degree-1; j++) {
                NSUInteger index = (NSUInteger) round(step * (j+1));
                cValue[j] = c[index];
                cPoint[j] = CGPointMake(cPoint[index].x, cPoint[index].y);
            }            
            
            // We need create the matrix for solve the lineal equation
            // Matrix B
            double b[degree-1];
            for (NSUInteger j = 0; j < degree-1; j++)
                b[j] = cPoint[j].x;
            
            // Matrix A
            double A[degree+1];
            for (NSUInteger j = 0; j < degree-1; j++) {
                
                double K[degree+1];
                
                for (NSUInteger k = 0; k <= degree; k++) {
                    K[k] = 
                }
            }
         */
            

            
            //double b[degree] = {-3.0, 7.0, 3.3};
            
            
            
            // We need create the matrix for solve the lineal equation
            /* 3x3 matrix A
             * 76 25 11
             * 27 89 51
             * 18 60 32
             */
            /*double A[9] = {76, 27, 18, 25, 89, 60, 11, 51, 32};
            double b[3] = {10, 7, 43};
            int N = 3;
            int nrhs = 1;
            int lda = 3;
            int ipiv[3];
            int ldb = 3;
            int info;
             dgesv_(&N, &nrhs, A, &lda, &ipiv, b, &ldb, &info);
             if(info == 0) // succeed
            printf("The solution is %lf %lf %lf\n", b[0], b[1], b[2]);
            else
                fprintf(stderr, "dgesv_ fails %d\n", info);
             */
            
            //double A[4] = {1.5, 2.3, 4.7, -5.0};
            //double b[2] = {-3.0, 7.0};
            /*
            int N = 2;
            int nrhs = 1;
            int lda = 2;
            int ipiv[2];
            int ldb = 2;
            int info;
            dgesv_(&N, &nrhs, A, &lda, &ipiv, b, &ldb, &info);
            if(info == 0) //* succeed
                printf("The solution is %lf %lf\n", b[0], b[1]);
            else
                fprintf(stderr, "dgesv_ fails %d\n", info);
            
            NSLog(@"fin");*/
        
        
        
        
        
        /*
        // The key point set the numbers of bezier curves
        for (NSUInteger i = 1 ; i < [self.pointKeyArray count] ; i++) {
            
            // Get the start and end point
            CGPoint t0Point = [[self.pointKeyArray objectAtIndex:i-1]CGPointValue];
            CGPoint t3Point = [[self.pointKeyArray objectAtIndex:i]CGPointValue];
                        
            // Cubic bezier. We need two points and its 't' value
            // --------------------------------------------------
            // We analyze the list Points. What's the start and end point index into listPoint array?
            NSUInteger index = 0; NSUInteger indexesStEnd[2] = {0,0};
            for (NSValue *aPoint in listPoints) {
                if ([aPoint isEqual:[self.pointKeyArray objectAtIndex:i-1]])
                    indexesStEnd[0] = index;
                if ([aPoint isEqual:[self.pointKeyArray objectAtIndex:i]])
                    indexesStEnd[1] = index;

                index++;
            }
                        
            if (indexesStEnd[0] == indexesStEnd[1] || indexesStEnd[0] > indexesStEnd[1])
                return;
            
            // We get iso-distributed points along bezier            
            NSUInteger step = (indexesStEnd[1] - indexesStEnd[0]) / 3;
            NSUInteger t1IndexPoint = indexesStEnd[0] + step;
            NSUInteger t2IndexPoint = indexesStEnd[0] + (2 * step);
                        
            // We calculate longitude between init point and final point
            CGFloat totalLongitude = .0; CGFloat t1Longitude = .0; CGFloat t2Longitude = .0;
            for (int i = indexesStEnd[0]+1 ; i <= indexesStEnd[1] ; i++) {
                CGPoint startSegment = [[listPoints objectAtIndex:i-1]CGPointValue];
                CGPoint endSegment = [[listPoints objectAtIndex:i]CGPointValue];
                
                SYSegment *segment = [[SYSegment alloc]initWithPoint:startSegment andPoint:endSegment];
                totalLongitude += [segment longitude];
                
                if (i == t1IndexPoint)
                    t1Longitude = totalLongitude;
                if (i == t2IndexPoint)
                    t2Longitude = totalLongitude;
            }

            CGPoint t1Point = [[listPoints objectAtIndex:t1IndexPoint]CGPointValue];
            float t1 = t1Longitude / totalLongitude;
            CGPoint t2Point = [[listPoints objectAtIndex:t2IndexPoint]CGPointValue];
            float t2 = t2Longitude / totalLongitude;
            
            // We use Cramer Rule
            // ax + by = e
            // cx + dy = f
            
            // First control Point
            float e = t1Point.x - (pow(1-t1, 3) * t0Point.x) - (pow(t1, 3) * t3Point.x);
            float f = t2Point.x - (pow(1-t2, 3) * t0Point.x) - (pow(t2, 3) * t3Point.x);
            
            float a = 3.0 * t1 * pow(1-t1, 2);
            float b = 3.0 * pow(t1, 2) * (1-t1);
            float c = 3.0 * t2 * pow(1-t2, 2);
            float d = 3.0 * pow(t2, 2) * (1-t2);
            
            float cPointX = (e*d - b*f) / (a*d - b*c);
            float cPointY = (a*f - e*c) / (a*d - b*c);
            CGPoint cPointA = CGPointMake(cPointX, cPointY);
            
            // Second control Point
            e = t1Point.y - (pow(1-t1, 3) * t0Point.y) - (pow(t1, 3) * t3Point.y);
            f = t2Point.y - (pow(1-t2, 3) * t0Point.y) - (pow(t2, 3) * t3Point.y);
            a = 3.0 * t1 * pow(1-t1, 2);
            b = 3.0 * pow(t1, 2) * (1-t1);
            c = 3.0 * t2 * pow(1-t2, 2);
            d = 3.0 * pow(t2, 2) * (1-t2);
            
            cPointX = (e*d - b*f) / (a*d - b*c);
            cPointY = (a*f - e*c) / (a*d - b*c);
            CGPoint cPointB = CGPointMake(cPointX, cPointY);
            
            // Convert points to draw axis
            t0Point = CGPointMake(t0Point.x, vectorView.bounds.size.height - t0Point.y);
            cPointA = CGPointMake(cPointA.x, vectorView.bounds.size.height - cPointA.y);
            cPointB = CGPointMake(cPointB.x, vectorView.bounds.size.height - cPointB.y);
            t3Point = CGPointMake(t3Point.x, vectorView.bounds.size.height - t3Point.y);
            
            t1Point = CGPointMake(t1Point.x, vectorView.bounds.size.height - t1Point.y);
            t2Point = CGPointMake(t2Point.x, vectorView.bounds.size.height - t2Point.y);
            
            // Save the points to the array to paint
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGPoint:t0Point], @"t0Point",
                                  [NSValue valueWithCGPoint:cPointA], @"cPointA",
                                  [NSValue valueWithCGPoint:cPointB], @"cPointB",
                                  [NSValue valueWithCGPoint:t3Point], @"t3Point",
                                  [NSValue valueWithCGPoint:t1Point], @"t1Point",
                                  [NSValue valueWithCGPoint:t2Point], @"t2Point", nil];
            [bezierPointsArray addObject:dict];            
        }
        */
        /*
        // Cubic bezier. We need two points and its 't' value
        float lengthLine = [self lengthFromPointList];

        NSMutableArray *pointsCurvesBezier = [NSMutableArray array];
        for (NSValue *newPoint in finalArray) {
            NSLog(@"newPoint");
            CGFloat longitude = .0;
            for (int i = 1 ; i < [listPoints count] ; i++) {
                CGPoint startSegment = [[listPoints objectAtIndex:i-1]CGPointValue];
                CGPoint endSegment = [[listPoints objectAtIndex:i]CGPointValue];
                
                SYSegment *segment = [[SYSegment alloc]initWithPoint:startSegment andPoint:endSegment];
                longitude += [segment longitude];
                
                if ([[listPoints objectAtIndex:i] isEqual:newPoint]) {
                    NSLog(@"(%f, %f) : %f", endSegment.x, endSegment.y, longitude/lengthLine);
                    [pointsCurvesBezier addObject:[listPoints objectAtIndex:i]];
                    [pointsCurvesBezier addObject:[NSNumber numberWithFloat:longitude/lengthLine]];
                    break;
                }
            }
        }
        NSLog(@"end");
        
        // Get 2 points
        CGPoint p0 = [[listPoints objectAtIndex:0]CGPointValue];
        CGPoint p3 = [[listPoints lastObject]CGPointValue];
        
        CGPoint pt1_3 = [[pointsCurvesBezier objectAtIndex:0]CGPointValue];
        float t1_3 = [[pointsCurvesBezier objectAtIndex:1]floatValue];
        CGPoint pt2_3 = [[pointsCurvesBezier objectAtIndex:2]CGPointValue];
        float t2_3 = [[pointsCurvesBezier objectAtIndex:3]floatValue];
        
        
        // We use Cramer Rule
        // ax + by = e
        // cx + dy = f
        
        // First control Point
        float e = pt1_3.x - (pow(1-t1_3, 3) * p0.x) - (pow(t1_3, 3) * p3.x);
        float f = pt2_3.x - (pow(1-t2_3, 3) * p0.x) - (pow(t2_3, 3) * p3.x);
        
        float a = 3.0 * t1_3 * pow(1-t1_3, 2);
        float b = 3.0 * pow(t1_3, 2) * (1-t1_3);
        float c = 3 * t2_3 * pow(1-t2_3, 2);
        float d = 3 * pow(t2_3, 2) * (1-t2_3);
        
        float cPointX = (e*d - b*f) / (a*d - b*c);
        float cPointY = (a*f - e*c) / (a*d - b*c);
        CGPoint cPointA = CGPointMake(cPointX, cPointY);
        
        // Second control Point
        e = pt1_3.y - (pow(1-t1_3, 3) * p0.y) - (pow(t1_3, 3) * p3.y);
        f = pt2_3.y - (pow(1-t2_3, 3) * p0.y) - (pow(t2_3, 3) * p3.y);
        a = 3.0 * t1_3 * pow(1-t1_3, 2);
        b = 3.0 * pow(t1_3, 2) * (1-t1_3);
        c = 3 * t2_3 * pow(1-t2_3, 2);
        d = 3 * pow(t2_3, 2) * (1-t2_3);
        
        cPointX = (e*d - b*f) / (a*d - b*c);
        cPointY = (a*f - e*c) / (a*d - b*c);
        CGPoint cPointB = CGPointMake(cPointX, cPointY);
        
        NSArray *bezierPointsArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p0],
                                     [NSValue valueWithCGPoint:cPointA],
                                     [NSValue valueWithCGPoint:cPointB],
                                     [NSValue valueWithCGPoint:p3], nil];
        */
        //[self createBezierCurveWithPoints:bezierPointsArray];
        
        return;
    }
    else {
        // It's closed (almost closed), do closed perfectly
        CGPoint firstPoint = [[finalArray objectAtIndex:0]CGPointValue];
        CGPoint lastPoint = [[finalArray lastObject]CGPointValue];
        CGPoint midPoint = [self midPointBetweenPoint:firstPoint andPoint:lastPoint];
        [finalArray replaceObjectAtIndex:0 withObject:[NSValue valueWithCGPoint:midPoint]];
        [finalArray removeLastObject];
        
        // Clean all NSNull
        finalArray = [NSMutableArray array];
        for (id keyPoint in pointKeyArray) {
            if ((NSNull *) keyPoint != [NSNull null]) {
                CGPoint newCGPoint = [keyPoint CGPointValue];
                NSValue *newPoint = [NSValue valueWithCGPoint:CGPointMake(newCGPoint.x, newCGPoint.y)];
                [finalArray addObject:newPoint];
            }
        }
        self.pointKeyArray = [[NSMutableArray alloc]initWithArray:finalArray];
        
        // Get oval axis
        CGFloat axisDistance = .0;
        SYSegment *bigAxisSegment = nil; 
        for (NSValue *pointValue in listPoints) {
            
            CGPoint pointA = [pointValue CGPointValue];
            
            for (int i = 0 ; i < [listPoints count] ; i++) {
                CGPoint pointB = [[listPoints objectAtIndex:i]CGPointValue];
                SYSegment *possibleAxis = [[SYSegment alloc]initWithPoint:pointA andPoint:pointB];
                if (axisDistance < [possibleAxis longitude]) {
                    [bigAxisSegment release];
                    bigAxisSegment = [possibleAxis retain];
                    axisDistance = [possibleAxis longitude];
                }
                [possibleAxis release];
            }
        }
        
        // If horizontal or vertical oval, we don't need rotate it
        float deltaAngle = fabs([bigAxisSegment angleDeg]) - 90.0;
        if (fabs([bigAxisSegment angleDeg]) < 10.0 || fabs(deltaAngle) < 10.0) {
            // Get the points Max, Min for create the CGRect
            minX = [[listPoints objectAtIndex:0]CGPointValue];
            maxX = [[listPoints objectAtIndex:0]CGPointValue];
            minY = [[listPoints objectAtIndex:0]CGPointValue];
            maxY = [[listPoints objectAtIndex:0]CGPointValue];
            for (NSValue *pointValue in listPoints) {
                CGPoint point = [pointValue CGPointValue];
                
                if (point.x > maxX.x)
                    maxX = point;
                if (point.y > maxY.y)
                    maxY = point;
                if (point.x < minX.x)
                    minX = point;
                if (point.y < minY.y)
                    minY = point;
            }
            [self createCircle];
            return;
        }
        
        // Looking for the small axis
        CGPoint center = [bigAxisSegment midPoint];
        SYSegment *smallAxisSegment = nil; CGFloat angleMax = .0;
        for (NSValue *pointValue in allPoint) {
            CGPoint pointB = [pointValue CGPointValue];
            SYSegment *possibleAxis = [[SYSegment alloc]initWithPoint:center andPoint:pointB];
            
            float angle = fabs([bigAxisSegment angleDeg] - [possibleAxis angleDeg]);            
            
            if (angle > angleMax) {
                [smallAxisSegment release];
                smallAxisSegment = [possibleAxis retain];
                angleMax = angle;
            }
            [possibleAxis release];
        }

        // Maybe it's almost a circle
        float bigAxisLongitude = [bigAxisSegment longitude];
        float smallAxisLongitude = sin((angleMax/180) * M_PI) * [smallAxisSegment longitude] * 2.0;
        if (smallAxisLongitude/bigAxisLongitude > 0.70) {
            
            // Get the points Max, Min for create the CGRect
            minX = [bigAxisSegment pointSt];
            maxX = [bigAxisSegment pointFn];
            minY = [[allPoint objectAtIndex:0]CGPointValue];
            maxY = [[allPoint objectAtIndex:0]CGPointValue];
            
            // Create arc 
            [self createArc:CGPointMake(center.x, vectorView.bounds.size.height - center.y)
                     radius:bigAxisLongitude*0.5
                 startAngle:.0
                   endAngle:360.0
                  clockwise:YES];
            return;
        }
        
        // Get max and min XY
        float angleRad = M_PI_2 - [bigAxisSegment angleRad];
        [bigAxisSegment setMiddlePointToDegree:90.0];
        minY = [bigAxisSegment pointSt];
        maxY = [bigAxisSegment pointFn];
        minX = CGPointMake([bigAxisSegment midPoint].x - smallAxisLongitude * 0.5, [bigAxisSegment midPoint].y);
        maxX = CGPointMake([bigAxisSegment midPoint].x + smallAxisLongitude * 0.5, [bigAxisSegment midPoint].y);
        
        // Transform, rotate a around the midpoint
        CGPoint pivotalPoint = CGPointMake([bigAxisSegment midPoint].x, vectorView.bounds.size.height - [bigAxisSegment midPoint].y);
        CGAffineTransform transform = CGAffineTransformMakeTranslation(pivotalPoint.x, pivotalPoint.y);
        transform = CGAffineTransformRotate(transform, angleRad);
        transform = CGAffineTransformTranslate(transform, - pivotalPoint.x, - pivotalPoint.y);
        [self createCircleWithTransform:transform];
        
        [bigAxisSegment release];
        [smallAxisSegment release];
        
        return;
    }  
    
}// getBezierPathPainted

/*
- (NSDictionary *) getCurveControlPointsFromKnots:(NSArray *) knots
{
    if (!knots) {
        NSLog(@"Error: We need knots points");
        return nil;
    }
    
    int n = [knots count] - 1;    
    if (n < 1)
        NSLog(@"Error: At least two knot points required");

    if (n == 1) {
        // Special case: Bezier curve should be a straight line.
        CGPoint firstControlPoints = CGPointZero;
        
        // 3P1 = 2P0 + P3
        firstControlPoints.x = (2 * [[knots objectAtIndex:0]CGPointValue].x + [[knots objectAtIndex:1]CGPointValue].x) / 3;
        firstControlPoints.y = (2 * [[knots objectAtIndex:0]CGPointValue].y + [[knots objectAtIndex:1]CGPointValue].y) / 3;
        
        CGPoint secondControlPoints = CGPointZero;
        
        // P2 = 2P1 – P0
        secondControlPoints.x = 2 * firstControlPoints.x - [[knots objectAtIndex:0]CGPointValue].x;
        secondControlPoints.y = 2 * firstControlPoints.y - [[knots objectAtIndex:0]CGPointValue].y;
        
        NSArray *firstControlPointsArray = [NSArray arrayWithObject:[NSValue valueWithCGPoint:firstControlPoints]];
        NSArray *secondControlPointsArray = [NSArray arrayWithObject:[NSValue valueWithCGPoint:secondControlPoints]];
        
        return [NSDictionary dictionaryWithObjectsAndKeys: firstControlPointsArray, @"firstControl", secondControlPointsArray, @"secondControl", nil];
    }
    
    // Calculate first Bezier control points
    // Right hand side vector
    double rhs[n];
    
    // Set right hand side X values
    NSMutableArray *rhsArray = [NSMutableArray array];
    rhs[0] = [[knots objectAtIndex:0]CGPointValue].x + 2 * [[knots objectAtIndex:1]CGPointValue].x;
    [rhsArray addObject:[NSNumber numberWithDouble:rhs[0]]];
    
    for (int i = 1; i < n - 1; ++i) {
        rhs[i] = 4 * [[knots objectAtIndex:i]CGPointValue].x + 2 * [[knots objectAtIndex:i+1]CGPointValue].x;
        [rhsArray addObject:[NSNumber numberWithDouble:rhs[i]]];
    }
    
    rhs[n - 1] = (8 * [[knots objectAtIndex:n-1]CGPointValue].x + [[knots objectAtIndex:n]CGPointValue].x) / 2.0;
    [rhsArray addObject:[NSNumber numberWithDouble:rhs[n - 1]]];
    
    
    
    // Get first control points X-values
    NSArray *xValues = [self getFirstControlPoints:rhsArray];
    
    // Set right hand side Y values
    rhsArray = [NSMutableArray array];
    rhs[0] = [[knots objectAtIndex:0]CGPointValue].y + 2 * [[knots objectAtIndex:1]CGPointValue].y;
    [rhsArray addObject:[NSNumber numberWithDouble:rhs[0]]];
    
    for (int i = 1; i < n - 1; ++i) {
        rhs[i] = 4 * [[knots objectAtIndex:i]CGPointValue].y + 2 * [[knots objectAtIndex:i+1]CGPointValue].y;
        [rhsArray addObject:[NSNumber numberWithDouble:rhs[i]]];
    }
    
    rhs[n - 1] = (8 * [[knots objectAtIndex:n-1]CGPointValue].y + [[knots objectAtIndex:n]CGPointValue].y) / 2.0;
    [rhsArray addObject:[NSNumber numberWithDouble:rhs[n - 1]]];
    
    
    
    // Get first control points Y-values
    NSArray *yValues = [self getFirstControlPoints:rhsArray];
    
    // Fill output arrays.
    CGPoint firstControlPoints[n];
    CGPoint secondControlPoints[n];
    
    NSMutableArray *firstControlPointsArray = [NSMutableArray array];
    NSMutableArray *secondControlPointsArray = [NSMutableArray array];
    
    for (int i = 0; i < n; ++i) {
        
        // First control point
        firstControlPoints[i] = CGPointMake([[xValues objectAtIndex:i]doubleValue], [[yValues objectAtIndex:i]doubleValue]);
        [firstControlPointsArray addObject:[NSValue valueWithCGPoint:firstControlPoints[i]]];
        
        // Second control point
        if (i < n - 1) {
            secondControlPoints[i] = CGPointMake(2 * [[knots objectAtIndex:i+1]CGPointValue].x - [[xValues objectAtIndex:i+1]doubleValue],
                                                 2 * [[knots objectAtIndex:i+1]CGPointValue].y - [[yValues objectAtIndex:i+1]doubleValue]);
            [secondControlPointsArray addObject:[NSValue valueWithCGPoint:secondControlPoints[i]]];
        }
        else {
            secondControlPoints[i] = CGPointMake(([[knots objectAtIndex:n]CGPointValue].x + [[xValues objectAtIndex:n-1]doubleValue]) / 2,
                                                 ([[knots objectAtIndex:n]CGPointValue].y + [[yValues objectAtIndex:n-1]doubleValue]) / 2);
            [secondControlPointsArray addObject:[NSValue valueWithCGPoint:secondControlPoints[i]]];
        }
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys: firstControlPointsArray, @"firstControl", secondControlPointsArray, @"secondControl", nil];
    
}// getCurveControlPointsFromKnots:


- (NSArray *) getFirstControlPoints:(NSArray *) rhs
{
    int n = [rhs count];
    double x[n];    // Solution vector.
    double tmp[n];  // Temp workspace.
    
    NSMutableArray *result = [NSMutableArray array];
    
    double b = 2.0;
    x[0] = [[rhs objectAtIndex:0]doubleValue] / b;
    [result addObject:[NSNumber numberWithDouble:x[0]]];

    // Decomposition and forward substitution.
    for (int i = 1; i < n; i++) {
        tmp[i] = 1 / b;
        b = (i < n - 1 ? 4.0 : 3.5) - tmp[i];
        x[i] = ([[rhs objectAtIndex:i]doubleValue] - x[i - 1]) / b;
        [result addObject:[NSNumber numberWithDouble:x[i]]];
    }
    
    // Backsubstitution
    for (int i = 1; i < n; i++) {
        x[n - i - 1] -= tmp[n - i] * x[n - i];

        if (i==1)
            [result addObject:[NSNumber numberWithDouble:x[n - i - 1]]];
        else
            [result replaceObjectAtIndex:n-i-1 withObject:[NSNumber numberWithDouble:x[n - i - 1]]];
    }
    
    return [NSArray arrayWithArray:result];
    
}// getFirstControlPoints:
*/

// Read lists and return the poligons best fit (or nil if the lists don't match)
- (void) getFigurePainted
{
    [self getBezierPathPainted];
    return;
    
    //TEMPORAL
    vectorView.shapeList = [[NSMutableArray alloc]init];
    
    // Get radius to reduce point cloud
    CGFloat maxDeltaX = maxX.x - minX.x;
    CGFloat maxDeltaY = maxY.y - minY.y;
    CGFloat radiusCloud = sqrtf(powf(maxDeltaX, 2) + powf(maxDeltaY, 2)) * 0.10;
    
    // Point cloud simplification algorithm (using radiusCloud)
    // --------------------------------------------------------------------------
    NSMutableArray *tempKeyPointsArray = [NSMutableArray arrayWithArray:[self pointKeyArray]];
    for (int i = 0 ; i < [tempKeyPointsArray count] ; i++) {
        // Pilla el primer punto
        id pointID = [tempKeyPointsArray objectAtIndex:i];
        
        if ((NSNull *) pointID != [NSNull null]) {
            CGPoint point = [[tempKeyPointsArray objectAtIndex:i]CGPointValue];
            
            // Compara con los siguientes hasta que no haya proximidad
            for (int j = i+1 ; j < [pointKeyArray count] ; j++) {
                CGPoint nextPoint = [[pointKeyArray objectAtIndex:j]CGPointValue];
                
                CGFloat distance = [self distanceBetweenPoint:point andPoint:nextPoint];
                if (distance < radiusCloud) {
                    [tempKeyPointsArray replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:point]];
                    [tempKeyPointsArray replaceObjectAtIndex:j withObject:[NSNull null]];
                }
            }
        }
    }
    
    
    // Clean all NSNull
    self.pointKeyArray = [[NSMutableArray alloc]init];
    for (id keyPoint in tempKeyPointsArray) {
        if ((NSNull *) keyPoint != [NSNull null])
            [pointKeyArray addObject:keyPoint];
    }
    
    
    // Remove points aligned (step A)
    // --------------------------------------------------------------------------
    NSMutableArray *edgePoints = [NSMutableArray array];
    if ([pointKeyArray count] > 0) {
        [edgePoints addObject:[pointKeyArray objectAtIndex:0]];
        
        for (int i = 0 ; i+2 < [pointKeyArray count] ; i++) {
            
            CGPoint pointKeyA = [[pointKeyArray objectAtIndex:i]CGPointValue];
            CGPoint pointKeyB = [[pointKeyArray objectAtIndex:i+1]CGPointValue];
            CGPoint pointKeyC = [[pointKeyArray objectAtIndex:i+2]CGPointValue];
            
            SYSegment *segment = [[SYSegment alloc]initWithPoint:pointKeyA andPoint:pointKeyC];
            CGFloat longitude = [segment longitude];
            
            if ([segment distanceToPoint:pointKeyB] < longitude * 0.12) {
                [pointKeyArray replaceObjectAtIndex:i+1 withObject:[NSNull null]];
                i = i+1;
            }
            
            [segment release];
        }
    }
    
    // Clean all NSNull
    NSMutableArray *finalArray = [NSMutableArray array];
    for (id keyPoint in pointKeyArray) {
        if ((NSNull *) keyPoint != [NSNull null]) {
            CGPoint newCGPoint = [keyPoint CGPointValue];
            NSValue *newPoint = [NSValue valueWithCGPoint:CGPointMake(newCGPoint.x, vectorView.bounds.size.height - newCGPoint.y)];
            [finalArray addObject:newPoint];
        }
    }
    
    
    // Is the painted shape closed (almost closed)?
    // --------------------------------------------------------------------------
    CGFloat deltaX = [[listPoints objectAtIndex:0]CGPointValue].x - [[listPoints lastObject]CGPointValue].x;
    CGFloat deltaY = [[listPoints objectAtIndex:0]CGPointValue].y - [[listPoints lastObject]CGPointValue].y;
    CGFloat ratioXClose = deltaX / maxDeltaX; 
    CGFloat ratioYClose = deltaY / maxDeltaY; 
    
    // It's open, do nothing, exit
    if (fabs(ratioXClose) > 0.25 || fabs(ratioYClose) > 0.25)
        return;
    
    // It's closed (almost closed), do closed perfectly
    CGPoint firstPoint = [[finalArray objectAtIndex:0]CGPointValue];
    CGPoint lastPoint = [[finalArray lastObject]CGPointValue];
    CGPoint midPoint = [self midPointBetweenPoint:firstPoint andPoint:lastPoint];
    [finalArray replaceObjectAtIndex:0 withObject:[NSValue valueWithCGPoint:midPoint]];
    [finalArray removeLastObject];
    
    // Clean all NSNull
    finalArray = [NSMutableArray array];
    for (id keyPoint in pointKeyArray) {
        if ((NSNull *) keyPoint != [NSNull null]) {
            CGPoint newCGPoint = [keyPoint CGPointValue];
            NSValue *newPoint = [NSValue valueWithCGPoint:CGPointMake(newCGPoint.x, newCGPoint.y)];
            [finalArray addObject:newPoint];
        }
    }
    
    // If the resulting points number is insufficient, exit
    self.pointKeyArray = [[NSMutableArray alloc]initWithArray:finalArray];
    if ([pointKeyArray count] < 2)
        return;
    
    
    // Remove points aligned (step B)
    // -----------------------------------------------------------------------
    NSMutableArray *pointAlign = [NSMutableArray arrayWithArray:pointKeyArray];
    for (int i = 0 ; i < [pointKeyArray count]; i++) {
        
        BOOL isBreak = NO;
        CGPoint pointA = [[pointAlign objectAtIndex:i]CGPointValue];
        CGPoint pointB = [[pointAlign objectAtIndex:i+1]CGPointValue];
        CGPoint pointC = CGPointZero;
        
        // Is it the last point?... take the first
        if (i+2 == [pointAlign count]) {
            pointC = [[pointAlign objectAtIndex:0]CGPointValue];
            isBreak = YES;
        }
        else
            pointC = [[pointAlign objectAtIndex:i+2]CGPointValue];
        
        CGFloat angleRad = fabsf([self getAngleBetweenVertex:pointB andPointA:pointA andPointB:pointC]);
        
        // Is it aligned
        if (angleRad > 2.4) { // casi 180º grados
            [pointAlign removeObjectAtIndex:i+1];
            i--;
            
            // If the resulting points number is insufficient, exit
            if ([pointAlign count] < 3)
                return;
        }
        
        if (isBreak)
            break;
    }
    
    // Clean all NSNull
    self.pointKeyArray = [[NSMutableArray alloc]init];
    for (id point in pointAlign) {
        if ((NSNull *) point != [NSNull null])
            [pointKeyArray addObject:point];
    }  
    
    
    // Snap Angles
    // ----------------------------------------------------------------
    // Build segment array
    NSMutableArray *segmentsArray  = [NSMutableArray array];
    for (int i = 0 ; i < [pointKeyArray count]; i++) {
        BOOL isBreak = NO;
        CGPoint pointA = [[pointKeyArray objectAtIndex:i]CGPointValue];
        CGPoint pointB = CGPointZero;
        
        // Is it the last point?... take the first
        if (i+1 == [pointKeyArray count]) {
            pointB = [[pointKeyArray objectAtIndex:0]CGPointValue];
            isBreak = YES;
        }
        else
            pointB = [[pointKeyArray objectAtIndex:i+1]CGPointValue];
        
        SYSegment *segment = [[SYSegment alloc]initWithPoint:pointA andPoint:pointB];
        [segmentsArray addObject:segment];
        
        if (isBreak)
            break;
    }
    
    // Snap all the segments
    for (SYSegment *segment in segmentsArray) {
        if ([segment isSnapAngle])
            [segment snapAngleChangingFinalPoint];
    }
    
    
    // Take the intersection between the segments (it will be key points)
    for (int i = 0 ; i < [segmentsArray count]; i++) {
        BOOL isBreak = NO;
        SYSegment *segmentA = [segmentsArray objectAtIndex:i];
        SYSegment *segmentB = nil;
        
        // Is it the last point?... take the first
        if (i+1 == [segmentsArray count]) {
            segmentB = [segmentsArray objectAtIndex:0];
            isBreak = YES;
        }
        else
            segmentB = [segmentsArray objectAtIndex:i+1];
        
        // Get the intersection point
        CGPoint intersectPoint = [segmentA pointIntersectWithSegment:segmentB];
        
        [segmentA setPointFn:intersectPoint];
        [segmentB setPointSt:intersectPoint];
        
        if (isBreak)
            break;        
    }
    
    // Get the final key points
    self.pointKeyArray  = [[NSMutableArray alloc]init];
    SYSegment *segment = [segmentsArray objectAtIndex:0];
    [self.pointKeyArray addObject:[NSValue valueWithCGPoint:[segment pointSt]]];
    
    for (SYSegment *segment in segmentsArray) {
        [self.pointKeyArray addObject:[NSValue valueWithCGPoint:[segment pointFn]]];
        //NSLog(@"%f", [segment angleDeg]);
    }
    
    [self createPolygonal];
 
}// getFigurePainted


#pragma mark - Create Geometric Methods

- (void) createBezierCurveWithPoints:(NSArray *) arrayData
{
    // Draw the resulting shape
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = BezierType;
    geometry.pointArray = [NSArray arrayWithArray:arrayData];
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor redColor];//[UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    [[vectorView shapeList]addObject:geometry];
    [vectorView setNeedsDisplay];
    
    [geometry release];
    
}// createBezierCurveWithPoints


- (void) createPolygonal
{
    // Draw the resulting shape
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = LinesType;
    
    // Origin XY conversion
    NSMutableArray *finalArray = [NSMutableArray array];
    for (id keyPoint in pointKeyArray) {
        if ((NSNull *) keyPoint != [NSNull null]) {
            CGPoint newCGPoint = [keyPoint CGPointValue];
            NSValue *newPoint = [NSValue valueWithCGPoint:CGPointMake(newCGPoint.x, vectorView.bounds.size.height - newCGPoint.y)];
            [finalArray addObject:newPoint];
        }
    }
    
    geometry.pointArray = [[NSArray alloc]initWithArray:finalArray];
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    [[vectorView shapeList]addObject:geometry];
    [vectorView setNeedsDisplay];
    
    [geometry release];
    
    return;
    
}// getFigurePainted


- (void) createSquare
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = SquareType;
    geometry.rectGeometry = CGRectMake( minX.x, vectorView.bounds.size.height - maxY.y, (maxX.x - minX.x), (maxY.y - minY.y));
    
    // Draw properties
    geometry.lineWidth = 2.0;
    geometry.fillColor = [UIColor whiteColor];
    geometry.strokeColor = [UIColor blackColor];
    
    //vectorView.shapeList = [[NSMutableArray alloc]initWithObjects:geometry, nil];
    [[vectorView shapeList]addObject:geometry];
    [vectorView setNeedsDisplay];
    
    [geometry release];
    
    return;
    
}// createSquare


- (void) createDiamond
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = DiamondType;
    geometry.rectGeometry = CGRectMake( minX.x, vectorView.bounds.size.height - maxY.y, (maxX.x - minX.x), (maxY.y - minY.y));
    
    // Draw properties
    geometry.lineWidth = 2.0;
    geometry.fillColor = [UIColor whiteColor];
    geometry.strokeColor = [UIColor blackColor];
    
    //vectorView.shapeList = [[NSMutableArray alloc]initWithObjects:geometry, nil];
    [[vectorView shapeList]addObject:geometry];
    [vectorView setNeedsDisplay];
    
    [geometry release];
    
    return;
    
}// createDiamond


- (void) createCircle
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = CircleType;
    geometry.rectGeometry = CGRectMake( minX.x, vectorView.bounds.size.height - maxY.y, (maxX.x - minX.x), (maxY.y - minY.y));
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor redColor];//[UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    //vectorView.shapeList = [[NSMutableArray alloc]initWithObjects:geometry, nil];
    [[vectorView shapeList]addObject:geometry];
    [vectorView setNeedsDisplay];
    
    [geometry release];
    
    return;
    
}// createCircle


- (void) createCircleWithTransform:(CGAffineTransform) transform
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = CircleType;
    geometry.rectGeometry = CGRectMake( minX.x, vectorView.bounds.size.height - maxY.y, (maxX.x - minX.x), (maxY.y - minY.y));
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor redColor];//[UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    geometry.transform = transform;
    
    //vectorView.shapeList = [[NSMutableArray alloc]initWithObjects:geometry, nil];
    [[vectorView shapeList]addObject:geometry];
    [vectorView setNeedsDisplay];
    
    [geometry release];
    
    return;
    
}// createCircleWithTransform


- (void) createArc:(CGPoint) midPoint radius:(NSUInteger) radius startAngle:(CGFloat) startAngle endAngle:(CGFloat) endAngle clockwise:(BOOL) clockwise
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = ArcType;
    [geometry setArcParametersWithMidPoint:midPoint
                                    radius:radius
                                startAngle:startAngle
                                  endAngle:endAngle
                              andClockWise:clockwise];
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor redColor];//[UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    //vectorView.shapeList = [[NSMutableArray alloc]initWithObjects:geometry, nil];
    [[vectorView shapeList]addObject:geometry];
    [vectorView setNeedsDisplay];
    
    [geometry release];
    
}// createArc:endAngle:


- (void) createTriangle
{    
    
}// createTriangle


-(void) dealloc
{
    [listPoints release];
    [listAngles release];
    
    [super dealloc];
    
}// dealloc

/*
#pragma mark - Temp Bezier

- (float) findDistance:(CGPoint)point lineA:(CGPoint)lineA lineB:(CGPoint)lineB
{
    CGPoint v1 = CGPointMake(lineB.x - lineA.x, lineB.y - lineA.y);
    CGPoint v2 = CGPointMake(point.x - lineA.x, point.y - lineA.y);
    float lenV1 = sqrt(v1.x * v1.x + v1.y * v1.y);
    float lenV2 = sqrt(v2.x * v2.x + v2.y * v2.y);
    float angle = acos((v1.x * v2.x + v1.y * v2.y) / (lenV1 * lenV2));
    return sin(angle) * lenV2;
}


- (NSArray *) douglasPeucker:(NSArray *)points epsilon:(float)epsilon
{
    int count = [points count];
    if(count < 3) {
        return points;
    }
    
    //Find the point with the maximum distance
    float dmax = 0;
    int index = 0;
    for(int i = 1; i < count - 1; i++) {
        CGPoint point = [[points objectAtIndex:i] CGPointValue];
        CGPoint lineA = [[points objectAtIndex:0] CGPointValue];
        CGPoint lineB = [[points objectAtIndex:count - 1] CGPointValue];
        float d = [self findDistance:point lineA:lineA lineB:lineB];
        if(d > dmax) {
            index = i;
            dmax = d;
        }
    }
    
    // If max distance is greater than epsilon, recursively simplify
    NSArray *resultList;
    if(dmax > epsilon) {
        NSArray *recResults1 = [self douglasPeucker:[points subarrayWithRange:NSMakeRange(0, index + 1)] epsilon:epsilon];
        
        NSArray *recResults2 = [self douglasPeucker:[points subarrayWithRange:NSMakeRange(index, count - index)] epsilon:epsilon];
        
        NSMutableArray *tmpList = [NSMutableArray arrayWithArray:recResults1];
        [tmpList removeLastObject];
        [tmpList addObjectsFromArray:recResults2];
        resultList = tmpList;
    }
    else
        resultList = [NSArray arrayWithObjects:[points objectAtIndex:0], [points objectAtIndex:count - 1],nil];
    
    return resultList;
}

- (NSArray *)catmullRomSplineAlgorithmOnPoints:(NSArray *)points segments:(int)segments
{
    int count = [points count];
    if(count < 4) {
        return points;
    }
    
    float b[segments][4];
    {
        // precompute interpolation parameters
        float t = 0.0f;
        float dt = 1.0f/(float)segments;
        for (int i = 0; i < segments; i++, t+=dt) {
            float tt = t*t;
            float ttt = tt * t;
            b[i][0] = 0.5f * (-ttt + 2.0f*tt - t);
            b[i][1] = 0.5f * (3.0f*ttt -5.0f*tt +2.0f);
            b[i][2] = 0.5f * (-3.0f*ttt + 4.0f*tt + t);
            b[i][3] = 0.5f * (ttt - tt);
        }
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    {
        int i = 0; // first control point
        [resultArray addObject:[points objectAtIndex:0]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGPoint pointIp2 = [[points objectAtIndex:(i + 2)] CGPointValue];
            float px = (b[j][0]+b[j][1])*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x;
            float py = (b[j][0]+b[j][1])*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    
    for (int i = 1; i < count-2; i++) {
        // the first interpolated point is always the original control point
        [resultArray addObject:[points objectAtIndex:i]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointIm1 = [[points objectAtIndex:(i - 1)] CGPointValue];
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGPoint pointIp2 = [[points objectAtIndex:(i + 2)] CGPointValue];
            float px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x;
            float py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    
    {
        int i = count-2; // second to last control point
        [resultArray addObject:[points objectAtIndex:i]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointIm1 = [[points objectAtIndex:(i - 1)] CGPointValue];
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            float px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + (b[j][2]+b[j][3])*pointIp1.x;
            float py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + (b[j][2]+b[j][3])*pointIp1.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    // the very last interpolated point is the last control point
    [resultArray addObject:[points objectAtIndex:(count - 1)]]; 
    
    return resultArray;
}
*/
@end