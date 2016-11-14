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
    var chapterTitles: [Page] = []
    var selectedChapter: Page?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Token.handleExistingToken(success: getChapters, failure: tokenFailed)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChapterCell")!
        
        cell.textLabel?.text = chapterTitles[indexPath.row].chapterDir()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chapterTitles.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedChapter = chapterTitles[indexPath.row]
        performSegue(withIdentifier: "ChaptersToPagesSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ChaptersToPagesSegue") {
            let destinationVC = segue.destination as! PagesViewController
            destinationVC.chapterPage = selectedChapter
        }
    }
    
    func getChapters() {
        let defaults = UserDefaults.standard
        
        let tokenData = defaults.data(forKey: "token")!
        let emailData = defaults.data(forKey: "email")!
        
        let token = NSKeyedUnarchiver.unarchiveObject(with: tokenData) as! String
        let email = NSKeyedUnarchiver.unarchiveObject(with: emailData) as! String

        let pageUuid: String = (bookPage?.uuid)!
        
        Backend.makeRequest(
            url: Backend.httpUrl + "chapters",
            method: "POST",
            bodyData: "page_uuid=\(pageUuid)&email=\(email)&classroom_id=\(Backend.classroomId)",
            userToken: token,
            callback: {(data: Data?, response: URLResponse?, error: Error?) in
                if let data = data {
                    let json = JSON(data: data)
                    CurrentUser = Backend.convertStringToDictionary(text: json["user"].stringValue)
                    
                    self.chapterTitles = []
                    
                    for chapter in json["chapters"].arrayValue {
                        let pageParams = [
                            "uuid": chapter["uuid"].stringValue,
                            "embed": chapter["embed"].stringValue,
                            "body": chapter["body"].stringValue,
                            "book_dir": chapter["book_dir"].stringValue,
                            "chapter_dir": chapter["chapter_dir"].stringValue,
                            "page_dir": chapter["page_dir"].stringValue
                        ]
                        
                        self.chapterTitles.append(Page(pageParams: pageParams))
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
