//
//  SYUnitTestController.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 22/08/12.
//
//

#import "SYUnitTestController.h"
#import "SYUnitPreview.h"

#import "SYPaintView.h"
#import "TCViewController.h"

@interface SYUnitTestController () {

    NSMutableArray *pfObjects;
    
}

@end


@implementation SYUnitTestController

@synthesize unitTestCell;

- (void) dealloc
{
    [pfObjects release];
    pfObjects = nil;
    
    myTableView = nil;
    closeButton = nil;

    viewController = nil;
        
    [super dealloc];
    
}// dealloc


#pragma mark - Save/Load Operations

-(void) importPointsStored:(PFObject *) pfObject
{    
    // List point convert
    NSMutableArray *listPoints = [NSMutableArray array];
    NSMutableArray *listPointStored = [pfObject objectForKey:@"listPoints"];
    for (NSDictionary *dictPoint in listPointStored) {
        CGPoint point = CGPointMake([[dictPoint valueForKey:@"x"]floatValue], [[dictPoint valueForKey:@"y"]floatValue]);
        [listPoints addObject:[NSValue valueWithCGPoint:point]];
    }
    
    
    // Point Key convert
    NSMutableArray *pointKeyArray = [NSMutableArray array];
    NSMutableArray *pointKeyArrayStored = [pfObject objectForKey:@"pointKeyArray"];
    for (NSDictionary *dictPoint in pointKeyArrayStored) {
        CGPoint point = CGPointMake([[dictPoint valueForKey:@"x"]floatValue], [[dictPoint valueForKey:@"y"]floatValue]);
        [pointKeyArray addObject:[NSValue valueWithCGPoint:point]];
    }
    
    
    // Max and Min
    NSDictionary *maxXDict = [pfObject objectForKey:@"maxX"];
    NSDictionary *maxYDict = [pfObject objectForKey:@"maxY"];
    NSDictionary *minXDict = [pfObject objectForKey:@"minX"];
    NSDictionary *minYDict = [pfObject objectForKey:@"minY"];
    
    CGPoint maxX = CGPointMake([[maxXDict valueForKey:@"x"]floatValue], [[maxXDict valueForKey:@"y"]floatValue]);
    CGPoint maxY = CGPointMake([[maxYDict valueForKey:@"x"]floatValue], [[maxYDict valueForKey:@"y"]floatValue]);
    CGPoint minX = CGPointMake([[minXDict valueForKey:@"x"]floatValue], [[minXDict valueForKey:@"y"]floatValue]);
    CGPoint minY = CGPointMake([[minYDict valueForKey:@"x"]floatValue], [[minYDict valueForKey:@"y"]floatValue]);
    
    NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjectsAndKeys:listPoints, @"listPoints", pointKeyArray, @"pointKeyArray", [NSValue valueWithCGPoint:maxX], @"maxX", [NSValue valueWithCGPoint:maxY], @"maxY", [NSValue valueWithCGPoint:minX], @"minX", [NSValue valueWithCGPoint:minY], @"minY", nil];
    
    [viewController importCase:dataDictionary];    

}// importPointsStored


- (void) saveListPoints:(NSDictionary *) dataDictionary forKey:(NSString *) key
{
    NSArray *listPoints = [dataDictionary valueForKey:@"listPoints"];
    NSArray *pointKeyArray = [dataDictionary valueForKey:@"pointKeyArray"];
    NSValue *maxXValue = [dataDictionary valueForKey:@"maxX"];
    NSValue *maxYValue = [dataDictionary valueForKey:@"maxY"];
    NSValue *minXValue = [dataDictionary valueForKey:@"minX"];
    NSValue *minYValue = [dataDictionary valueForKey:@"minY"];
    
    // Convert NSValue Array in NSDictionary Array
    // because PFObject doesn't work with NSValue
    NSMutableArray *listPointToStore = [NSMutableArray array];
    for (NSValue *pointValue in listPoints) {
        NSDictionary *dictPoint = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:[pointValue CGPointValue].x], @"x", [NSNumber numberWithFloat:[pointValue CGPointValue].y], @"y", nil];
        [listPointToStore addObject:dictPoint];
    }
    
    NSMutableArray *pointKeyArrayToStore = [NSMutableArray array];
    for (NSValue *pointValue in pointKeyArray) {
        NSDictionary *dictPoint = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:[pointValue CGPointValue].x], @"x", [NSNumber numberWithFloat:[pointValue CGPointValue].y], @"y", nil];
        [pointKeyArrayToStore addObject:dictPoint];
    }
    
    NSDictionary *maxX = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:[maxXValue CGPointValue].x], @"x", [NSNumber numberWithFloat:[maxXValue CGPointValue].y], @"y", nil];
    NSDictionary *maxY = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:[maxYValue CGPointValue].x], @"x", [NSNumber numberWithFloat:[maxYValue CGPointValue].y], @"y", nil];
    NSDictionary *minX = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:[minXValue CGPointValue].x], @"x", [NSNumber numberWithFloat:[minXValue CGPointValue].y], @"y", nil];
    NSDictionary *minY = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:[minYValue CGPointValue].x], @"x", [NSNumber numberWithFloat:[minYValue CGPointValue].y], @"y", nil];
    
    PFObject *testObject = [PFObject objectWithClassName:@"ListPoints"];
    [testObject setObject:listPointToStore forKey:@"listPoints"];
    [testObject setObject:pointKeyArrayToStore forKey:@"pointKeyArray"];
    [testObject setObject:maxX forKey:@"maxX"];
    [testObject setObject:maxY forKey:@"maxY"];
    [testObject setObject:minX forKey:@"minX"];
    [testObject setObject:minY forKey:@"minY"];    
    [testObject setObject:key forKey:@"name"];
    [testObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self updateListPointStored];
        } else {
            // Avisa del error obtenido
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[error domain] capitalizedString]
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"Accept"
                                                  otherButtonTitles:nil];
            [alert show];            
        }
    }];
    
}// saveListPoints


