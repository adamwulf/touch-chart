//
//  SYSegment.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 01/06/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import "SYSegment.h"

@implementation SYSegment 

#define zero 1e-8
#define inf 1e100
#define equal(a,b)  (fabs((a)-(b))<zero)

@synthesize pointSt;
@synthesize pointFn;

- (NSString *) description
{
    return [NSString stringWithFormat:@"StartPoint(%f, %f)     EndPoint(%f, %f)", pointSt.x, pointSt.y, pointFn.x, pointFn.y];
    
}// description


- (id) initWithPoint:(CGPoint) pointA andPoint:(CGPoint) pointB
{
    self = [super init];

    if (self) {

        self.pointSt = pointA;
        self.pointFn = pointB;

    }

    return self;

}// initWithPoint:andPoint:


- (void) dealloc
{
    [super dealloc];

}// dealloc


#pragma mark - Geometric Methods

// Cuadrado de la distancia
- (CGFloat) moduleTwo:(CGPoint)puntoA and:(CGPoint)puntoB
{
    return (puntoB.x-puntoA.x)*(puntoB.x-puntoA.x) + (puntoB.y-puntoA.y)*(puntoB.y-puntoA.y);
    
}// moduleTwo:and:


// Distancia punto a punto en 2 dimensiones
- (CGFloat) distance:(CGPoint)puntoA and:(CGPoint)puntoB
{
    return sqrt([self moduleTwo:puntoA and:puntoB]);

}// distance:and:


// Longitud del vector
- (CGFloat) longitude
{
    return sqrt([self moduleTwo:pointSt and:pointFn]);
    
}// longitude


// Distancia del segmento al punto C
- (CGFloat) distanceToPoint:(CGPoint) C
{
    // Punto en el segmento al cual se calculará la distancia
    // iniciamos en uno de los extremos
    CGPoint P = pointSt;
    
    // Para prevenir una división por cero se calcula primero el demoninador de
    // la división. (Se puede dar si A y B son el mismo punto).
    // Podría substituirse por [self moduleTwo:A a:B]
    CGFloat denominador = (pointFn.x-pointSt.x)*(pointFn.x-pointSt.x)+(pointFn.y-pointSt.y)*(pointFn.y-pointSt.y);

    if(denominador !=0){

        // Se calcula el parámetro, que indica la posición del punto P en la recta
        // del segmento
        CGFloat u = ((C.x - pointSt.x) * (pointFn.x - pointSt.x) + (C.y - pointSt.y) * (pointFn.y - pointSt.y))/denominador;

        // Si u esta en el intervalo [0,1], el punto P pertenece al segmento
        if(u > 0.0 && u < 1.0) {
            P.x = pointSt.x + u * (pointFn.x - pointSt.x);
            P.y = pointSt.y + u * (pointFn.y - pointSt.y);
        }

        // Si P no pertenece al segmento se toma uno de los extremos para calcular
        // la distancia. Si u < 0 el extremo es A. Si u >=1 el extremos es B.
        else{
            if( u>= 1.0)
                P=pointFn;
        }
    }

    // Se devuelve la distancia entre el punto C y el punto P calculado.
    return [self distance:P and:C];

}// distanceToPoint:


- (CGPoint) pointIntersectWithSegment:(SYSegment *) anotherSegment
{
    // Comprueba que tiene pendientes diferentes
    float fS1ope1 = (equal(self.pointSt.x, self.pointFn.x)) ? (inf) : ((self.pointFn.y - self.pointSt.y)/(self.pointFn.x - self.pointSt.x));
    float fS1ope2 = (equal(anotherSegment.pointSt.x, anotherSegment.pointFn.x)) ? (inf) : ((anotherSegment.pointFn.y - anotherSegment.pointSt.y)/(anotherSegment.pointFn.x - anotherSegment.pointSt.x));
    
    // Si son iguales, ambas rectas son paralelas y no se cruzan
    if (equal(fS1ope1, fS1ope2)) {
        if (equal(self.pointSt.y - fS1ope1 * self.pointSt.x,
                  anotherSegment.pointSt.y - fS1ope2 * anotherSegment.pointSt.x)) {
            NSLog(@"LINE\n");
        }
        else
            NSLog(@"NONE\n");
        
        CGPoint errorPoint = CGPointMake(10000, 10000);
        return errorPoint;
    }

    // Sino, se cruzarán en algun momento. Calcula ese punto
    CGPoint ptIntersect = CGPointZero;
    ptIntersect.x = (fS1ope1 * self.pointSt.x - self.pointSt.y - fS1ope2 * anotherSegment.pointSt.x + anotherSegment.pointSt.y)/(fS1ope1 - fS1ope2);
    if (equal(self.pointSt.x, self.pointFn.x))
        ptIntersect.x = self.pointSt.x;
    if (equal(anotherSegment.pointSt.x, anotherSegment.pointFn.x))
        ptIntersect.x = anotherSegment.pointSt.x;
    
    ptIntersect.y = fS1ope1 * (ptIntersect.x - self.pointSt.x) + self.pointSt.y;
    if (equal(self.pointSt.x, self.pointFn.x))
        ptIntersect.y = fS1ope2 * (ptIntersect.x - anotherSegment.pointSt.x) + anotherSegment.pointSt.y;

    return ptIntersect;
    
}// pointIntersectWithSegment:


