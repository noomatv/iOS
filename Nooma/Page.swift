//
//  Book.swift
//  Nooma
//
//  Created by Jae Hoon Lee on 11/2/16.
//  Copyright © 2016 Nooma. All rights reserved.
//

import Foundation

class Page {
    let uuid: String?
    let embed: String?
    let body: String?
    let book_dir: String?
    let chapter_dir: String?
    let page_dir: String?
    
    init(pageParams: [String: String]) {
        self.uuid = pageParams["uuid"]
        self.embed = pageParams["embed"]
        self.body = pageParams["body"]
        self.book_dir = pageParams["book_dir"]
        self.chapter_dir = pageParams["chapter_dir"]
        self.page_dir = pageParams["page_dir"]
    }
}
