//
//  AppDelegate.m
//  OneKeyCall
//
//  Created by swhl on 13-7-3.
//  Copyright (c) 2013年 sprite. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    self.viewController = [[[ViewController alloc] initWithNibName:nil bundle:nil] autorelease];

    
//    self.window.bounds = CGRectMake(0, -64, self.window.frame.size.width, self.window.frame.size.height);
//    self.window.frame = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height-20);
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:self.viewController];

    [self.window makeKeyAndVisible];
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSLog(@"open url start");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *urlString = [url absoluteString];
        if([urlString rangeOfString:@"onekeycall://"].location != NSNotFound ){
            urlString = [urlString stringByReplacingOccurrencesOfString:@"onekeycall" withString:@"tel"];
            [application openURL:[NSURL URLWithString:urlString]];
        }
    });
    NSLog(@"open url end");
    return NO;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
