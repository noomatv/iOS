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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkExistentSession()

        let theme = A0Theme()
        theme.registerImage(withName: "noomalogo", bundle: Bundle.main, forKey: A0ThemeIconImageName)
        theme.register(UIColor(red:0.255, green:0.816, blue:0.478, alpha:1.00), forKey: A0ThemePrimaryButtonNormalColor)
        theme.register(UIColor(red:0.455, green:1.000, blue:0.678, alpha:1.00), forKey: A0ThemePrimaryButtonHighlightedColor)
        theme.register(.white, forKey: A0ThemePrimaryButtonTextColor)
        theme.statusBarStyle = .lightContent
        theme.register(.white, forKey: A0ThemeIconBackgroundColor)


        A0Theme.sharedInstance().register(theme)
      
        let lock = A0Lock()
        let controller = lock.newEmailViewController()
        lock.presentEmailController(controller, from: self)
        
        controller?.onAuthenticationBlock = { (profile, token) in
            
            let defaults = UserDefaults.standard
            
            defaults.set(NSKeyedArchiver.archivedData(withRootObject: profile), forKey: "profile")
            defaults.set(NSKeyedArchiver.archivedData(withRootObject: token), forKey: "token")
            
            defaults.synchronize()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func checkExistentSession() {
        let defaults = UserDefaults.standard
        
        if defaults.data(forKey: "token") != nil &&
            defaults.data(forKey: "profile") != nil {
            
            self.performSegue(withIdentifier: "SignedInSegue", sender: nil)
        } else {
            let lock = A0Lock()
            let controller = lock.newEmailViewController()
            lock.presentEmailController(controller, from: self)
            
            controller?.onAuthenticationBlock = { (profile, token) in
                
                let defaults = UserDefaults.standard
                
                defaults.set(NSKeyedArchiver.archivedData(withRootObject: profile), forKey: "profile")
                defaults.set(NSKeyedArchiver.archivedData(withRootObject: token), forKey: "token")
                
                defaults.synchronize()
                
                self.dismiss(animated: false, completion: nil)
                self.performSegue(withIdentifier: "SignedInSegue", sender: nil)
            }
        }
    }
}
