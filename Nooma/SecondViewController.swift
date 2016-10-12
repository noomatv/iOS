//
//  SecondViewController.swift
//  Nooma
//
//  Created by Jae Hoon Lee on 10/10/16.
//  Copyright © 2016 Nooma. All rights reserved.
//

import UIKit
import SlackTextViewController

class SecondViewController: SLKTextViewController {
    
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        tableView?.register(MessageTableViewCell.self, forCellReuseIdentifier: "MessageTableViewCell")
        tableView?.rowHeight = UITableViewAutomaticDimension //needed for autolayout
        tableView?.estimatedRowHeight = 50.0 //needed for autolayout
        isInverted = true
        
        messages.append(Message(name: "Kyrie", body: "This is not a high school kid coming to you — 'Kobe, Kobe, oh my God!' This is me, coming to talk to you, one-on-one."))
        messages.append(Message(name: "Kobe", body: "I know your dad don't think you can beat me one-on-one"))
        messages.append(Message(name: "Kobe", body: "I know that. I know that."))
        messages.append(Message(name: "Kobe", body: "Get your dad on the phone right now. Be like, 'Pops, I'm trying to bet Kob' 50 grand I can beat him one-on-one.' He'll be like, 'Son, are you crazy? Are you crazy?'"))
        messages.append(Message(name: "Kyrie", body: "He thinks he's talking to a high school kid!"))
        messages.append(Message(name: "Kobe", body: "You just came out of high school, kid!"))
        messages.append(Message(name: "Kyrie", body: "I just came out of college!"))
        messages.append(Message(name: "Kyrie", body: "You came out of high school!"))
        messages.append(Message(name: "Kobe", body: "You played two games. You are a high school kid."))


        self.tableView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
        
        let message = messages[indexPath.row]
        
        cell.nameLabel.text = message.name
        cell.bodyLabel.text = message.body
        
        cell.transform = (self.tableView?.transform)!
        
        print("cell.transform \(cell.transform)")
        return cell
    }
}
