//
//  FacebookManager.swift
//  FacebookManager
//
//  Created by Alexsander  on 6/10/16.
//  Copyright © 2016 Alexsander Khitev. All rights reserved.
//

import Foundation

class FacebookManager {
    
    // MARK: - delegate
    
    weak static var delegate: FacebookManagerDelegate?
    
    // MARK: - app functions
    
    // MARK: registration in app
    
    static func facebookDelegate(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    static func facebookActiveApp() {
        FBSDKAppEvents.activateApp()
    }
    
    // MARK: - auth functions
    
    private static func getDataLogin(success: (() -> ())?, fails: ((error: NSError?) -> ())?) {
        let manager = FBSDKLoginManager()
        manager.loginBehavior = .Native
        let permission = ["public_profile", "email"]
        manager.logInWithReadPermissions(permission, fromViewController: nil) { (loginResult, error) in
            if error == nil {
                success?()
            } else {
                fails?(error: error)
            }
        }
    }
    
    private static func getCurrentUser(success: (() -> ())?, fails: ((error: NSError) -> ())?) {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            let parameters = ["fields" : ""]
            FBSDKGraphRequest(graphPath: "me", parameters: parameters, HTTPMethod: "GET").startWithCompletionHandler({ (requestConnection, result, error) in
                if error == nil {
                    let userDictionary = result as! [String : AnyObject]
                    let userID = userDictionary["id"] as! String
                    let userName = userDictionary["name"] as! String
                    let currentUser = FacebookUser(id: userID, name: userName)
                    saveFacebookUser(currentUser)
                    success?()
                } else {
                    fails?(error: error)
                    print("facebook I don't get the facebook image profile", error.localizedDescription)
                }
            })
        } else {
            print("facebook token == nil")
            getDataLogin({
                getCurrentUser(success, fails: fails)
                }, fails: { (error) in
                    print("facebook", error?.localizedDescription)
            })
        }
    }
    
    // MARK: - save and get user
    
    private static func saveFacebookUser(user: FacebookUser) {
        // need to implement this function
    }
    
    static func getCurrentFacebookUser() -> FacebookUser? {
        // need to implement this function
    }
    
    // MARK: - data and information functions
    
