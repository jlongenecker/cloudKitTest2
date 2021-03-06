/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var masterViewController: MasterViewController!
  
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
    
   //uploadSampleData()
    
    let navBarController = self.window!.rootViewController as! UITabBarController
    let splitViewController = navBarController.viewControllers![0] as! UISplitViewController
    let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.endIndex-1] as! UINavigationController
    splitViewController.delegate = navigationController.topViewController as! DetailViewController
    
    let masterNav = splitViewController.viewControllers[0] as! UINavigationController
    masterViewController = masterNav.topViewController as! MasterViewController
    
    
    //Testing Push Notifications
    let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil)
    UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    UIApplication.sharedApplication().registerForRemoteNotifications()
    
    
//    application.registerForRemoteNotifications()

    return true
  }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken:NSData) {
        print("Registered for Post notifications with token: \(deviceToken)")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationswithError error: NSError) {
        print("Push subscription failed: \(error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let note = CKQueryNotification(fromRemoteNotificationDictionary: userInfo as! [String: NSObject])
        masterViewController.controller.handleNotification(note)
        
        if let pushInfo = userInfo as? [String:NSObject] {
            let notification = CKNotification(fromRemoteNotificationDictionary: pushInfo)
            print("Received Notification")
            let ac = UIAlertController(title: "New Updates", message: notification.alertBody, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            if let nc = window?.rootViewController as? UINavigationController {
                if let vc = nc.visibleViewController {
                    vc.presentViewController(ac, animated: true, completion: nil)
                }
            }
        }
    }

}

