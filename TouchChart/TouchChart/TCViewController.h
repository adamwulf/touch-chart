//
//  TCViewController.h
//  TouchChart
//
//  Created by Adam Wulf on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYFreePaintView;
@class SYVectorView;

@interface TCViewController : UIViewController {
    
    IBOutlet SYFreePaintView *freePaint;
    IBOutlet SYVectorView *vectorView;
    
}

@end
