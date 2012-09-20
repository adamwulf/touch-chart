//
//  SYUnitTestController.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 22/08/12.
//
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

@class TCViewController;

@interface SYUnitTestController : NSObject <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UITableView *myTableView;
    IBOutlet UIButton *closeButton;
    
    IBOutlet TCViewController *viewController;
}

@property (nonatomic, assign) IBOutlet UITableViewCell *unitTestCell;

// Save/Load Operations
- (void) importPointsStored:(PFObject *) listPointStored;
- (void) saveListPoints:(NSArray *) allPoints withName:(NSString *) name;
- (void) updateListPointStored;

@end
