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

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        socket = SocketIOClient(socketURL: URL(string: Backend.socketUrl)!, config: [.log(true), .forcePolling(true)])
        
        socket?.on("connect") {data, ack in
            self.socket?.emit("joinRoom", [
                "user": CurrentUser!
                ])
        }
        
        socket?.on("chatSent") {data, ack in
            let json = data[0] as! Dictionary<String, Any>
            let incoming = json["incoming"] as! Dictionary<String, Any>
            let user = incoming["user"] as! Dictionary<String, Any>
            
            let newMessage = Message(name: user["username"] as! String, body: incoming["message"] as! String)
            self.messages.insert(newMessage, at: 0)
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
        
        socket?.connect()
        
        Backend.getMessages(path: "messages/\(CurrentUser!["classroom_id"] as! Int)", callback: afterRequest)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        socket?.disconnect()
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
                    "user": CurrentUser!,
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
