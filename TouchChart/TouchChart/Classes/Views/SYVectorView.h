//
//  SYVectorView.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 14/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYShape;

@interface SYVectorView : UIView

@property (nonatomic, strong) NSMutableArray *shapeList;

- (void) addShape:(SYShape *)shape;
- (IBAction)clear:(id)sender;

@end
