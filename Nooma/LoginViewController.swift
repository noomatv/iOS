//
//  LoginViewController.swift
//  Nooma
//
//  Created by Jae Hoon Lee on 10/10/16.
//  Copyright © 2016 Nooma. All rights reserved.
//

import UIKit
import Lock

class LoginViewController: UIViewController {
    
    var existingUser = false
    var idToken: String?
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let existingSession = checkExistingSession()
        
        if existingSession {
            performSegue(withIdentifier: "SignedInSegue", sender: nil)
        } else {
            promptLogin()
        }
    }
    
    private func promptLogin() {
        setTheme()
        let lock = A0Lock()
        let controller = lock.newEmailViewController()
        lock.presentEmailController(controller, from: self)
        
        controller?.onAuthenticationBlock = { (profile, token) in
            let defaults = UserDefaults.standard
            
            defaults.set(NSKeyedArchiver.archivedData(withRootObject: profile.email!), forKey: "email")
            defaults.set(NSKeyedArchiver.archivedData(withRootObject: token.idToken), forKey: "token")
            defaults.set(NSKeyedArchiver.archivedData(withRootObject: token.refreshToken!), forKey: "refreshToken")

            defaults.synchronize()
            
            self.idToken = token.idToken

            if let email = profile.email {
                Backend.makeRequest(url: "\(Backend.httpUrl)signin", method: "POST", bodyData: "email=\(email)&classroom_id=\(Backend.classroomId)", userToken: token.idToken, callback: self.afterRequest)
            }
        }
    }
    
    func tokenSuccess() {
        performSegue(withIdentifier: "SignedInSegue", sender: nil)

    }
    
    func tokenFailure() {
        promptLogin()
    }
    
    private func afterRequest(data: Data?, response: URLResponse?, error: Error?) {
        if let data = data {
            if let response = Backend.parseJSONtoDictionary(inputData: data as NSData) {
                if let errors = response["errors"] {
                    print("Errors \(errors)")
                } else {
                    self.dismiss(animated: false, completion: nil)
                    
                    if response["existing_user"] != nil || response["new_user"] != nil {
                        existingUser = true
                    }

                    if existingUser && idToken != nil {
                        Token.handleExistingToken(success: tokenSuccess, failure: tokenFailure)
                    }
                }
            }
        }
    }
    
    private func checkExistingSession() -> Bool {
        let defaults = UserDefaults.standard
        
        if defaults.data(forKey: "token") != nil &&
            defaults.data(forKey: "refreshToken") != nil &&
            defaults.data(forKey: "email") != nil {
            return true
        } else {
            return false
        }
    }
    
    private func setTheme() {
        let theme = A0Theme()
        theme.registerImage(withName: "noomalogo", bundle: Bundle.main, forKey: A0ThemeIconImageName)
        theme.register(UIColor(red:0.255, green:0.816, blue:0.478, alpha:1.00), forKey: A0ThemePrimaryButtonNormalColor)
        theme.register(UIColor(red:0.455, green:1.000, blue:0.678, alpha:1.00), forKey: A0ThemePrimaryButtonHighlightedColor)
        theme.register(.white, forKey: A0ThemePrimaryButtonTextColor)
        theme.statusBarStyle = .lightContent
        theme.register(.white, forKey: A0ThemeIconBackgroundColor)
        
        A0Theme.sharedInstance().register(theme)
    }
}
