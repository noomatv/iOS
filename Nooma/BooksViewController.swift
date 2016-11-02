//
//  FirstViewController.swift
//  Nooma
//
//  Created by Jae Hoon Lee on 10/10/16.
//  Copyright © 2016 Nooma. All rights reserved.
//

import UIKit
import Lock
import SwiftyJSON

class BooksViewController: UITableViewController {
    
    var bookTitles: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Token.handleExistingToken(success: getBooks, failure: tokenFailed)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell")!
        
        cell.textLabel?.text = bookTitles[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookTitles.count
    }
    
    func tokenFailed() {
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
                    let json = JSON(data: data)
                    CurrentUser = Backend.convertStringToDictionary(text: json["user"].stringValue)
                    
                    for book in json["books"].arrayValue {
                        self.bookTitles.append(book["book_dir"].stringValue)
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        )
    }
}