#pragma mark - Angles Methods

- (CGFloat) angleRad
{
    CGFloat deltaX = pointFn.x - pointSt.x;
    CGFloat deltaY = pointFn.y - pointSt.y;
    
    if (deltaX == .0) {
        if (deltaY > .0)
            return M_PI_2;
        else if (deltaY < .0)
            return -M_PI_2;
    }

    
    if (deltaY == .0) {
        if (deltaX > .0)
            return .0;
        else if (deltaX < .0)
            return -M_PI;
    }
    
    // Obtiene a través del arco tangente
    return atanf(deltaY/deltaX);
    
}// angleRad


- (CGFloat) angleDeg
{
    CGFloat angle = [self angleRad];
    return (angle/M_PI) * 180.0;
    
}// angleDeg


- (void) setStartPointToDegree:(CGFloat) angle
{
    CGFloat angleRad = (angle/90.0) * M_PI_2;
    
    // sen/cos = tan ----> sen = tan * cos
    if (fabs(angle) == .0 || fabs(angle) == 180.0)
        pointSt.y = pointFn.y;
    if (fabs(angle) == 90.0)
        pointSt.x = pointFn.x;
    else {
        // sen/cos = tan ----> sen = tan * cos
        CGFloat deltaY = (pointSt.x - pointFn.x) * tanf(angleRad);
        pointSt.y = deltaY + pointFn.y;
    }   
    
}// setStartPointToDegree:


- (void) setMiddlePointToDegree:(CGFloat) angle
{
    CGFloat angleRad = (angle/90.0) * M_PI_2;
    
    // sen/cos = tan ----> sen = tan * cos
    if (fabs(angle) == .0 || fabs(angle) == 180.0) {
        CGFloat midY = (pointFn.y + pointSt.y) * 0.5;
        pointSt.y = midY;
        pointFn.y = midY;
    }
    if (fabs(angle) == 90.0) {
        CGFloat midX = (pointFn.x + pointSt.x) * 0.5;
        pointSt.x = midX;
        pointFn.x = midX;
    }
    else {
        CGFloat deltaY = (pointFn.x - pointSt.x) * tanf(angleRad);
        pointSt.y = pointSt.y + (deltaY * 0.5);
        pointFn.y = pointFn.y - (deltaY * 0.5);
    }
    
}// setMiddlePointToDegree


- (void) setFinalPointToDegree:(CGFloat) angle
{
    CGFloat angleRad = (angle/90.0) * M_PI_2;
    
    // sen/cos = tan ----> sen = tan * cos
    if (fabs(angle) == .0 || fabs(angle) == 180.0)
        pointFn.y = pointSt.y;
    if (fabs(angle) == 90.0)
        pointFn.x = pointSt.x;
    else {
        CGFloat deltaY = (pointFn.x - pointSt.x) * tan(angleRad);
        pointFn.y = pointSt.y + deltaY;
    }
    
}// setFinalPointToDegree:


