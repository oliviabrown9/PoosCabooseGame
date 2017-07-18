//
//  GameSettings.swift
//  KittyJump
//
//  Created by Olivia Brown on 7/18/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import Foundation
import UIKit

var g_bPause : Bool = false

func load()
{
    let userDefault = UserDefaults.standard
    
    let bLoad : Bool = userDefault.bool(forKey: "kittykittykitty")
    
    if (!bLoad) {
        
        userDefault.set(true, forKey: "kittykittykitty")
        g_bPause = false
        userDefault.set(g_bPause, forKey: "kitty_game_pause")
        userDefault.synchronize()
        
    }
    else {
        
        g_bPause = userDefault.bool(forKey: "kitty_game_pause")
    }
}

func setPauseState()
{
    let userDefault = UserDefaults.standard
    userDefault.set(g_bPause, forKey: "kitty_game_pause")
    userDefault.synchronize()
}

func getPauseState()
{
    let userDefault = UserDefaults.standard
    g_bPause = userDefault.bool(forKey: "kitty_game_pause")
}
