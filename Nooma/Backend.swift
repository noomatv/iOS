//
//  Backend.swift
//  Nooma
//
//  Created by Jae Hoon Lee on 10/11/16.
//  Copyright © 2016 Nooma. All rights reserved.
//

import Foundation

class Backend {
    static var url = "https://noomatv-node.herokuapp.com/"
    
    static func get(path: String, callback:(NSArray?) -> Void) {
        if let urlToReq = NSURL(string: url + path) {
            if let data = NSData(contentsOf: urlToReq as URL) {
                return callback(parseJSONtoArray(inputData: data) as NSArray?)
            } else {
                return callback(nil)
            }
        } else {
            return callback(nil)
        }
    }
    
    static func post(path: String, bodyData: String, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        if let urlToReq = NSURL(string: url + path) {
            let request = NSMutableURLRequest(url: urlToReq as URL)
            request.httpMethod = "POST"
            request.httpBody = bodyData.data(using: String.Encoding.utf8)
            URLSession.shared.dataTask(with: request as URLRequest, completionHandler: callback).resume()
        }
    }
    
    static func delete(path: String, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        if let urlToReq = NSURL(string: url + path) {
            let request = NSMutableURLRequest(url: urlToReq as URL)
            request.httpMethod = "DELETE"
            URLSession.shared.dataTask(with: request as URLRequest, completionHandler: callback).resume()
        }
    }
    
    static func parseJSONtoDictionary(inputData: NSData) -> NSDictionary? {
        do {
            let arrOfObjects = try JSONSerialization.jsonObject(with: inputData as Data, options: JSONSerialization.ReadingOptions.mutableContainers)
            return arrOfObjects as? NSDictionary
        } catch {
            return nil
        }
    }
    
    static func parseJSONtoArray(inputData: NSData) -> [Message]? {
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
