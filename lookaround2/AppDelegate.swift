//
//  AppDelegate.swift
//  lookaround2
//
//  Created by Angela Yu on 10/21/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FirebaseCore
import HDAugmentedReality

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       
        FirebaseApp.configure()
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)        

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let fStoryboard = UIStoryboard(name: "Filter", bundle: nil)
        
        let hamburgerViewController = storyboard.instantiateViewController(withIdentifier: "HamburgerViewController") as! HamburgerViewController
        
        let filterViewController = fStoryboard.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
        
        let augmentedNavController = storyboard.instantiateViewController(withIdentifier: "AugmentedNavigationController") as! UINavigationController
        
        guard let augmentedVC = augmentedNavController.childViewControllers[0] as? AugmentedViewController else {
            print("downcast of augmentedVC failed")
            return true
        }
        
        hamburgerViewController.filterViewController = filterViewController
        hamburgerViewController.contentViewController = augmentedNavController
        filterViewController.delegate = augmentedVC
        augmentedVC.delegate = hamburgerViewController
        augmentedVC.filterVC = filterViewController
        augmentedVC.uiOptions.closeButtonEnabled = false
        augmentedVC.dataSource = augmentedVC
        augmentedVC.presenter.presenterTransform = ARPresenterStackTransform()

        
        /* let dStoryboard = UIStoryboard(name: "Detail", bundle: nil)
        let detailNavVC = dStoryboard.instantiateViewController(withIdentifier: "PlaceDetailNavVC") as! UINavigationController
        let detailVC = detailNavVC.childViewControllers[0] as! PlaceDetailViewController
        hamburgerViewController.detailNavController = detailNavVC
        hamburgerViewController.detailViewController = detailVC */
        
        window?.rootViewController = hamburgerViewController
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = SDKApplicationDelegate.shared.application(app, open: url, options: options)
        
        return handled
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

