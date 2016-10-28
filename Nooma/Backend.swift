//
//  Backend.swift
//  Nooma
//
//  Created by Jae Hoon Lee on 10/11/16.
//  Copyright © 2016 Nooma. All rights reserved.
//

import Foundation
import Lock

class Backend {
    static var socketUrl = "http://localhost:4567/"
    static var httpUrl = "http://localhost:3000/api/v1/"
    static var classroomId = "1"
    
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
    
    static func parseJSONtoDictionary(inputData: NSData) -> NSDictionary? {
        do {
            let foundationObj = try JSONSerialization.jsonObject(with: inputData as Data, options: JSONSerialization.ReadingOptions.mutableContainers)
            return foundationObj as? NSDictionary
        } catch {
            return nil
        }
    }
    
    static func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    static func setCurrentUser() {
        let defaults = UserDefaults.standard
        
        let tokenData = defaults.data(forKey: "token")
        let profileData = defaults.data(forKey: "profile")
        
        let token = NSKeyedUnarchiver.unarchiveObject(with: tokenData!) as! A0Token
        let profile = NSKeyedUnarchiver.unarchiveObject(with: profileData!) as! A0UserProfile
        
        print("\n\n\n")
        print("\n\n\n")
        print("OMG")
        print("token \(token)")
        print("profile \(profile)")
        print("OMG")
        print("\n\n\n")
        print("\n\n\n")
        

        if let email = profile.email {

            Backend.makeRequest(
                url: Backend.httpUrl + "books",
                method: "POST",
                bodyData: "email=\(email)&auth_id=\(profile.userId)&classroom_id=\(Backend.classroomId)",
                userToken: token.idToken,
                callback: {(data: Data?, response: URLResponse?, error: Error?) in
                    if let data = data {
                        print("data", data)
                        
                        if let response = Backend.parseJSONtoDictionary(inputData: data as NSData) {
                            print("response", response)
                            
                            if let errors = response["errors"] {
                                print("Errors \(errors)")
                            } else {
                                print("response", response)
                                if let currentUser = response["existing_user"] {
                                    CurrentUser = Backend.convertStringToDictionary(text: currentUser as! String)!
                                    
                                    print("HELLO")
                                    print(CurrentUser)
                                }
                            }
                        }
                    }
                }
            )
        }
        
    }
}
