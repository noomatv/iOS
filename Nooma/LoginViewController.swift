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

    }

    // MARK: - Private
    
    private func checkExistentSession() {
        let defaults = UserDefaults.standard
        print(defaults.data(forKey: "token"))
        
        if defaults.data(forKey: "token") != nil &&
            defaults.data(forKey: "profile") != nil {
            self.performSegue(withIdentifier: "UserLoggedIn", sender: nil)
        } else {
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
    }
}
