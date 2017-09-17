//
//  AppDelegate.swift
//  flicks
//
//  Created by Liqiang Ye on 9/12/17.
//  Copyright © 2017 Liqiang Ye. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        //add tab bar programmatically
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //set up the first view controller
        let nowPlayingNavigationController = storyboard.instantiateViewController(withIdentifier: "MoviesNavigationController") as! UINavigationController
        let nowPlayingViewController = nowPlayingNavigationController.topViewController as! MainViewController
        nowPlayingViewController.endpoint = "now_playing"
        nowPlayingViewController.tabBarItem.title = "Now Playing"
        let tabBarItemTextAttributes: [String: AnyObject] = [NSFontAttributeName:UIFont(name: "Helvetica", size: 14)!]
        nowPlayingViewController.tabBarItem.setTitleTextAttributes(tabBarItemTextAttributes, for: .normal)
        nowPlayingViewController.tabBarItem.image = UIImage(named: "now_playing")
        
        
        //set up the second view controller
        
        let topRatedNavigationController = storyboard.instantiateViewController(withIdentifier: "MoviesNavigationController") as! UINavigationController
        let topRatedViewController = topRatedNavigationController.topViewController as! MainViewController
        topRatedViewController.endpoint = "top_rated"
        topRatedViewController.tabBarItem.title = "Top Rated"
        topRatedViewController.tabBarItem.setTitleTextAttributes(tabBarItemTextAttributes, for: .normal)
        topRatedViewController.tabBarItem.image = UIImage(named: "top_rated")
        
        
        //set up the tab bar controller to have the tabs
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [nowPlayingNavigationController, topRatedNavigationController]
        
        
        //customizing tab bar
        tabBarController.tabBar.barStyle = .black
        tabBarController.tabBar.barTintColor = .black
        tabBarController.tabBar.alpha = 0.85
        tabBarController.tabBar.tintColor = .white
        
        
        //make the tab bar controller the root view controller
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        //customizing navigation bar
        let navigationBarAppearace = UINavigationBar.appearance()
        
        //navigationBar color settings
        navigationBarAppearace.barStyle = .blackOpaque
        navigationBarAppearace.barTintColor = .black
        navigationBarAppearace.tintColor = .white
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