- (void) snapAngleChangingStartPoint
{
    // Si es distinto de .0 o 90.0, y ajusta al punto B
    CGFloat angleDeg = [self angleDeg];
    if ([self isSnapAngle]) {
        if (angleDeg > .0) {
            if (angleDeg < 15.0)
                [self setStartPointToDegree:.0];
            else if (angleDeg < 37.5)
                [self setStartPointToDegree:30.0];
            else if (angleDeg < 52.5)
                [self setStartPointToDegree:45.0];
            else if (angleDeg < 75.0)
                [self setStartPointToDegree:60.0];
            else if (angleDeg < 90.0 + 15.0)
                [self setStartPointToDegree:90.0];
            else if (angleDeg < 90.0 + 37.5)
                [self setStartPointToDegree:90.0 + 30.0];
            else if (angleDeg < 90.0 + 52.5)
                [self setStartPointToDegree:90.0 + 45.0];
            else if (angleDeg < 90.0 + 75.0)
                [self setStartPointToDegree:90.0 + 60.0];
            else
                [self setStartPointToDegree:180.0];
        }
        else {
            if (angleDeg > -15.0)
                [self setStartPointToDegree:.0];
            else if (angleDeg > -37.5)
                [self setStartPointToDegree:-30.0];
            else if (angleDeg > -52.5)
                [self setStartPointToDegree:-45.0];
            else if (angleDeg > -75.0)
                [self setStartPointToDegree:-60.0];
            else if (angleDeg > -90.0 - 15.0)
                [self setStartPointToDegree:-90.0];
            else if (angleDeg > -90.0 - 37.5)
                [self setStartPointToDegree:-90.0 - 30.0];
            else if (angleDeg > -90.0 - 52.5)
                [self setStartPointToDegree:-90.0 - 45.0];
            else if (angleDeg > -90.0 - 75.0)
                [self setStartPointToDegree:-90.0 - 60.0];
            else
                [self setStartPointToDegree:-180.0];
        }
    }
    
}// snapAngleChangingStartPoint


- (void) snapAngleChangingFromMiddlePoint
{
    NSLog(@"Inicio: %f", [self angleDeg]);
    // Si es distinto de .0 o 90.0, y ajusta al punto B
    CGFloat angleDeg = [self angleDeg];
    if ([self isSnapAngle]) {
        if (angleDeg > .0) {
            if (angleDeg < 15.0)
                [self setMiddlePointToDegree:.0];
            else if (angleDeg < 37.5)
                [self setMiddlePointToDegree:30.0];
            else if (angleDeg < 52.5)
                [self setMiddlePointToDegree:45.0];
            else if (angleDeg < 75.0)
                [self setMiddlePointToDegree:60.0];
            else if (angleDeg < 90.0 + 15.0)
                [self setMiddlePointToDegree:90.0];
            else if (angleDeg < 90.0 + 37.5)
                [self setMiddlePointToDegree:90.0 + 30.0];
            else if (angleDeg < 90.0 + 52.5)
                [self setMiddlePointToDegree:90.0 + 45.0];
            else if (angleDeg < 90.0 + 75.0)
                [self setMiddlePointToDegree:90.0 + 60.0];
            else
                [self setMiddlePointToDegree:180.0];
        }
        else {
            if (angleDeg > -15.0)
                [self setMiddlePointToDegree:.0];
            else if (angleDeg > -37.5)
                [self setMiddlePointToDegree:-30.0];
            else if (angleDeg > -52.5)
                [self setMiddlePointToDegree:-45.0];
            else if (angleDeg > -75.0)
                [self setMiddlePointToDegree:-60.0];
            else if (angleDeg > -90.0 - 15.0)
                [self setMiddlePointToDegree:-90.0];
            else if (angleDeg > -90.0 - 37.5)
                [self setMiddlePointToDegree:-90.0 - 30.0];
            else if (angleDeg > -90.0 - 52.5)
                [self setMiddlePointToDegree:-90.0 - 45.0];
            else if (angleDeg > -90.0 - 75.0)
                [self setMiddlePointToDegree:-90.0 - 60.0];
            else
                [self setMiddlePointToDegree:-180.0];
        }
    }
    
    NSLog(@"Final: %f", [self angleDeg]);

}// snapAngleChangingFromMiddlePoint


