//
//  FacebookManagerDelegate.swift
//  FacebookManager
//
//  Created by Alexsander  on 6/10/16.
//  Copyright © 2016 Alexsander Khitev. All rights reserved.
//

import Foundation

@objc protocol FacebookManagerDelegate {
    
    optional func facebookManagerReceivedUserProfileImage(image: UIImage)
    optional func facebookManagerFailReceivedUserProfileImage(error: NSError?)
    
    optional func facebookManagerReceivedUserBirthday(date: NSDate)
    optional func facebookManagerFailReceivedUserBirthday(error: NSError)
    
    optional func facebookManagerReceivedUserWork(resultDictionary: [String : AnyObject])
    optional func facebookManagerFailReceivedUserWork(error: NSError?)
    
    optional func facebookManagerReceivedUserEducation(resultDictionary: [String : AnyObject])
    optional func facebookManagerFailReceivedUserEduction(error: NSError?)
    
    optional func facebookManagerReceivedUserRelationshipStatus(status: String)
    optional func facebookManagerFailReceivedUserRelationshipStatus(error: NSError?)
    
    optional func facebookManagerReceivedUsername(username: String)
    optional func facebookManagerFailReceivedUsername(error: NSError?)
}