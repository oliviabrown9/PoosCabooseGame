//
//  Friend.swift
//  KittyJump
//
//  Created by Olivia Brown on 8/14/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import Foundation

class Friend {

    var name: String
    var highScore: String
    var todayScore: String
    var imageURL: String
    
    init(name: String, highScore: String, todayScore: String, imageURL: String) {
        self.name = name
        self.highScore = highScore
        self.todayScore = todayScore
        self.imageURL = imageURL
    }
}
