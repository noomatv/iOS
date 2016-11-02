//
//  FirstViewController.swift
//  Nooma
//
//  Created by Jae Hoon Lee on 10/10/16.
//  Copyright © 2016 Nooma. All rights reserved.
//

import UIKit
import Lock

class BooksViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        getBooks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Token.handleExistingToken(success: getBooks, failure: tokenFailed)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tokenFailed() {
        print("Uh oh...")
        self.performSegue(withIdentifier: "unwindToLogin", sender: self)
    }

    func getBooks() {
        let defaults = UserDefaults.standard
        
        let tokenData = defaults.data(forKey: "token")
        let profileData = defaults.data(forKey: "profile")
        
        let token = NSKeyedUnarchiver.unarchiveObject(with: tokenData!) as! A0Token
        let profile = NSKeyedUnarchiver.unarchiveObject(with: profileData!) as! A0UserProfile
        
        Backend.makeRequest(
            url: Backend.httpUrl + "books",
            method: "POST",
            bodyData: "email=\(profile.email!)&classroom_id=\(Backend.classroomId)",
            userToken: token.idToken,
            callback: {(data: Data?, response: URLResponse?, error: Error?) in
                if let data = data {
                    print("data", data)
                    
                    if let response = Backend.parseJSONtoDictionary(inputData: data as NSData) {
                        print("response", response)
                        
                        if let errors = response["errors"] {
                            print("Errors \(errors)")
                        } else {
                            print("response", response)
                            if let currentUser = response["user"] {
                                CurrentUser = Backend.convertStringToDictionary(text: currentUser as! String)!
                                
                                print("CurrentUser \(CurrentUser as Any)")
                            }
                            
                            if let books = response["books"] {
                                print("BOOKS \(books)")
                            }
                        }
                    }
                }
            }
        )
    }
}

