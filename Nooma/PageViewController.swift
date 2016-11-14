//
//  PageViewController.swift
//  Nooma
//
//  Created by Jae Hoon Lee on 11/8/16.
//  Copyright © 2016 Nooma. All rights reserved.
//

import UIKit
import SwiftyJSON

class PageViewController: UIViewController, UIWebViewDelegate {
    var currentPage: Page?

    @IBOutlet weak var embedWebView: UIWebView!
    @IBOutlet weak var markdownWebView: UIWebView!
    
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    override func viewDidLoad() {
        embedWebView.delegate = self
        embedWebView.scrollView.isScrollEnabled = false
        embedWebView.allowsInlineMediaPlayback = true
        
        markdownWebView.delegate = self
        
        // Weird hack to prevent auto layouts getting overridden when coming back from full screen
        NotificationCenter.default.addObserver(self, selector: #selector(PageViewController.isFullScreen), name: NSNotification.Name.UIWindowDidBecomeVisible, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(PageViewController.backToNormal), name: NSNotification.Name.UIWindowDidBecomeHidden, object: self.view.window)
        
        Token.handleExistingToken(success: getPage, failure: tokenFailed)
    }
    
    func isFullScreen() {
        topMargin.constant = 8.3
    }
    
    func backToNormal() {
        topMargin.constant = 8
    }
    
    func tokenFailed() {
        print("Token failed")
    }
    
    func getPage() {
        let defaults = UserDefaults.standard
        
        let tokenData = defaults.data(forKey: "token")!
        let emailData = defaults.data(forKey: "email")!
        
        let token = NSKeyedUnarchiver.unarchiveObject(with: tokenData) as! String
        let email = NSKeyedUnarchiver.unarchiveObject(with: emailData) as! String
        let uuid = (currentPage?.uuid!)!
        
        Backend.makeRequest(
            url: Backend.httpUrl + "embeds",
            method: "POST",
            bodyData: "email=\(email)&uuid=\(uuid)&classroom_id=\(Backend.classroomId)",
            userToken: token,
            callback: {(data: Data?, response: URLResponse?, error: Error?) in
                if let data = data {
                    let json = JSON(data: data)
                    CurrentUser = Backend.convertStringToDictionary(text: json["user"].stringValue)
                    
                    print(json["body_partial"].stringValue)
                    
                    self.embedWebView.loadHTMLString(json["embed_partial"].stringValue, baseURL: nil)
                    
                    self.markdownWebView.loadHTMLString(json["body_partial"].stringValue, baseURL: nil)
                }
            }
        )
    }
}
