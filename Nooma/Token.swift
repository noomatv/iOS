//
//  Token.swift
//  Nooma
//
//  Created by Jae Hoon Lee on 11/2/16.
//  Copyright © 2016 Nooma. All rights reserved.
//

import Foundation
import Lock

class Token {
    static let defaults = UserDefaults.standard
    
    static func checkIfTokenExists() -> Bool {
        if defaults.data(forKey: "token") != nil &&
            defaults.data(forKey: "profile") != nil {
            return true
        } else {
            return false
        }
    }
    
    static func handleExistingToken(success: @escaping () -> (), failure: @escaping () -> ()) {
        let client = A0Lock.shared().apiClient()
        let tokenData = defaults.data(forKey: "token")
        let token = NSKeyedUnarchiver.unarchiveObject(with: tokenData!) as! A0Token
        
        client.fetchUserProfile(withIdToken: token.idToken,
            success: { profile in
                // Our idToken is still valid...
                // We store the fetched user profile
                defaults.set(NSKeyedArchiver.archivedData(withRootObject: profile), forKey: "profile")
                
                // ✅ At this point, you can log the user into your app, by navigating to the corresponding screen
                
                success()
            },
            failure: { error in
                // ⚠️ idToken has expired or is no longer valid
                let defaults = UserDefaults.standard
                defaults.data(forKey: "profile")
                let tokenData = defaults.data(forKey: "token")
                let token = NSKeyedUnarchiver.unarchiveObject(with: tokenData!) as! A0Token
                
                if token.refreshToken == nil {
                    return
                }
                
                let client = A0Lock.shared().apiClient()
                client.fetchNewIdToken(withRefreshToken: token.refreshToken!, parameters: nil,
                    success: { newToken in
                        print("\n\n\n3. fetchNewIdToken success\n\n\n")
                    
                        // Just got a new idToken!
                        // Don't forget to store it...
                        let defaults = UserDefaults.standard
                        defaults.set(NSKeyedArchiver.archivedData(withRootObject: newToken), forKey: "token")
                        defaults.synchronize()
                        
                        // ✅ At this point, you can log the user into your app, by navigating to the corresponding screen
                        success()
                    },
                    failure: { error in
                        print("\n\n\n3. fetchNewIdToken error\n\n\n")
                                                            
                        // refreshToken is no longer valid (e.g. it has been revoked)
                        // Cleaning stored values since they are no longer valid
                        if let bundle = Bundle.main.bundleIdentifier {
                            UserDefaults.standard.removePersistentDomain(forName: bundle)
                        }
                        
                        // ⛔️ At this point, you should ask the user to enter his credentials again!
                        failure()
                    }
                )
            }
        )
    }
}
