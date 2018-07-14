//
//  AppDelegate.swift
//  Recognizer
//
//  Created by Chun Kong on 2018/6/12.
//  Copyright © 2018 chenzhengang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        setUpWindowAndRootView()
        // Override point for customization after application launch.
        
//        let viewBounds:CGRect = UIScreen.main.bounds
//
//        self.window?.backgroundColor = #colorLiteral(red: 0.7280698614, green: 0.9076298398, blue: 1, alpha: 1)
//
//        //下面这句一定得加上，否则不会有任何动画
//        self.window?.makeKeyAndVisible()
//        let imageView1 = UIImageView(image:UIImage(named:"相机"))
//        imageView1.frame = CGRect(x:viewBounds.width/2-50,y:0,width:100,height:80);
//        self.window?.addSubview(imageView1)
//
//        let imageView2 = UIImageView(image:UIImage(named:"放大镜"))
//        imageView2.frame = CGRect(x:viewBounds.width/2-50,y:viewBounds.height,width:100,height:100);
//        self.window?.addSubview(imageView2)
//
//
//        UIView.animate(withDuration: 0.8, animations: {
//            self.window?.backgroundColor = UIColor.white
//            imageView1.frame = CGRect(x:viewBounds.width/2-50,y:viewBounds.height/2,width:100,height:80)
//            imageView2.frame = CGRect(x:viewBounds.width/2-50,y:viewBounds.height/2,width:100,height:100);
//        }, completion: { _ in
//            imageView1.removeFromSuperview()
//            imageView2.removeFromSuperview()
//        })
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

extension AppDelegate {
    
    func setUpWindowAndRootView() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.backgroundColor = UIColor.white
        window!.makeKeyAndVisible()
        
        let adVC = AdViewController()
        adVC.completion = {
            //let vc = MainViewController()
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            vc.adView = adVC.view
            self.window!.rootViewController = vc
        }
        window!.rootViewController = adVC
    }
}

