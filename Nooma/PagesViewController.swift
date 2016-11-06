//
//  PagesViewController.swift
//  Nooma
//
//  Created by Jae Hoon Lee on 11/3/16.
//  Copyright © 2016 Nooma. All rights reserved.
//

import Foundation
import Lock
import SwiftyJSON

class PagesViewController: UITableViewController {
    var chapterPage: Page?
    var pageTitles: [Page] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Token.handleExistingToken(success: getPages, failure: tokenFailed)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PageCell")!
        
        cell.textLabel?.text = pageTitles[indexPath.row].page_dir
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pageTitles.count
    }
    
    func getPages() {
        let defaults = UserDefaults.standard
  
        let tokenData = defaults.data(forKey: "token")!
        let emailData = defaults.data(forKey: "email")!
        
        let token = NSKeyedUnarchiver.unarchiveObject(with: tokenData) as! String
        let email = NSKeyedUnarchiver.unarchiveObject(with: emailData) as! String

        let pageUuid: String = (chapterPage?.uuid)!
        
        Backend.makeRequest(
            url: Backend.httpUrl + "pages",
            method: "POST",
            bodyData: "page_uuid=\(pageUuid)&email=\(email)&classroom_id=\(Backend.classroomId)",
            userToken: token,
            callback: {(data: Data?, response: URLResponse?, error: Error?) in
                if let data = data {
                    let json = JSON(data: data)
                    CurrentUser = Backend.convertStringToDictionary(text: json["user"].stringValue)
                    
                    self.pageTitles = []
                    
                    print(json["pages"])
                    
                    for page in json["pages"].arrayValue {
                        let pageParams = [
                            "uuid": page["uuid"].stringValue,
                            "embed": page["embed"].stringValue,
                            "body": page["body"].stringValue,
                            "book_dir": page["book_dir"].stringValue,
                            "chapter_dir": page["chapter_dir"].stringValue,
                            "page_dir": page["page_dir"].stringValue
                        ]
                        
                        self.pageTitles.append(Page(pageParams: pageParams))
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
