//
//  Message.swift
//  Nooma
//
//  Created by Jae Hoon Lee on 10/11/16.
//  Copyright © 2016 Nooma. All rights reserved.
//

import Foundation

class Message {
    let name: String
    let body: String?
    
    init(name: String, body: String) {
        self.name = name
        self.body = body
    }
}
