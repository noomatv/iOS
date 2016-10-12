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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        tableView?.register(MessageTableViewCell.self, forCellReuseIdentifier: "MessageTableViewCell")
        tableView?.rowHeight = UITableViewAutomaticDimension //needed for autolayout
        tableView?.estimatedRowHeight = 50.0 //needed for autolayout
        isInverted = true
        
        Backend.get(path: "messages/1540", callback: afterRequest)
        
        let socket = SocketIOClient(socketURL: URL(string: "https://noomatv-node.herokuapp.com")!, config: [.log(true), .forcePolling(true)])
        
        socket.on("connect") {data, ack in
            print("\n\n\n\n\n\n")

            print("socket connected")
            
            print("\n\n\n\n\n\n")
        }
        
        socket.on("currentAmount") {data, ack in
            if let cur = data[0] as? Double {
                socket.emitWithAck("canUpdate", cur)(0) {data in
                    socket.emit("update", ["amount": cur + 2.50])
                }
                
                ack.with("Got your currentAmount", "dude")
            }
        }
        
        socket.connect()


    }
    
    func afterRequest(response: NSArray?) {
        if let arrOfMessages = response {
            for message in arrOfMessages.reversed() {
                messages.append(message as! Message)
            }
        }
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
