/*
 Copyright (c) 2015-present, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation
import UIKit
import SalesforceSDKCore

// Fill these in when creating a new Connected Application on Force.com
let RemoteAccessConsumerKey = "3MVG9Iu66FKeHhINkB1l7xt7kR8czFcCTUhgoA8Ol2Ltf1eYHOU4SqQRSEitYFDUpqRWcoQ2.dBv_a1Dyu5xa";
let OAuthRedirectURI        = "testsfdc:///mobilesdk/detect/oauth/done";


class AppDelegate : UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    override
    init()
    {
        super.init()
        SalesforceSDKManager.shared().connectedAppId = RemoteAccessConsumerKey
        SalesforceSDKManager.shared().connectedAppCallbackUri = OAuthRedirectURI
        SalesforceSDKManager.shared().authScopes = ["web", "api"];
        
        //Uncomment the following line inorder to enable/force the use of advanced authentication flow.
        // SFAuthenticationManager.shared().advancedAuthConfiguration = SFOAuthAdvancedAuthConfiguration.require;
        // OR
        // To  retrieve advanced auth configuration from the org, to determine whether to initiate advanced authentication.
        // SFAuthenticationManager.shared().advancedAuthConfiguration = SFOAuthAdvancedAuthConfiguration.allow;
        
        // NOTE: If advanced authentication is configured or forced,  it will launch Safari to handle authentication
        // instead of a webview. You must implement application:openURL:options  to handle the callback.
        
        SalesforceSDKManager.shared().postLaunchAction = {
            [unowned self] (launchActionList: SFSDKLaunchAction) in
            let launchActionString = SalesforceSDKManager.launchActionsStringRepresentation(launchActionList)
            SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.info, message:"Post-launch: launch actions taken: \(launchActionString)");
            self.setupRootViewController();
        }
        SalesforceSDKManager.shared().launchErrorAction = {
            [unowned self] (error: Error, launchActionList: SFSDKLaunchAction) in
            SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.error, message:"Error during SDK launch: \(error.localizedDescription)")
            self.initializeAppViewState()
            SalesforceSDKManager.shared().launch()
        }
        SalesforceSDKManager.shared().postLogoutAction = {
            [unowned self] in
            self.handleSdkManagerLogout()
        }
        SalesforceSDKManager.shared().switchUserAction = {
            [unowned self] (fromUser: SFUserAccount?, toUser: SFUserAccount?) -> () in
            self.handleUserSwitch(fromUser, toUser: toUser)
        }
    }
    
    // MARK: - App delegate lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.initializeAppViewState();
        
        //
        // If you wish to register for push notifications, uncomment the line below.  Note that,
        // if you want to receive push notifications from Salesforce, you will also need to
        // implement the application:didRegisterForRemoteNotificationsWithDeviceToken: method (below).
        //
        // SFPushNotificationManager.sharedInstance().registerForRemoteNotifications()
        
        //
        //Uncomment the code below to see how you can customize the color, textcolor, font and fontsize of the navigation bar
        //
        // let loginViewController = SFLoginViewController.sharedInstance();
        //Set showNavBar to NO if you want to hide the top bar
        // loginViewController.showNavbar = true;
        //Set showSettingsIcon to NO if you want to hide the settings icon on the nav bar
        // loginViewController.showSettingsIcon = true;
        // Set primary color to different color to style the navigation header
        // loginViewController.navBarColor = UIColor(red: 0.051, green: 0.765, blue: 0.733, alpha: 1.0);
        // loginViewController.navBarFont = UIFont (name: "Helvetica Neue", size: 16);
        // loginViewController.navBarTextColor = UIColor.black;
        //
        SalesforceSDKManager.shared().launch()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        //
        // Uncomment the code below to register your device token with the push notification manager
        //
        //
        // SFPushNotificationManager.sharedInstance().didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
        // if (SFUserAccountManager.sharedInstance().currentUser?.credentials.accessToken != nil)
        // {
        //    SFPushNotificationManager.sharedInstance().registerForSalesforceNotifications()
        // }
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error )
    {
        // Respond to any push notification registration errors here.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Uncomment the following line, if Authentication was attempted using handle advanced OAuth flow.
        // For Advanced Auth functionality to work, edit your apps plist files and add the URL scheme that you have
        // chosen for your app. The scheme should be the same as used in  the oauthRedirectURI settings of your Connected App.
        // You should also set the  delegate(SFAuthenticationManagerDelegate) for SFAuthenticationManager to be notified
        // of success & failures. Inorder to be notfied of user's selected action on displayed alerts implement
        // authManagerDidProceedWithBrowserFlow: & authManagerDidCancelBrowserFlow:
        
        // return  SFAuthenticationManager.shared().handleAdvancedAuthenticationResponse(url)
        return false;
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

    
    // MARK: - Private methods
    func initializeAppViewState()
    {
        if (!Thread.isMainThread) {
            DispatchQueue.main.async {
                self.initializeAppViewState()
            }
            return
        }
        
        self.window!.rootViewController = InitialViewController(nibName: nil, bundle: nil)
        self.window!.makeKeyAndVisible()
    }
    
    func setupRootViewController()
    {
        
        
        let storyboard: UIStoryboard = UIStoryboard(name: "LandingPage", bundle: Bundle.main)
        let landingPageController = storyboard.instantiateViewController(withIdentifier: "LandingPage")
        self.window!.rootViewController = landingPageController
        
        //let rootVC = RootViewController(nibName: nil, bundle: nil)
        //let navVC = UINavigationController(rootViewController: rootVC)
        //self.window!.rootViewController = navVC
    }
    
    func resetViewState(_ postResetBlock: @escaping () -> ())
    {
        if let rootViewController = self.window!.rootViewController {
            if let _ = rootViewController.presentedViewController {
                rootViewController.dismiss(animated: false, completion: postResetBlock)
                return
            }
        }
        
        postResetBlock()
    }
    
    func handleSdkManagerLogout()
    {
        SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.debug, message: "SFAuthenticationManager logged out.  Resetting app.")
        self.resetViewState { () -> () in
            self.initializeAppViewState()
            
            // Multi-user pattern:
            // - If there are two or more existing accounts after logout, let the user choose the account
            //   to switch to.
            // - If there is one existing account, automatically switch to that account.
            // - If there are no further authenticated accounts, present the login screen.
            //
            // Alternatively, you could just go straight to re-initializing your app state, if you know
            // your app does not support multiple accounts.  The logic below will work either way.
            
            var numberOfAccounts : Int;
            let allAccounts = SFUserAccountManager.sharedInstance().allUserAccounts()
            numberOfAccounts = (allAccounts!.count);
            
            if numberOfAccounts > 1 {
                let userSwitchVc = SFDefaultUserManagementViewController(completionBlock: {
                    action in
                    self.window!.rootViewController!.dismiss(animated:true, completion: nil)
                })
                if let actualRootViewController = self.window!.rootViewController {
                    actualRootViewController.present(userSwitchVc!, animated: true, completion: nil)
                }
            } else {
                if (numberOfAccounts == 1) {
                    SFUserAccountManager.sharedInstance().currentUser = allAccounts![0]
                }
                SalesforceSDKManager.shared().launch()
            }
        }
    }
    
    func handleUserSwitch(_ fromUser: SFUserAccount?, toUser: SFUserAccount?)
    {
        let fromUserName = (fromUser != nil) ? fromUser?.userName : "<none>"
        let toUserName = (toUser != nil) ? toUser?.userName : "<none>"
        SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.debug, message:"SFUserAccountManager changed from user \(String(describing: fromUserName)) to \(String(describing: toUserName)).  Resetting app.")
        self.resetViewState { () -> () in
            self.initializeAppViewState()
            SalesforceSDKManager.shared().launch()
        }
    }
}
