//
//  TCAppDelegate.m
//  TouchChart
//
//  Created by Adam Wulf on 3/11/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "TCAppDelegate.h"
#import "TCViewController.h"
#import "Parse/Parse.h"

@implementation TCAppDelegate

@synthesize viewController = _viewController;
@synthesize window;
// dealloc

+(void) forceStaticLink{
    [SYVectorView class];
    [SYPaintView class];
}

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Setup Parse
    [Parse setApplicationId:@"AnWkxCZfCOPVzPXD8tWNFVsL3Mie5qwOWueRS9xW"
                  clientKey:@"YPmL7zoIPvU5JAbiM3X080eRNljPjtYfhW62XVMM"];

    self.window = [[UIWindow alloc] initWithFrame:[[[UIScreen mainScreen] fixedCoordinateSpace] bounds]];
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        self.viewController = [[TCViewController alloc] initWithNibName:@"TCViewController_iPhone" bundle:nil];
    else
        self.viewController = [[TCViewController alloc] initWithNibName:@"TCViewController_iPad" bundle:nil];

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
    
}// application:didFinishLaunchingWithOptions:


- (void) applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}// applicationWillResignActive:


- (void) applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}// applicationDidEnterBackground:


- (void) applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}// applicationWillEnterForeground:


- (void) applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}// applicationDidBecomeActive:


- (void) applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}// applicationWillTerminate:

@end