- (void) updateListPointStored
{
    PFQuery *query = [PFQuery queryWithClassName:@"ListPoints"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            [pfObjects release];
            pfObjects = [[NSMutableArray alloc]initWithArray:objects];
            [myTableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [pfObjects release];
            pfObjects = nil;
        }
    }];
    
}// updateListPointStored


#pragma mark - UITableViewDelegate Protocol

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Data
    PFObject *pfObject = [pfObjects objectAtIndex:indexPath.row];
    [self importPointsStored:pfObject];
    
}// tableView:didSelectRowAtIndexPath:


- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete from server
        PFObject *testObject = [pfObjects objectAtIndex:indexPath.row];
        [testObject deleteInBackground];

        // Delete from tableview
        [pfObjects removeObject:testObject];
        [tableView reloadData];
        
        // If it's the last case, close tableview
        if ([pfObjects count] == 0)
            [viewController switchShowTable:nil];
    }
    
}// tableView:commitEditingStyle:forRowAtIndexPath:


- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
    
}// tableView:editingStyleForRowAtIndexPath:


- (void) tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{    
    // Take the preview view from that cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    SYUnitPreview *preview = (SYUnitPreview *)[cell viewWithTag:3];
    
    // Hide preview view
    [UIView animateWithDuration:0.2 animations:^{
        [preview setAlpha:.0];
    }];
    
    // Hide close button background
    [closeButton setHidden:YES];
    
    return;
    
}// tableView:willBeginEditingRowAtIndexPath:


- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{    
    // Take the preview view from that cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    SYUnitPreview *preview = (SYUnitPreview *)[cell viewWithTag:3];
    
    // Show preview view
    [UIView animateWithDuration:0.2 animations:^{
        [preview setAlpha:1.0];
    }completion:^(BOOL finished){
        // Show close button background
        [closeButton setHidden:NO];
    }];
    
}// tableView:didEndEditingRowAtIndexPath:


#pragma mark - UITableViewDataSource Protocol

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}// numberOfSectionsInTableView:


- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
    
}// tableView:titleForHeaderInSection:


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [pfObjects count];
    
}// tableView:numberOfRowsInSection:


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleTableIdentifier = @"TestTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"UnitTestCell" owner:self options:nil];
        cell = unitTestCell;
        self.unitTestCell = nil;
    }
    
    // Data
    PFObject *pfObject = [pfObjects objectAtIndex:indexPath.row];
    NSArray *list = [pfObject objectForKey:@"listPoints"];

    // Day
    UILabel *day = (UILabel *)[cell viewWithTag:1];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"yyyy' 'MMM' 'd' at 'HH':'mm"];
    [dateFormatter setDateFormat:@"d"];
    day.text = [dateFormatter stringFromDate:[pfObject createdAt]];
    
    // Month
    UILabel *month = (UILabel *)[cell viewWithTag:2];
    [dateFormatter setDateFormat:@"MMM"];
    month.text = [[dateFormatter stringFromDate:[pfObject createdAt]]uppercaseString];

    // Preview
    SYUnitPreview *preview = (SYUnitPreview *)[cell viewWithTag:3];
    [preview setPoints:list];
    [preview setAlpha:1.0];
    [preview setNeedsDisplay];
    //[preview setNeedsLayout];

    // Name
    UILabel *name = (UILabel *)[cell viewWithTag:4];
    name.text = [[pfObject objectForKey:@"name"]capitalizedString];

    // Number of points
    UILabel *points = (UILabel *)[cell viewWithTag:5];
    points.text = [NSString stringWithFormat:@"%u points", [list count]];
    
    return cell;
    
}// tableView:cellForRowAtIndexPath:


@end
