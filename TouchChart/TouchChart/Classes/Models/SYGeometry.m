//
//  SYGeometry.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 16/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SYGeometry.h"

@implementation SYGeometry

@synthesize geometryType;
@synthesize rectGeometry;
@synthesize pointArray;

@synthesize lineWidth;
@synthesize fillColor;
@synthesize strokeColor;

-(void) dealloc
{
    [fillColor release];
    [strokeColor release];
    
    [super dealloc];
    
}// dealloc

@end
