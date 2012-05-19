//
//  SYGeometry.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 16/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	SquareType,
	CircleType,
	DiamondType
} GeometryType;

@interface SYGeometry : NSObject {
    
    GeometryType geometryType;
    
    // Geometry parameters
    CGRect rectGeometry;
    
    // Draw properties
    CGFloat lineWidth;
    UIColor *fillColor;
    UIColor *strokeColor;
    
}

@property (nonatomic) GeometryType geometryType;
@property (nonatomic) CGRect rectGeometry;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, retain) UIColor *fillColor;
@property (nonatomic, retain) UIColor *strokeColor;

@end
