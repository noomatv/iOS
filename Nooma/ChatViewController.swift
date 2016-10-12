//
//  SecondViewController.swift
//  Nooma
//
//  Created by Jae Hoon Lee on 10/10/16.
//  Copyright © 2016 Nooma. All rights reserved.
//

import UIKit
import SlackTextViewController
import SocketIO

class ChatViewController: SLKTextViewController {
    
    var messages = [Message]()
    var socket: SocketIOClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        tableView?.register(MessageTableViewCell.self, forCellReuseIdentifier: "MessageTableViewCell")
        tableView?.rowHeight = UITableViewAutomaticDimension //needed for autolayout
        tableView?.estimatedRowHeight = 50.0 //needed for autolayout
        isInverted = true
        
        Backend.get(path: "messages/\(CurrentUser["classroom_id"] as! Int)", callback: afterRequest)
        socket = SocketIOClient(socketURL: URL(string: Backend.url)!, config: [.log(true), .forcePolling(true)])
        
        socket?.on("connect") {data, ack in
            print("\n\n\n\n\n\n")

            print("socket connected")
            
            print("\n\n\n\n\n\n")
        }
        
        socket?.on("chatSent") {data, ack in
            print("\n\n\n\n\n\ndata!")
            
            print(data)
        
            
            print("\n\n\n\n\n\nenddata!")
        }
    
        
        socket?.connect()
    }



    func afterRequest(response: NSArray?) {
        if let arrOfMessages = response {
            for message in arrOfMessages.reversed() {
                messages.append(message as! Message)
            }
        }
    }
    
    override func didPressRightButton(_ sender: Any?) {
        self.textView.refreshFirstResponder()
        
        if let message = self.textView.text {
            socket?.emit("chat", [
                "incoming": [
                    "user": CurrentUser,
                    "message": message
                ]
            ])
        }
        
        self.textView.text = ""
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
