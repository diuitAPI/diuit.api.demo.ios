//
//  AppDelegate.swift
//  Diuit API Demo
//
//  Created by David Lin on 11/30/15.
//  Copyright © 2015 Diuit. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import DUMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        DUMessaging.setAppId("test", appKey: "123")
        Fabric.with([Crashlytics.self])
        return true
    }

}

