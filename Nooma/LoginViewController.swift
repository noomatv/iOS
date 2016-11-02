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
            
            defaults.set(NSKeyedArchiver.archivedData(withRootObject: profile), forKey: "profile")
            defaults.set(NSKeyedArchiver.archivedData(withRootObject: token), forKey: "token")
            defaults.synchronize()
            
            self.idToken = token.idToken

            if let email = profile.email {
                Backend.makeRequest(url: "\(Backend.httpUrl)signin", method: "POST", bodyData: "email=\(email)&classroom_id=\(Backend.classroomId)", userToken: token.idToken, callback: self.afterRequest)
            }
        }
    }
    
    private func afterRequest(data: Data?, response: URLResponse?, error: Error?) {
        if let data = data {
            if let response = Backend.parseJSONtoDictionary(inputData: data as NSData) {
                if let errors = response["errors"] {
                    print("Errors \(errors)")
                } else {
                    self.dismiss(animated: false, completion: nil)

                    if let _ = response["existing_user"] {
                        existingUser = true
                    } else if let _ = response["new_user"] {
                        self.performSegue(withIdentifier: "ChooseUsernameSegue", sender: nil)
                    }

                    if existingUser && idToken != nil {
                        // idToken exists
                        let client = A0Lock.shared().apiClient()
                        let defaults = UserDefaults.standard

                        client.fetchUserProfile(withIdToken: idToken!,
                            success: { profile in
                                // Our idToken is still valid...
                                // We store the fetched user profile
                                defaults.set(NSKeyedArchiver.archivedData(withRootObject: profile), forKey: "profile")

                                // ✅ At this point, you can log the user into your app, by navigating to the corresponding screen
                                self.performSegue(withIdentifier: "SignedInSegue", sender: nil)
                            },
                            failure: { error in
                                // ⚠️ idToken has expired or is no longer valid
                                let defaults = UserDefaults.standard
                                defaults.data(forKey: "profile")
                                let tokenData = defaults.data(forKey: "token")
                                let token = NSKeyedUnarchiver.unarchiveObject(with: tokenData!) as! A0Token
                                
                                if token.refreshToken == nil {
                                    return
                                }
                                
                                let client = A0Lock.shared().apiClient()
                                client.fetchNewIdToken(withRefreshToken: token.refreshToken!, parameters: nil,
                                    success: { newToken in
                                        print("\n\n\n3. fetchNewIdToken success\n\n\n")
                                    
                                        // Just got a new idToken!
                                        // Don't forget to store it...
                                        let defaults = UserDefaults.standard
                                        defaults.set(NSKeyedArchiver.archivedData(withRootObject: newToken), forKey: "token")
                                        defaults.synchronize()
                                        
                                        // ✅ At this point, you can log the user into your app, by navigating to the corresponding screen
                                        self.performSegue(withIdentifier: "SignedInSegue", sender: nil)
                                    },
                                    failure: { error in
                                        print("\n\n\n3. fetchNewIdToken error\n\n\n")
                                        
                                        // refreshToken is no longer valid (e.g. it has been revoked)
                                        // Cleaning stored values since they are no longer valid
                                        if let bundle = Bundle.main.bundleIdentifier {
                                            UserDefaults.standard.removePersistentDomain(forName: bundle)
                                        }
                                        
                                        // ⛔️ At this point, you should ask the user to enter his credentials again!
                                        self.promptLogin()
                                    }
                                )
                            }
                        )
                    }
                }
            }
        }
    }
    
    private func checkExistingSession() -> Bool {
        let defaults = UserDefaults.standard
        
        if defaults.data(forKey: "token") != nil &&
            defaults.data(forKey: "profile") != nil {
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
