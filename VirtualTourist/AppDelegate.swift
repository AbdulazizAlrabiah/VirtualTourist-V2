//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by aziz on 08/06/2019.
//  Copyright © 2019 Aziz. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

     let dataController = DataController(modelName: "VirtualTourist")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        
        let mapViewController = navigationController.topViewController as! MapViewController
        
        mapViewController.dataController = dataController
        
        return true
    }
}

