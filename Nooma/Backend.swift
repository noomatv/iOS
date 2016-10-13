//
//  Backend.swift
//  Nooma
//
//  Created by Jae Hoon Lee on 10/11/16.
//  Copyright © 2016 Nooma. All rights reserved.
//

import Foundation

class Backend {
    static var socketUrl = "http://localhost:4567/"
    
    static func makeRequest(url: String, method: String, bodyData: String?, userToken: String?, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        if let urlToReq = NSURL(string: url) {
            let request = NSMutableURLRequest(url: urlToReq as URL)
            request.httpMethod = method
            
            if let body = bodyData {
                request.httpBody = body.data(using: String.Encoding.utf8)
            }
            
            if let header = userToken {
                request.setValue("Bearer \(header)", forHTTPHeaderField: "Authorization")
            }
            
            URLSession.shared.dataTask(with: request as URLRequest, completionHandler: callback).resume()
        }
        
    }
    
    static func getMessages(path: String, callback:(NSArray?) -> Void) {
        if let urlToReq = NSURL(string: socketUrl + path) {
            if let data = NSData(contentsOf: urlToReq as URL) {
                return callback(convertDataToMessages(inputData: data) as NSArray?)
            } else {
                return callback(nil)
            }
        } else {
            return callback(nil)
        }
    }
    
    static func convertDataToMessages(inputData: NSData) -> [Message]? {
        var messages = [Message]()
        
        do {
            let json = try JSONSerialization.jsonObject(with: inputData as Data, options: .allowFragments)
            
            for message in (json as? [[String: AnyObject]])! {
                messages.append(Message(name: message["username"] as! String, body: message["message"] as! String))
            }
            
            return messages

        } catch {
            print("error serializing JSON: \(error)")
            return nil
        }
    }
}
