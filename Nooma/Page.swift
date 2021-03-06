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
    
    func bookDir() -> String {
        return getDir(dir: book_dir!)
    }
    
    func chapterDir() -> String {
        return getDir(dir: chapter_dir!)
    }
    
    func pageDir() -> String {
        return getDir(dir: page_dir!)
    }
    
    func getDir(dir: String) -> String {
        var split = dir.components(separatedBy: "-")
        split.remove(at: 0)
        return split.joined(separator: "-").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