- (void) snapAngleChangingFinalPoint
{
    // Si es distinto de .0 o 90.0, y ajusta al punto B
    CGFloat angleDeg = [self angleDeg];
    if ([self isSnapAngle]) {
        if (angleDeg > .0) {
            if (angleDeg < 15.0)
                [self setFinalPointToDegree:.0];
            else if (angleDeg < 37.5)
                [self setFinalPointToDegree:30.0];
            else if (angleDeg < 52.5)
                [self setFinalPointToDegree:45.0];
            else if (angleDeg < 75.0)
                [self setFinalPointToDegree:60.0];
            else if (angleDeg < 90.0 + 15.0)
                [self setFinalPointToDegree:90.0];
            else if (angleDeg < 90.0 + 37.5)
                [self setFinalPointToDegree:90.0 + 30.0];
            else if (angleDeg < 90.0 + 52.5)
                [self setFinalPointToDegree:90.0 + 45.0];
            else if (angleDeg < 90.0 + 75.0)
                [self setFinalPointToDegree:90.0 + 60.0];
            else
                [self setFinalPointToDegree:180.0];
        }
        else {
            if (angleDeg > -15.0)
                [self setFinalPointToDegree:.0];
            else if (angleDeg > -37.5)
                [self setFinalPointToDegree:-30.0];
            else if (angleDeg > -52.5)
                [self setFinalPointToDegree:-45.0];
            else if (angleDeg > -75.0)
                [self setFinalPointToDegree:-60.0];
            else if (angleDeg > -90.0 - 15.0)
                [self setFinalPointToDegree:-90.0];
            else if (angleDeg > -90.0 - 37.5)
                [self setFinalPointToDegree:-90.0 - 30.0];
            else if (angleDeg > -90.0 - 52.5)
                [self setFinalPointToDegree:-90.0 - 45.0];
            else if (angleDeg > -90.0 - 75.0)
                [self setFinalPointToDegree:-90.0 - 60.0];
            else
                [self setFinalPointToDegree:-180.0];
        }
    }
        
}// snapAngleChangingFinalPoint


- (BOOL) isSnapAngle
{
    CGFloat angleDeg = [self angleDeg];
    
    /*
    // Si no esta ajustado responde que no
    CGFloat resultAbs = fabsf(angleDeg);
    
    if (resultAbs < 5.0)
        return YES;

    CGFloat ratio = 30.0/resultAbs;     // de 25 a 35 grados
    if (ratio > 0.85 && ratio < 1.2)
        return YES;
    
    ratio = 45.0/resultAbs;             // de 40 a 50 grados
    if (ratio < 1.125 && ratio > 0.9)
        return YES;
    
    ratio = 60.0/resultAbs;             // de 55 a 65 grados
    if (ratio < 1.091 && ratio > 0.923)
        return YES;
    
    ratio = 90.0/resultAbs;             // de 85 a 95 grados
    if (ratio < 1.0588 && ratio > 0.947)
        return YES;
    
    ratio = 120.0/resultAbs;             // de 115 a 125 grados
    if (ratio < 1.043 && ratio > 0.96)
        return YES;
    
    ratio = 135.0/resultAbs;             // de 130 a 140 grados
    if (ratio < 1.0384 && ratio > 0.9643)
        return YES;
    
    ratio = 150.0/resultAbs;             // de 145 a 155 grados
    if (ratio < 1.0345 && ratio > 0.9677)
        return YES;
    
    ratio = 180.0/resultAbs;             // de 175 a 185 grados
    if (ratio < 1.0286 && ratio > 0.973)
        return YES;
    
    return NO;
    */
    
    
    // Si no esta ajustado responde que no
    CGFloat resultAbs = fabsf(angleDeg);

    if (resultAbs < 10.0)
        return YES;
    
    if (resultAbs > 20.0 && resultAbs < 40.0)    // de 20 a 40 grados
        return YES;
    
    if (resultAbs > 35.0 && resultAbs < 55.0)    // de 35 a 55 grados
        return YES;
    
    if (resultAbs > 50.0 && resultAbs < 70.0)    // de 50 a 70 grados
        return YES;
    
    if (resultAbs > 80.0 && resultAbs < 100.0)    // de 80 a 100 grados
        return YES;
    
    if (resultAbs > 110.0 && resultAbs < 130.0)    // de 110 a 130 grados
        return YES;
    
    if (resultAbs > 125.0 && resultAbs < 145.0)    // de 125 a 145 grados
        return YES;
    
    if (resultAbs > 140.0 && resultAbs < 160.0)    // de 140 a 160 grados
        return YES;
    
    if (resultAbs > 170.0 && resultAbs < 190.0)    // de 170 a 190 grados
        return YES;
    
    return NO;
     
}// isSnapAngle

@end
