//
//  LandingPageViewController.swift
//  TestCommunitySwift
//
//  Created by KK Ramamoorthy on 8/16/17.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import UIKit
import WebKit
import SafariServices
import SalesforceSDKCore

class LandingPageViewController: UIViewController, SFSafariViewControllerDelegate, WKUIDelegate, WKNavigationDelegate {
    @IBOutlet var urlNavigationItem: UINavigationItem!
    
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!
    @IBOutlet var reloadButton: UIBarButtonItem!
    
    var webView: WKWebView!
    var accessToken:String = (SFUserAccountManager.sharedInstance().currentUser?.credentials.accessToken)!
    var communityURL:String = (SFUserAccountManager.sharedInstance().currentUser?.credentials.communityUrl?.absoluteString)!
    var instanceURL:String = (SFUserAccountManager.sharedInstance().currentUser?.credentials.instanceUrl?.absoluteString)!
    var communityId:String = (SFUserAccountManager.sharedInstance().currentUser?.credentials.communityId)!
    var orgId:String = (SFUserAccountManager.sharedInstance().currentUser?.credentials.organizationId)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let communityURLWithoutProtocol = communityURL.replacingOccurrences(of: "https://", with: "")
        let communityURLArray = communityURLWithoutProtocol.components(separatedBy: "/")
        var retURL:String = ""
        for(index,element) in communityURLArray.enumerated(){
            if index > 0{
                retURL = "\(retURL)/\(element)"
            }
        }
        retURL = "\(retURL)/s"
        
        let urlString = "\(communityURL)/secur/frontdoor.jsp?sid=\(accessToken)&retURL=\(retURL)"
        let url = URL(string: urlString)
        
        /*
        //Safari View Controller
        let webVC = SFSafariViewController(url: url!)
        webVC.delegate = self
        self.present(webVC, animated: true, completion: nil)
        */
        
        //WK Webview
        webView = WKWebView()
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: -44)
        let width = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        
        let request = URLRequest(url: url!)
        webView.load(request)
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = self
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        if(keyPath == "loading"){
            backButton.isEnabled = webView.canGoBack
            forwardButton.isEnabled = webView.canGoForward
        }
 
    }
    
    
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        webView.goBack()
    }
    
 
    @IBAction func forward(_ sender: UIBarButtonItem){
        webView.goForward()
    }
    
    
    @IBAction func reload(_ sender: UIBarButtonItem) {
        
        let request = URLRequest(url: webView.url!)
        webView.load(request)
    }
    
    
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        
        //Open _target=blank in the same frame
        if navigationAction.targetFrame == nil{
            webView.load(navigationAction.request)
        }
 
 
        
        /*
        //Open _target=blank in Safari
        if navigationAction.targetFrame == nil{
            let url:URL = navigationAction.request.url!
            let urlDesc:String = url.description.lowercased()
            
            if urlDesc.range(of: "http://") != nil || urlDesc.range(of: "https://") != nil || urlDesc.range(of: "mailto://") != nil || urlDesc.range(of: "tel://") != nil {
                print("***URL Desc is \(urlDesc)")
                UIApplication.shared.openURL(url)
            }
            
        }
        */

        
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