    static func getUserProfileImage(success: ((imagePath: String) -> ())?, fails: ((error: NSError?) -> ())?) {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            let parameters = ["fields" : "picture.type(large)"]
            FBSDKGraphRequest(graphPath: "me", parameters: parameters, HTTPMethod: "GET").startWithCompletionHandler({ (requestConnection, result, error) in
                if error == nil {
                    guard let dictionary = result as? [String : AnyObject] else {
                        delegate?.facebookManagerFailReceivedUserProfileImage?(nil)
                        fails?(error: nil)
                        return
                    }
                    guard let pictureDictionary = dictionary["picture"] as? [String : AnyObject] else {
                        delegate?.facebookManagerFailReceivedUserProfileImage?(nil)
                        fails?(error: nil)
                        return
                    }
                    guard let urlPath = pictureDictionary["data"]?["url"] as? String else {
                        delegate?.facebookManagerFailReceivedUserProfileImage?(nil)
                        fails?(error: nil)
                        return
                    }
                    success?(imagePath: urlPath)
                } else {
                    fails?(error: error)
                }
            })
        } else {
            getDataLogin({
                getUserProfileImage(success, fails: fails)
                }, fails: { (error) in
                    fails?(error: error)
            })
        }
    }
    
    static func getUserBirthday(success: ((date: NSDate) -> ())?, fails: ((error: NSError) -> ())?) {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            let parameters = ["fields": "birthday"]
            FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil) {
                    let result = result as! [String : AnyObject]
                    let birthday = result["birthday"] as! String
                    let dateFormatteer = NSDateFormatter()
                    dateFormatteer.dateFormat = "MM-dd-yyyy"
                    guard let date = dateFormatteer.dateFromString(birthday) else { return }
                    delegate?.facebookManagerReceivedUserBirthday?(date)
                    success?(date: date)
                } else {
                    if error != nil {
                        delegate?.facebookManagerFailReceivedUserBirthday?(error!)
                    }
                    fails?(error: error)
                    print(error.localizedDescription)
                }
            })
        } else {
            getDataLogin({
                getUserBirthday(success, fails: fails)
                }, fails: { (error) in
                    if error != nil {
                        delegate?.facebookManagerFailReceivedUserBirthday?(error!)
                    }
                    print(error?.localizedDescription)
                    
            })
        }
    }
    
    // TODO: - need to come up any error for if user doesn't have a work
    /// you get data from result by following keys employer, position, location
    static func getUserWork(success: ((result: [String : AnyObject]) -> ())?, fails: ((error: NSError?) -> ())?) {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            let parameters = ["fields" : "work"]
            FBSDKGraphRequest(graphPath: "me", parameters: parameters, HTTPMethod: "GET").startWithCompletionHandler({ (requestConnection, result, error) in
                if error == nil {
                    var returnedResult = [String : AnyObject]()
                    let resultDictionary = result as! [String : AnyObject]
                    
                    guard let workArray = resultDictionary["work"] as? [[String : AnyObject]] else {
                        delegate?.facebookManagerFailReceivedUserWork?(nil)
                        fails?(error: nil)
                        return
                    }
                    
                    if let lastWorkspace = workArray.first {
                        if let position = lastWorkspace["position"] as? [String : AnyObject] {
                            guard let positionName = position["name"] as? String else { return }
                            returnedResult["position"] = positionName
                        }
                        
                        if let employer = lastWorkspace["employer"] as? [String : AnyObject] {
                            guard let employerName = employer["name"] as? String else { return }
                            returnedResult["employer"] = employerName
                        }
                        
                        if let location = lastWorkspace["location"] as? [String : AnyObject] {
                            guard let locationName = location["name"] as? String else { return }
                            returnedResult["location"] = locationName
                        }
                        print("returnedResult", returnedResult)
                        delegate?.facebookManagerReceivedUserWork?(returnedResult)
                        success?(result: returnedResult)
                    } else {
                        delegate?.facebookManagerFailReceivedUserWork?(error)
                        fails?(error: nil)
                    }
                } else {
                    delegate?.facebookManagerFailReceivedUserWork?(error)
                    fails?(error: error)
                    print(error.localizedDescription)
                }
            })
        } else {
            getDataLogin({
                getUserWork(success, fails: fails)
                }, fails: { (error) in
                    fails?(error: error)
            })
        }
    }
    
    /// you get data from result by following keys schoolName, type, year, concentration
    static func getUserEducation(success: ((result: [String : AnyObject]) -> ())?, fails: ((error: NSError?) -> ())?) {
        //education
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            let parameters = ["fields" : "education"]
            FBSDKGraphRequest(graphPath: "me", parameters: parameters, HTTPMethod: "GET").startWithCompletionHandler({ (requestConnection, result, error) in
                if error == nil {
                    var returnedResult = [String : AnyObject]()
                    let resultDictionary = result as! [String : AnyObject]
                    guard let education = resultDictionary["education"] as? [[String : AnyObject]] else {
                        fails?(error: nil)
                        return
                    }
                    
                    guard let lastEducation = education.first else {
                        fails?(error: nil)
                        return
                    }
                    
                    if let school = lastEducation["school"] as? [String : AnyObject] {
                        guard let schoolName = school["name"] as? String else { return }
                        returnedResult["schoolName"] = schoolName
                    }
                    
                    if let type = lastEducation["type"] as? String {
                        returnedResult["type"] = type
                    }
                    
                    if let year = lastEducation["year"] as? [String : AnyObject] {
                        guard let nameYear = year["name"] as? String else { return }
                        returnedResult["year"] = nameYear
                    }
                    
                    if let concentration = lastEducation["concentration"] as? [[String : AnyObject]] {
                        guard let lastConcentration = concentration.first else { return }
                        guard let name = lastConcentration["name"] as? String else { return }
                        returnedResult["concentration"] = name
                    }
                    print("returnedResult", returnedResult)
                    delegate?.facebookManagerReceivedUserEducation?(returnedResult)
                    success?(result: returnedResult)
                } else {
                    delegate?.facebookManagerFailReceivedUserEduction?(nil)
                    fails?(error: nil)
                }
            })
        } else {
            getDataLogin({
                getUserEducation(success, fails: fails)
                }, fails: { (error) in
                    delegate?.facebookManagerFailReceivedUserEduction?(nil)
                    fails?(error: nil)
            })
        }
    }
    
    static func getUserRelationship(success: ((status: String) -> ())?, fails: ((error: NSError?) -> ())?) {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            let parameters = ["fields" : "relationship_status"]
            FBSDKGraphRequest(graphPath: "me", parameters: parameters, HTTPMethod: "GET").startWithCompletionHandler({ (requestConnection, result, error) in
                if error == nil {
                    print("result", result)
                    guard let statusDictionary = result as? [String : AnyObject] else {
                        delegate?.facebookManagerFailReceivedUserRelationshipStatus?(nil)
                        fails?(error: nil)
                        return
                    }
                    guard let status = statusDictionary["relationship_status"] as? String else {
                        delegate?.facebookManagerFailReceivedUserRelationshipStatus?(nil)
                        fails?(error: nil)
                        return
                    }
                    delegate?.facebookManagerReceivedUserRelationshipStatus?(status)
                    success?(status: status)
                } else {
                    delegate?.facebookManagerFailReceivedUserRelationshipStatus?(error)
                    fails?(error: error)
                    print("getUserRelationship error", error.localizedDescription)
                }
            })
        } else {
            getDataLogin({
                getUserRelationship(success, fails: fails)
                }, fails: { (error) in
                    delegate?.facebookManagerFailReceivedUserRelationshipStatus?(error)
                    fails?(error: error)
            })
        }
    }
    
    static func getUserName(success: ((username: String) -> ())?, fails: ((error: NSError?) -> ())?) {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            let parameters = ["fields" : "name"]
            FBSDKGraphRequest(graphPath: "me", parameters: parameters, HTTPMethod: "GET").startWithCompletionHandler({ (requestConnection, result, error) in
                if error == nil {
                    guard let resultDictionary = result as? [String : AnyObject] else {
                        delegate?.facebookManagerFailReceivedUsername?(nil)
                        fails?(error: nil)
                        return
                    }
                    guard let username = resultDictionary["name"] as? String else {
                        delegate?.facebookManagerFailReceivedUsername?(nil)
                        fails?(error: nil)
                        return
                    }
                    success?(username: username)
                } else {
                    delegate?.facebookManagerFailReceivedUsername?(error)
                    fails?(error: error)
                }
            })
        } else {
            getDataLogin({
                getUserName(success, fails: fails)
                }, fails: { (error) in
                    delegate?.facebookManagerFailReceivedUsername?(error)
                    fails?(error: error)
            })
        }
    }
}