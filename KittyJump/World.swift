//
//  World.swift
//  KittyJump
//
//  Created by awata6 on 18/08/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import Foundation

class World {
    
    var name: String
    var highScore: Int
    var todayScore: Int
    var imageURL: String
    
    init(name: String, highScore: Int, todayScore: Int, imageURL: String) {
        self.name = name
        self.highScore = highScore
        self.todayScore = todayScore
        self.imageURL = imageURL
    }
}
