//
//  GameSettings.swift
//  Olivia
//
//  Created by Olivia Brown on 7/19/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import Foundation
import UIKit

var savePause : Bool = false
var finishJump : Bool = false;

func load()
{
    let userDefault = UserDefaults.standard
    let bLoad: Bool = userDefault.bool(forKey: "kittykittykitty")
    
    if (!bLoad) {
        userDefault.set(true, forKey: "kittykittykitty")
        savePause = false
        userDefault.set(savePause, forKey: "gamePaused")
        userDefault.synchronize()
    }
    else {
        savePause = userDefault.bool(forKey: "gamePaused")
    }
}

func setPauseState()
{
    let userDefault = UserDefaults.standard
    userDefault.set(savePause, forKey: "gamePaused")
    userDefault.synchronize()
}

func getPauseState()
{
    let userDefault = UserDefaults.standard
    savePause = userDefault.bool(forKey: "gamePaused")
}
