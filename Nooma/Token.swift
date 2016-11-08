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
            defaults.data(forKey: "refreshToken") != nil {
            return true
        } else {
            return false
        }
    }
    
    static func handleExistingToken(success: @escaping () -> (), failure: @escaping () -> ()) {
        let client = A0Lock.shared().apiClient()
        
        let tokenData = defaults.data(forKey: "token")!
        let refreshTokenData = defaults.data(forKey: "refreshToken")!
        
        let token = NSKeyedUnarchiver.unarchiveObject(with: tokenData) as! String
        let refreshToken = NSKeyedUnarchiver.unarchiveObject(with: refreshTokenData) as! String

        client.fetchUserProfile(withIdToken: token,
            success: { profile in
                // Our idToken is still valid...
                // We store the fetched user profile
                defaults.set(NSKeyedArchiver.archivedData(withRootObject: profile.email!), forKey: "email")
    
                // ✅ At this point, you can log the user into your app, by navigating to the corresponding screen
                success()
            },
            failure: { error in
                // ⚠️ idToken has expired or is no longer valid
                let client = A0Lock.shared().apiClient()
                client.fetchNewIdToken(withRefreshToken: refreshToken, parameters: nil,
                    success: { newToken in
                        // Just got a new idToken!
                        // Don't forget to store it...
                        let defaults = UserDefaults.standard
                        
                        defaults.set(NSKeyedArchiver.archivedData(withRootObject: newToken.idToken), forKey: "token")
                        defaults.set(NSKeyedArchiver.archivedData(withRootObject: refreshToken), forKey: "refreshToken")

                        defaults.synchronize()
                        // ✅ At this point, you can log the user into your app, by navigating to the corresponding screen
                        success()
                    },
                    failure: { error in
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
