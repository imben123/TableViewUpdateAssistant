//
//  AppDelegate.swift
//  TableViewAssistantDemo
//
//  Created by Ben Davis on 19/01/2019.
//  Copyright © 2019 Ben Davis Apps. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor.white
        let viewController = ViewController()
        window!.rootViewController = viewController
        self.window!.makeKeyAndVisible()
        return true
    }
}

