//
//  SessionManager.swift
//  KittyJump
//
//  Created by Olivia Brown on 6/12/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import UIKit


class SharingManager {
    
    // MARK: Local Variable
    
    var lastScores = [Int](repeating: 0, count: 9)
    var userDefaults: UserDefaults = UserDefaults.standard
    
    var highScore: Int = 0 {
        didSet {
            userDefaults.set(highScore, forKey: "HighScore")
        }
    }
    
    var currentScore: Int = 0 {
        didSet {
            changeLastScores(score: currentScore)
        }
    }
    
    static let sharedInstance = SharingManager()
    
    private init() {
        let _highScore = userDefaults.integer(forKey: "HighScore")
        if _highScore != 0 {
            highScore = _highScore
        }
        else {
            userDefaults.set(highScore, forKey: "HighScore")
        }
        
        let _lastScores = userDefaults.array(forKey: "LastScores") as? [Int]
        if _lastScores != nil {
            lastScores = _lastScores!
        }
        else {
            userDefaults.set(lastScores, forKey: "LastScores")
        }
    }
    
    func changeLastScores(score: Int) {
        var temp1, temp2: Int
        temp1 = score
        
        for i in 0..<lastScores.count {
            temp2 = lastScores[i]
            lastScores[i] = temp1
            temp1 = temp2
        }
        userDefaults.set(lastScores, forKey: "LastScores")
    }
}
