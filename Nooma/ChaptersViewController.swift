//
//  ChaptersViewController.swift
//  Nooma
//
//  Created by Jae Hoon Lee on 11/2/16.
//  Copyright © 2016 Nooma. All rights reserved.
//

import Foundation
import Lock
import SwiftyJSON

class ChaptersViewController: UITableViewController {
    var bookPage: Page?
    var chapterTitles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Token.handleExistingToken(success: getChapters, failure: tokenFailed)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChapterCell")!
        
        cell.textLabel?.text = chapterTitles[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chapterTitles.count
    }
    
    func getChapters() {
        let defaults = UserDefaults.standard
        
        let tokenData = defaults.data(forKey: "token")
        let profileData = defaults.data(forKey: "profile")
        
        let token = NSKeyedUnarchiver.unarchiveObject(with: tokenData!) as! A0Token
        let profile = NSKeyedUnarchiver.unarchiveObject(with: profileData!) as! A0UserProfile
        let pageUuid: String = (bookPage?.uuid)!
        
        Backend.makeRequest(
            url: Backend.httpUrl + "chapters",
            method: "POST",
            bodyData: "page_uuid=\(pageUuid)&email=\(profile.email!)&classroom_id=\(Backend.classroomId)",
            userToken: token.idToken,
            callback: {(data: Data?, response: URLResponse?, error: Error?) in
                if let data = data {
                    let json = JSON(data: data)
                    CurrentUser = Backend.convertStringToDictionary(text: json["user"].stringValue)
                    
                    self.chapterTitles = []

                    for chapter in json["chapters"].arrayValue {
                        print(chapter)
                        self.chapterTitles.append(chapter.stringValue)
                    }

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        )
    }
    
    func tokenFailed() {
        performSegue(withIdentifier: "unwindToLogin", sender: self)
    }
}
