//
//  TCViewController.m
//  TouchChart
//
//  Created by Adam Wulf on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TCViewController.h"
#import "SYVectorView.h"

@interface TCViewController ()

@end

@implementation TCViewController

#pragma mark - Lifecycle Methods

- (void) viewDidLoad
{
    [super viewDidLoad];
    
}// viewDidLoad


- (void) viewDidUnload
{
    [super viewDidUnload];
    
    [freePaint release];
    freePaint = nil;
    
    [vectorView release];
    vectorView = nil;
    
}// viewDidUnload


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Support all orientations
    return YES;

}// shouldAutorotateToInterfaceOrientation:


- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [vectorView setNeedsDisplay];
    
}// willRotateToInterfaceOrientation:duration:


- (void) dealloc
{
    [super dealloc];
    
    [freePaint release];
    [vectorView release];
    
}// dealloc

@end
