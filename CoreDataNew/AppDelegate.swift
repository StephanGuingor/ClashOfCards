//
//  AppDelegate.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/11/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
var window: UIWindow?
    var mpcHandler:MPCHandler = MPCHandler()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle
    func applicationWillTerminate(_ application: UIApplication) {
        do{
        try PersistanceService.context.save()
        }catch{
            print(error.localizedDescription)
        }
        }
   
}

