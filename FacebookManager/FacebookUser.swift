//
//  FacebookUser.swift
//  FacebookManager
//
//  Created by Alexsander  on 6/10/16.
//  Copyright © 2016 Alexsander Khitev. All rights reserved.
//

import Foundation

class FacebookUser {
    
    var id: String!
    var name: String!
    
    convenience init(id: String, name: String) {
        self.init()
        self.id = id
        self.name = name
    }
}