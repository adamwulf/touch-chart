//
//  TCViewController.m
//  TouchChart
//
//  Created by Adam Wulf on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TCViewController.h"
#import "SYFreePaintView.h"

@interface TCViewController ()

@end

@implementation TCViewController

#pragma mark - Lifecycle Methods

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Set initial the brush color
	[(SYFreePaintView *)[[[self view]subviews]objectAtIndex:0] setBrushColorWithRed:.0 green:.0 blue:1.0];

}// viewDidLoad


- (void) viewDidUnload
{
    [super viewDidUnload];
    
}// viewDidUnload


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    else
        return YES;

}// shouldAutorotateToInterfaceOrientation:

@end
