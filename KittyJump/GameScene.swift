//
//  GameScene.swift
//  KittyJump
//
//  Created by Olivia Brown on 6/9/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import SpriteKit
import GameplayKit
import Foundation
import AVFoundation
import GoogleMobileAds

var playCount: Int = 0
var soundState: Bool = SharingManager.sharedInstance.soundState

class GameScene: SKScene, SKPhysicsContactDelegate {
    var interstitial: GADInterstitial!
    
    var soundEffectPlayer: AVAudioPlayer = AVAudioPlayer()
    
    var viewController: UIViewController?
    let background = SKSpriteNode(imageNamed: "background")
    
    // Variables for position
    let trainYPosition: CGFloat = -600.0
    let trainDiffPosition: CGFloat = 185.0
    
    // Variables for game play
    var isStart = false
    var pauseState = false
    var gamePaused = false
    var pauseButton:SKSpriteNode!
    var soundButton:SKSpriteNode!
    var showBagAtEvery:Int = Int(arc4random_uniform(10)) + 15;
    
    //    let trainAlpha = 1;
    //    let trackAlpha = 0.4;
    //    let grassAlpha = 0.7;
    var bonusPoint = 100;
    
    // Label for current score
    var scoreLabel: SKLabelNode!
    var coinLabel: SKLabelNode!
    var coinImage: SKSpriteNode!
    var bonusLabel: SKLabelNode!
    
    // Enum for train direction
    enum kittyCurrentTrain {
        case LeftTrain
        case RightTrain
    }
    
    // Enum for kitty location
    enum kittyState {
        case onAir
        case onTrain
    }
    
    // Starting position is on a right train
    var kittyCurrentState  = kittyState.onTrain
    var kittyPosition = kittyCurrentTrain.RightTrain
    
    // Screen sprite variable
    var kittyCamera = KCamera()
    var isUpdateCameraPosY = false
    var cameraFocus = SKSpriteNode()
    
    var trainTrackArray = [TrainTrack]()
    var grassArray = [Grass]()
    let deadline = Deadline()
    var newDeadlinePosY:CGFloat = 0
    
    let leftTrain1 = LeftTrain()
    let rightTrain1 = RightTrain()
    var currentLeftTrain:LeftTrain!
    var currentRightTrain:RightTrain!
    var leftTrainArray = [LeftTrain]()
    var isFirstTrain = true
    var newLeftTrainIndex = -1
    var rightTrainArray = [RightTrain]()
    var newRightTrainIndex = -1
    var newTrainPosY: CGFloat = -600.0
    let kitty = Kitty()
    var joint1: SKPhysicsJointPin!
    var currentTrain: Int = 3
    var currentTrainNumber: Int = 0
    var stepSpeed: Int = 0
    var stepPos: CGFloat = 0
    var beforeColorIndex = -1
    let countTrainArray = 3
    var timeOfTrain: Double = 4.4
    var isStop = false
    
    
    // Starting score label set to zero & changes with current score
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    var roundCoins: Int = SharingManager.sharedInstance.lifetimeScore {
        didSet {
            coinLabel.text = "\(roundCoins)"
        }
    }
    
    let pastHighScore: Int = SharingManager.sharedInstance.highScore
    // Starting high score set to zero & changes as high score updates
    var highScore: Int = 0 {
        didSet {
            Label.highScoreLabel.text = "Best: \(pastHighScore)"
            
        }
    }
    
    // Init functions
    override init() {
        super.init()
        isStart = false
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -1)
        
        let borderBody = SKPhysicsBody(edgeLoopFrom:
            CGRect(
                x:self.frame.minX,
                y:self.frame.minY,
                width:self.frame.width,
                height:self.frame.height * 10000))
        borderBody.friction = 0
        self.physicsBody = borderBody
        self.physicsBody?.categoryBitMask = categoryBorder
        
        beforeColorIndex = [0, 1, 2].randomItem()
        
        
        stepSpeed = 0
        stepPos = 0
        createHud()
        setupTrackArray()
        setupGrassArray()
        
        newDeadlinePosY = trainYPosition + trainDiffPosition + 160
        setupDeadline()
        
        setupFirstRightAndLeftTrains()
        currentTrainNumber = 0
    }
    
    // Movement
    func switchJoint(iWagon: RightTrain) {
        var bonusFound = false;
        let coinStatus = iWagon.userData?.value(forKey: "coin") as! String;
        print("selected is " + coinStatus);
        bonusFound = ((coinStatus ).contains("yes"))
        print("bonus found \(bonusFound.description)")
        if(bonusFound){
            
            print("fetech name wagon_" + iWagon.name!)
            if let child = iWagon.childNode(withName: "wagon_" + iWagon.name!) as? SKSpriteNode {
                child.removeAllChildren()
            }
        }
        if let jointN = joint1 {
            
            self.physicsWorld.remove(jointN)
            
            if let wagonPhysicBody = iWagon.physicsBody, let kittyPhysicBody = kitty.physicsBody {
                
                kitty.position.x = iWagon.frame.minX + (kitty.size.width/2.0) + 8.0
                kitty.position.y = iWagon.frame.maxY
                
                joint1 = SKPhysicsJointPin.joint(withBodyA: wagonPhysicBody, bodyB: kittyPhysicBody, anchor: CGPoint(x: iWagon.frame.minX, y: iWagon.frame.midY))
                self.physicsWorld.add(joint1)
                updateScore(bonusFound: bonusFound)
                if score < 10 {
                    bonusPoint = 10
                }
                else if score > 10 && score <= 20 {
                    bonusPoint = 25
                }
                else if score > 20 && score <= 40 {
                    bonusPoint = 50
                }
                else if score > 40 && score <= 80 {
                    bonusPoint = 100
                }
                else if score > 80 && score <= 160 {
                    bonusPoint = 150
                }
                else if score > 160 && score <= 320 {
                    bonusPoint = 200
                }
                else if score > 320 {
                    bonusPoint = 250
                }
                kittyCurrentState = .onTrain
            }
        }
    }
    
    func switchJointL(iWagon :LeftTrain ) {
        var bonusFound = false;
        
        self.physicsWorld.removeAllJoints()
        let coinStatus = iWagon.userData?.value(forKey: "coin") as! String;
        print("selected is \(String(describing: coinStatus))");
        
        bonusFound = ((coinStatus ).contains("yes"))
        print("bonus found \(bonusFound.description)")
        if(bonusFound){
            
            print("fetech name wagon_" + iWagon.name!)
            if let child = iWagon.childNode(withName: "wagon_" + iWagon.name!) as? SKSpriteNode {
                child.removeAllChildren()
            }
        }
        if let wagonPhysicBody = iWagon.physicsBody, let kittyPhysicBody = kitty.physicsBody {
            
            kitty.position.x  = iWagon.frame.maxX - (kitty.size.width/2.0)-8.0
            kitty.position.y  = iWagon.frame.maxY
            
            joint1 = SKPhysicsJointPin.joint(withBodyA: wagonPhysicBody, bodyB: kittyPhysicBody, anchor: CGPoint(x: iWagon.frame.midX, y: iWagon.frame.midY))
            self.physicsWorld.add(joint1)
            updateScore(bonusFound: bonusFound)
            kittyCurrentState = .onTrain
        }
    }
    
    func updateScore(bonusFound: Bool) {
        score = score + 1
        
        var coinsEarned = 0
        
        if(bonusFound) {
            if (!soundState) {
                let newHighScoreSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "foundCoins", ofType: "mp3")!)
                do {
                    let audioSession = AVAudioSession.sharedInstance()
                    try!audioSession.setCategory(AVAudioSessionCategoryAmbient, with: AVAudioSessionCategoryOptions.mixWithOthers)
                    soundEffectPlayer = try AVAudioPlayer(contentsOf: newHighScoreSound as URL)
                    soundEffectPlayer.numberOfLoops = 0
                    soundEffectPlayer.prepareToPlay()
                    soundEffectPlayer.volume = 0.5
                    soundEffectPlayer.play()
                } catch {
                    print("Cannot play the file")
                }
            }
            roundCoins = roundCoins + (bonusPoint * multiplier)
            coinsEarned = (bonusPoint * multiplier) + multiplier
            bonusLabel.text = "+\(coinsEarned)"
            
        }
        else {
            roundCoins = roundCoins + multiplier
            bonusLabel.text = "+\(multiplier)"
        }
        if coinsEarned < 10 {
            bonusLabel.position = CGPoint(x: self.frame.maxX - 40, y: 80)
        }
        else if coinsEarned >= 10 && coinsEarned < 100 {
            bonusLabel.position = CGPoint(x: self.frame.maxX - 55, y: 80)
        }
        else if coinsEarned >= 100 && coinsEarned < 1000 {
            bonusLabel.position = CGPoint(x: self.frame.maxX - 65, y: 80)
        }
        else if coinsEarned >= 1000 {
            bonusLabel.position = CGPoint(x: self.frame.maxX - 77, y: 80)
        }
        
        bonusLabel.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.bonusLabel.isHidden = true
        }
        
        
        SharingManager.sharedInstance.lifetimeScore = roundCoins
        if score > pastHighScore {
            Label.highScoreLabel.text = "Best: \(score)"
        }
        
        if(score >= 5 && score < 10){
            timeOfTrain =  4.2;
        } else
            if(score >= 10 && score < 20){
                timeOfTrain =  4.0;
            } else
                if(score >= 20 && score < 40){
                    timeOfTrain =  3.8;
                } else
                    if(score >= 40 && score < 80){
                        timeOfTrain =  3.6;
                    } else
                        if(score >= 80 && score < 160){
                            timeOfTrain =  3.4;
                        }
                        else
                            if(score >= 160 && score < 320){
                                timeOfTrain =  3.2;
                            }
                                
                            else
                                if(score >= 320 && score < 640){
                                    timeOfTrain =  3.0;
        }
        
    }
    func setSoundButton() {
        if soundState == true {
            soundButton.texture = SKTexture(imageNamed: "sound")
        }
        else {
            soundButton.texture = SKTexture(imageNamed: "mute")
        }
    }
    
    // Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Pause Button click
        let touch = touches.first
        let positionInScene = touch!.location(in: self)
        let touchedNode = self.atPoint(positionInScene)
        let name = touchedNode.name
        
        if (name == "pause") {
            pauseState = !pauseState
            if (pauseState) {
                pauseGame()
                pauseButton.texture = SKTexture(imageNamed: "play")
            }
            else {
                playGame()
                resetMoveRightTrainWhenRestartGame()
                resetMoveLeftTrainWhenRestartGame()
                pauseButton.texture = SKTexture(imageNamed: "pause")
            }
        }
        else if (name == "sound") {
            soundState = !soundState
            SharingManager.sharedInstance.soundState = soundState
            if (soundState) {
                muteSound()
                setSoundButton()
            }
            else {
                playSound()
                setSoundButton()
            }
        }
        else {
            if name == "hud" {
                return
            }
            else if (!pauseState) {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                let successGenerator = UINotificationFeedbackGenerator()
                generator.prepare()
                successGenerator.prepare()
                if kittyCurrentState == .onTrain {
                    self.physicsWorld.removeAllJoints()
                    kitty.animateShape(destPos: CGPoint(x: kitty.position.x,
                                                        y: kitty.position.y + 200))
                    kitty.zPosition = 3
                    
                    if score != pastHighScore {
                        generator.impactOccurred()
                    }
                    
                    if (!soundState) {
                        let jumpSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "jump", ofType: "mp3")!)
                        do {
                            let audioSession = AVAudioSession.sharedInstance()
                            try!audioSession.setCategory(AVAudioSessionCategoryAmbient, with: AVAudioSessionCategoryOptions.mixWithOthers)
                            soundEffectPlayer = try AVAudioPlayer(contentsOf: jumpSound as URL)
                            soundEffectPlayer.numberOfLoops = 0
                            soundEffectPlayer.volume = 0.8
                            soundEffectPlayer.prepareToPlay()
                            soundEffectPlayer.play()
                        } catch {
                            print("Cannot play the file")
                        }
                    }
                    kittyCurrentState = .onAir
                    
                    if score == pastHighScore {
                        successGenerator.notificationOccurred(.success)
                        if (!soundState) {
                            let newHighScoreSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "newHighScore", ofType: "mp3")!)
                            do {
                                let audioSession = AVAudioSession.sharedInstance()
                                try!audioSession.setCategory(AVAudioSessionCategoryAmbient, with: AVAudioSessionCategoryOptions.mixWithOthers)
                                soundEffectPlayer = try AVAudioPlayer(contentsOf: newHighScoreSound as URL)
                                soundEffectPlayer.numberOfLoops = 0
                                soundEffectPlayer.prepareToPlay()
                                soundEffectPlayer.volume = 1
                                soundEffectPlayer.play()
                            } catch {
                                print("Cannot play the file")
                            }
                        }
                    }
                }
            }
            else if(pauseState) {
                pauseState = false
                playGame()
                resetMoveRightTrainWhenRestartGame()
                resetMoveLeftTrainWhenRestartGame()
                pauseButton.texture = SKTexture(imageNamed: "pause")
            }
        }
    }
    
    // Init functions to build screen
    
    // HUD
    func createHud()  {
        let hud = SKSpriteNode(color: UIColor.init(red: 0.1, green: 0.5, blue: 0.9, alpha: 0), size: CGSize(width: self.frame.width, height: trainDiffPosition * 2
        ))
        
        hud.anchorPoint = CGPoint(x:0.5, y:0.5)
        hud.position = CGPoint(x:0 , y:self.size.height/2  - hud.size.height/2)
        hud.zPosition = 4
        hud.name = "hud"
        scoreLabel = SKLabelNode(fontNamed: "Avenir-Medium")
        scoreLabel.zPosition = 1
        scoreLabel.fontSize = 160
        scoreLabel.text = "0"
        
        scoreLabel.fontColor = UIColor.white
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .center
        hud.addChild(scoreLabel)
        
        
        bonusLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        bonusLabel.zPosition = 1
        bonusLabel.fontSize = 40
        bonusLabel.text = "\(bonusPoint)"
        bonusLabel.fontColor = UIColor.white
        bonusLabel.position = CGPoint(x: self.frame.maxX - 40, y: 80)
        bonusLabel.verticalAlignmentMode = .center
        hud.addChild(bonusLabel)
        
        bonusLabel.isHidden = true
        
        coinLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        coinLabel.zPosition = 1
        coinLabel.fontSize = 40
        coinLabel.text = "\(SharingManager.sharedInstance.lifetimeScore)"
        coinLabel.fontColor = UIColor.white
        coinLabel.position = CGPoint(x: self.frame.maxX - 75 , y: 130)
        coinLabel.verticalAlignmentMode = .center
        hud.addChild(coinLabel)
        
        coinImage = SKSpriteNode(imageNamed: "coin")
        coinImage.size.height = 36
        coinImage.size.width = 40
        coinImage.position = CGPoint(x: coinLabel.frame.minX - 25, y: 130)
        hud.addChild(coinImage)
        
        
        kittyCamera.addChild(hud)
        
        Label.createHighScore()
        Label.highScoreLabel.position = CGPoint(x: self.frame.midX, y: 130)
        hud.addChild(Label.highScoreLabel)
        
        pauseButton = SKSpriteNode(imageNamed: "pause")
        pauseButton.name = "pause"
        pauseButton.size.height = 40
        pauseButton.size.width = 40
        pauseButton.position = CGPoint(x:-(hud.size.width/2)+50, y: 130)
        hud.addChild(pauseButton)
        
        if soundState == true {
            soundButton = SKSpriteNode(imageNamed: "sound")
        }
        else {
            soundButton = SKSpriteNode(imageNamed: "mute")
        }
        soundButton.name = "sound"
        soundButton.size.height = 40
        soundButton.size.width = 60
        soundButton.position = CGPoint(x:-(hud.size.width/2)+130, y: 130)
        hud.addChild(soundButton)
    }
    
    // Train Track & Grass
    func setupTrackArray() {
        for i in 0...5 {
            let trainTrack = TrainTrack()
            trainTrack.position = getTrainTrackPosition(row : i)
            trainTrack.name = "Track" + String(i)
            trainTrack.zPosition = 1
            self.addChild(trainTrack)
            trainTrackArray.append(trainTrack)
        }
    }
    
    func getTrainTrackPosition(row: Int) -> CGPoint {
        let x = self.frame.minX
        let y = trainYPosition + trainDiffPosition * CGFloat(row)
        return CGPoint(x: x, y: y)
    }
    
    func setupNewTrack(index: Int, posY: CGFloat) {
        print("setting up new track \(index)")
        let nodeName = "Track" + String(index)
        self.enumerateChildNodes(withName: nodeName) {
            node, stop in
            node.removeFromParent();
        }
        
        let trainTrack = trainTrackArray[index]
        trainTrack.position.y = posY
        trainTrack.name = nodeName
        trainTrack.zPosition = 1
        self.addChild(trainTrack)
    }
    
    func setupGrassArray() {
        for i in 0...5 {
            let grass = Grass()
            if i == 5 {
                //                grass.alpha = 1
            }
            
            
            let nodeName = "Grass" + String(i)
            grass.name = nodeName;
            
            
            grass.position = getGrassPosition(row: i)
            grass.zPosition = 1
            //            grass.alpha = CGFloat(grassAlpha)
            self.addChild(grass)
            grassArray.append(grass)
        }
    }
    
    func getGrassPosition(row: Int) -> CGPoint {
        let x = self.frame.minX
        let y = trainYPosition + trainDiffPosition * CGFloat(row) + TrainTrack.getHeight()
        return CGPoint(x: x, y: y)
    }
    
    func setupDeadline() {
        deadline.position = getDeadlinePosition(posY: newDeadlinePosY)
        self.addChild(deadline)
    }
    
    func getDeadlinePosition(posY: CGFloat) -> CGPoint {
        let x = self.frame.minX
        return CGPoint(x: x, y: posY)
    }
    
    
    func setupFirstRightAndLeftTrains() {
        isFirstTrain = true
        var posY1: CGFloat = newTrainPosY + 20 + 45
        var posY2: CGFloat = posY1 + trainDiffPosition
        var coins = "no";
        
        for i in 0..<countTrainArray {
            if i != 0 {
                posY1 = -1000
                posY2 = -1000
            }
            
            //            if( i > 0 && ((i%randRange(lower: 2,upper: 6)) == 0)){
            if( i > 0 && ((i%5) == 0)){
                coins = "yes";
            }else{
                coins = "no";
                
            }
            // Right train
            let rightTrain = RightTrain()
            rightTrain.position = CGPoint(x:self.frame.minX + (rightTrain.size.width - rightTrain.size.width/2), y: posY1)
            rightTrain.name = "right" + String(i)
            currentRightTrain = rightTrain
            
            var wagon = createWagon(bonus: false)
            wagon.name = "wagon_" + rightTrain.name!
            print("create name wagon_" + rightTrain.name!)
            rightTrain.zPosition = 2
            rightTrain.addChild(wagon)
            //            rightTrain.alpha = CGFloat(trainAlpha);
            self.addChild(rightTrain)
            rightTrainArray.append(rightTrain);
            
            
            
            //            if( i > 0 && ((i%randRange(lower: 2,upper: 6)) == 0)){
            if( i > 0 && (((i+1)%5) == 0)){
                coins = "yes";
            }else{
                coins = "no";
                
            }
            
            
            // Left train
            let leftTrain = LeftTrain()
            leftTrain.position = CGPoint(x:self.frame.maxX + leftTrain.size.width/2, y:posY2)
            leftTrain.name = "left" + String(i)
            
            currentLeftTrain = leftTrain
            wagon = createWagon(rightSide: false,bonus: false)
            leftTrain.zPosition = 2
            wagon.name = "wagon_"+leftTrain.name!
            leftTrain.addChild(wagon)
            //            leftTrain.alpha = CGFloat(trainAlpha);
            self.addChild(leftTrain)
            leftTrainArray.append(leftTrain)
        }
    }
    
    func createWagon(rightSide: Bool = true, bonus: Bool = false) -> SKSpriteNode {
        
        // Get random color except the color before
        var restColorIndices = [Int]()
        for i in 0...2 {
            if i != beforeColorIndex {
                restColorIndices.append(i)
            }
        }
        beforeColorIndex = restColorIndices.randomItem()
        
        // Get color image
        var wagon:SKSpriteNode
        switch beforeColorIndex {
        case 0:
            wagon = SKSpriteNode(imageNamed:"o")
        case 1:
            wagon = SKSpriteNode(imageNamed:"r")
        case 2:
            wagon = SKSpriteNode(imageNamed:"y")
        default:
            wagon = SKSpriteNode()
        }
        
        
        // Get color image
        // Locate imate at specified point
        let size = CGSize(width: 110, height: 45)
        wagon.scale(to: size)
        if rightSide {
            let xPos = currentRightTrain.size.width/2
            let yPos = currentRightTrain.size.height/2
            wagon.anchorPoint = CGPoint(x:0, y:0)
            wagon.position = CGPoint(x: -xPos, y: -yPos)
            if(bonus){
                print("bonus exist")
                
                var coin:SKSpriteNode
                let size = CGSize(width: 110, height: 200)
                coin = SKSpriteNode(imageNamed:"poos coin bag")
                coin.scale(to: size)
                coin.name = "bonus";
                coin.position.y = wagon.position.y + coin.size.height + 10
                coin.position.x =  -(wagon.size.width/2) + coin.size.width + 50
                coin.zPosition = 2
                wagon.addChild(coin);
            }else{
                
                print("bonus not available")
            }
            
        } else {
            wagon.removeAllChildren();
            let xPos1 = currentLeftTrain.size.width/2
            let yPos1 = currentLeftTrain.size.height/2
            wagon.anchorPoint = CGPoint(x:1, y:0)
            wagon.position = CGPoint(x: xPos1, y: -yPos1)
            if(bonus){
                print("bonus exist")
                
                
                var coin:SKSpriteNode
                let size = CGSize(width: 110, height: 200)
                coin = SKSpriteNode(imageNamed:"poos coin bag")
                coin.scale(to: size)
                coin.name = "bonus";
                coin.position.y =  wagon.position.y + coin.size.height  + 10
                coin.position.x =  +(wagon.size.width/2) - coin.size.width - 40
                coin.zPosition = 2
                
                wagon.addChild(coin);
            }else{
                
                print("bonus not available")
            }
        }
        wagon.zPosition = 2
        
        return wagon
    }
    
    var index = 0;
    // Set the train in motion
    func moveRightWagon2() {
        // Track height: 20 & train height: 45
        let yPositionC: CGFloat = CGFloat(newTrainPosY + 20 + 45)
        
        newRightTrainIndex += 1
        index+=1
        print("newRightTrainIndex \(newRightTrainIndex)")
        if newRightTrainIndex > countTrainArray-1 {
            newRightTrainIndex %= countTrainArray
        }
        
        print("onus foun index \(index)")
        print("onus foun call \(index%showBagAtEvery)")
        let irWagon = rightTrainArray[newRightTrainIndex]
        //        let irWagon = createNewRightTrain(pos: newRightTrainIndex);
        if(index%showBagAtEvery == 0){
            print("bonus exist")
            
            irWagon.userData = NSMutableDictionary();
            irWagon.userData?.setValue("yes", forKey: "coin")
            
            var coin:SKSpriteNode
            let size = CGSize(width: 110, height: 200)
            coin = SKSpriteNode(imageNamed:"poos coin bag")
            coin.scale(to: size)
            coin.name = "bonus";
            
            if let child = irWagon.childNode(withName: "wagon_" + irWagon.name!) as? SKSpriteNode {
                
                coin.position.y = (child.position.y) + coin.size.height + 10
                
                coin.position.x =  -(child.size.width/2) + coin.size.width + 50
                coin.zPosition = 2
                child.addChild(coin);
            }
            showBagAtEvery = Int(arc4random_uniform(10)) + 15
        }else{
            
            irWagon.userData = NSMutableDictionary();
            irWagon.userData?.setValue("no", forKey: "coin")
        }
        
        var posInit = CGPoint.zero
        var posTo = CGPoint.zero
        
        if isFirstTrain {
            let firsttrain = rightTrainArray[0]
            posInit = CGPoint(x: self.frame.minX + firsttrain.size.width/2,
                              y: yPositionC)
            posTo = CGPoint(x: self.frame.maxX + irWagon.size.width/2,
                            y: yPositionC)
            isFirstTrain = false
        }
        else {
            posInit = CGPoint(x: self.frame.minX - irWagon.size.width/2 - stepPos,
                              y: yPositionC)
            posTo = CGPoint(x: self.frame.maxX + irWagon.size.width/2 + stepPos,
                            y: yPositionC)
        }
        
        irWagon.position = posInit
        let act1 = SKAction.move(to: posInit, duration: 0.0)
        let act2 = SKAction.move(to: posTo, duration: timeOfTrain)
        let act = SKAction.sequence([act1, act2])
        
        irWagon.run(act)
        irWagon.timeOfTrain = timeOfTrain
        newTrainPosY += trainDiffPosition
    }
    
    func moveLeftTrain2() {
        index+=1
        
        // Track height: 20 & train height: 45
        let yPositionC: CGFloat = CGFloat(newTrainPosY + 20 + 45)
        
        newLeftTrainIndex += 1
        if newLeftTrainIndex > countTrainArray-1 {
            newLeftTrainIndex %= countTrainArray
        }
        
        let ilTrain = leftTrainArray[newLeftTrainIndex]
        
        print("onus foun index \(index)")
        print("onus foun call \(index%showBagAtEvery)")
        if(index%showBagAtEvery == 0){
            print("bonus exist")
            
            ilTrain.userData = NSMutableDictionary();
            ilTrain.userData?.setValue("yes", forKey: "coin")
            
            var coin:SKSpriteNode
            let size = CGSize(width: 110, height: 200)
            coin = SKSpriteNode(imageNamed:"poos coin bag")
            coin.scale(to: size)
            coin.name = "bonus";
            
            print("fetech name wagon1_" + ilTrain.name!)
            
            if let child = ilTrain.childNode(withName: "wagon_" + ilTrain.name!) as? SKSpriteNode {
                
                coin.position.y = (child.position.y) + coin.size.height + 10
                
                coin.position.x =  +(child.size.width/2) - coin.size.width - 40
                coin.zPosition = 2
                child.addChild(coin);
            }
            //            showBagAtEvery = Int(arc4random_uniform(10)) + 15
        } else{
            
            ilTrain.userData = NSMutableDictionary();
            ilTrain.userData?.setValue("no", forKey: "coin")
        }
        
        let posInit = CGPoint(x: self.frame.maxX + ilTrain.size.width/2 - stepPos,
                              y: yPositionC)
        
        let posTo = CGPoint(x: self.frame.minX - ilTrain.size.width/2,
                            y: yPositionC)
        ilTrain.position = posInit
        
        let act1 = SKAction.move(to: posInit, duration: 0.0)
        let act2 = SKAction.move(to: posTo, duration: timeOfTrain)
        let act = SKAction.sequence([act1, act2])
        ilTrain.run(act)
        ilTrain.timeOfTrain = timeOfTrain
        newTrainPosY += trainDiffPosition
    }
    
    // Reset the moving of right train from current position to purposeful position
    func resetMoveRightTrain() {
        let irWagon = rightTrainArray[newRightTrainIndex]
        let posInitR = CGPoint(x: irWagon.position.x - stepPos,
                               y: irWagon.position.y)
        
        let posToR = CGPoint(x: self.frame.maxX + irWagon.size.width/2 + stepPos,
                             y: irWagon.position.y)
        irWagon.position = posInitR
        
        let actR1 = SKAction.move(to: posInitR, duration: 0.0)
        let actR2 = SKAction.move(to: posToR, duration: timeOfTrain)
        let actR = SKAction.sequence([actR1, actR2])
        irWagon.run(actR)
    }
    
    func resetMoveRightTrainWhenRestartGame() {
        for i in 0..<rightTrainArray.count {
            let irWagon = rightTrainArray[i]
            let posInitR = CGPoint(x: irWagon.position.x - stepPos,
                                   y: irWagon.position.y)
            let posToR = CGPoint(x: self.frame.maxX + irWagon.size.width + posInitR.x + stepPos,
                                 y: irWagon.position.y)
            irWagon.position = posInitR
            
            let actR1 = SKAction.move(to: posInitR, duration: 0.0)
            let actR2 = SKAction.move(to: posToR, duration: timeOfTrain)
            let actR = SKAction.sequence([actR1, actR2])
            irWagon.run(actR)
        }
    }
    
    // Reset the moving of left train from current position to purposeful position
    func resetMoveLeftTrain() {
        let ilTrain = leftTrainArray[newLeftTrainIndex]
        let posInitL = CGPoint(x: ilTrain.position.x - stepPos,
                               y: ilTrain.position.y)
        let posToL = CGPoint(x: self.frame.minX - ilTrain.size.width/2,
                             y: ilTrain.position.y)
        ilTrain.position = posInitL
        
        let act1 = SKAction.move(to: posInitL, duration: 0.0)
        let act2 = SKAction.move(to: posToL, duration: timeOfTrain)
        let act = SKAction.sequence([act1, act2])
        ilTrain.run(act)
    }
    
    func resetMoveLeftTrainWhenRestartGame() {
        
        for i in 0..<leftTrainArray.count {
            let ilTrain = leftTrainArray[i]
            let posInitL = CGPoint(x: ilTrain.position.x - stepPos,
                                   y: ilTrain.position.y)
            let posToL = CGPoint(x: posInitL.x - (self.frame.maxX + ilTrain.size.width),
                                 y: ilTrain.position.y)
            ilTrain.position = posInitL
            
            let act1 = SKAction.move(to: posInitL, duration: 0.0)
            let act2 = SKAction.move(to: posToL, duration: timeOfTrain)
            let act = SKAction.sequence([act1, act2])
            ilTrain.run(act)
        }
    }
    // Contact delegate functions
    var needItme:Bool = true;
    func didBegin(_ contact: SKPhysicsContact) {
        //        if(needItme){
        //            moveRightWagon2()
        //            moveLeftTrain2()
        //            needItme = false;
        //        }
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask == categoryKitty && secondBody.categoryBitMask == categoryBorder) || (firstBody.categoryBitMask == categoryKitty && secondBody.categoryBitMask == categoryDeadline) {
            kitty.zPosition = 2
            kitty.removeAllActions()
            self.stop()
        }
        
        if isStop {
            return
        }
        
        // Handles left train & creates a right train
        if kittyPosition == .RightTrain {
            
            if firstBody.categoryBitMask == categoryKitty && secondBody.categoryBitMask == categoryTrain {
                
                if (contact.contactPoint.x > (secondBody.node!.frame.maxX - 100)) {
                    
                    kitty.removeAllActions()
                    kitty.zPosition = 2
                    
                    switchJointL(iWagon: secondBody.node! as! LeftTrain)
                    moveRightWagon2()
                    
                    changeTrackAndGrassInNewLocation()
                    
                    kittyPosition = .LeftTrain
                    
                    // Remove old deadline & add new deadline
                    newDeadlinePosY += trainDiffPosition
                    setNewDeadline()
                    isUpdateCameraPosY = true
                    
                }
                else {
                    stop()
                }
            }
        }
        
        // Handles right train & creates a left train
        if kittyPosition == .LeftTrain {
            if firstBody.categoryBitMask == categoryKitty && secondBody.categoryBitMask == categoryWagon {
                
                if (contact.contactPoint.x < (secondBody.node!.frame.minX + 100)) {
                    
                    kitty.removeAllActions()
                    kitty.zPosition = 2
                    
                    switchJoint(iWagon:secondBody.node! as! RightTrain)
                    moveLeftTrain2()
                    changeTrackAndGrassInNewLocation()
                    kittyPosition = .RightTrain
                    
                    // Remove old deadline & add new deadline
                    newDeadlinePosY += trainDiffPosition
                    setNewDeadline()
                    
                    // Camera
                    isUpdateCameraPosY = true
                }
                else {
                    stop()
                }
            }
        }
    }
    
    func setNewDeadline() {
        self.enumerateChildNodes(withName: "Deadline") {
            node, stop in
            node.removeFromParent();
        }
        setupDeadline()
    }
    
    func changeTrackAndGrassInNewLocation() {
        let lastTrain = currentTrain
        currentTrain += 1
        if currentTrain > 5 {
            currentTrain %= 6
        }
        
        print("updating alphas")
        print("count trainTrackArray \(trainTrackArray.count)")
        
        
        
        let newCurrentTrainPosY = trainTrackArray[lastTrain].position.y + trainDiffPosition
        setupNewTrack(index: currentTrain, posY: newCurrentTrainPosY)
        
        grassArray[currentTrain].position.y = grassArray[lastTrain].position.y + trainDiffPosition
        //        if let child = self.childNode(withName: "Track0") as? SKSpriteNode {
        //            child.alpha = 0;
        //        }
        
        if (currentTrain > 2){
            for i in 0...trainTrackArray.count-1 {
                print("index \(i)")
            }
            for j in 0...grassArray.count-1 {
                print("index j \(j)")
            }
        }
        grassArray[currentTrain].alpha = 1
        trainTrackArray[currentTrain].alpha = 1
        grassArray[lastTrain].alpha = 1
        trainTrackArray[lastTrain].alpha = 1
    }
    
    // SKScene functions
    override func didSimulatePhysics() {
        if(isStart && kitty.position.x > -200 && needItme){
            self.moveRightWagon2()
            self.moveLeftTrain2()
            self.needItme = false;
        }
        if isUpdateCameraPosY && (kitty.position.y > -100.0) {
            currentTrainNumber += 1
            if currentTrainNumber > 5 {
                stepPos = 50
                stepSpeed = 1
            }
            grassArray[5].alpha = 1
            trainTrackArray[5].alpha = 1
            
            let action = SKAction.moveTo(y: kitty.position.y + trainDiffPosition, duration: 0.5)
            action.timingMode = .easeInEaseOut
            kittyCamera.run(action)
            background.run(action)
            isUpdateCameraPosY = false
        }
    }
    
    func updateNodesYPosition(){
        let temp: CGFloat = 1000
        var newYPos: CGFloat = 0
        // Track & grass
        for i in 0...5 {
            
            // Track
            newYPos = trainTrackArray[i].position.y - temp
            setupNewTrack(index: i, posY: newYPos)
            
            // Grass
            grassArray[i].position.y -= temp
        }
        // Deadline
        newDeadlinePosY -= temp
        setNewDeadline()
        
        // Left & right trains
        updateAllTrainsCoordinate(temp: temp)
    }
    
    func updateAllTrainsCoordinate(temp: CGFloat) {
        var rightTrainName: String = ""
        var leftTrainName: String = ""
        
        for i in 0..<countTrainArray {
            
            // Right train
            rightTrainName = "right" + String(i)
            self.enumerateChildNodes(withName: rightTrainName) {
                node, stop in
                node.removeFromParent();
            }
            
            
            rightTrainArray[i].position.y -= temp
            
            rightTrainArray[i].userData = NSMutableDictionary()
            rightTrainArray[i].userData?.setValue("init", forKey: "coin")
            self.addChild(rightTrainArray[i])
            
            // Left train
            leftTrainName = "left" + String(i)
            self.enumerateChildNodes(withName: leftTrainName) {
                node, stop in
                node.removeFromParent();
            }
            leftTrainArray[i].position.y -= temp
            
            leftTrainArray[i].userData = NSMutableDictionary()
            leftTrainArray[i].userData?.setValue("init", forKey: "coin")
            self.addChild(leftTrainArray[i])
            newTrainPosY -= temp
        }
    }
    
    override func didMove(to view: SKView) {
        
        if isStart {
            // Place the background
            background.position = CGPoint(x: 0, y: 0)
            background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            background.size = self.size
            background.zPosition = -1
            self.addChild(background)
            
            self.physicsWorld.removeAllJoints()
            self.removeAllActions()
            self.physicsWorld.contactDelegate = self
            
            // Move the first 2 trains
            newTrainPosY = trainYPosition
            
            moveRightWagon2()
            moveLeftTrain2()
            
            kitty.position.x = rightTrainArray[0].frame.minX + (kitty.size.width/2.0)+8.0
            kitty.position.y = rightTrainArray[0].frame.maxY
            
            kitty.zPosition = 3
            self.addChild(kitty)
            joint1 = SKPhysicsJointPin.joint(withBodyA: rightTrainArray[0].physicsBody! , bodyB: kitty.physicsBody!, anchor: CGPoint(x: self.rightTrainArray[0].frame.minX, y: self.rightTrainArray[0].frame.midY))
            self.physicsWorld.add(joint1)
            
            kittyCamera.position.y = 0
            addChild(kittyCamera)
            self.camera = kittyCamera
        }
        else {
        }
    }
    
    // Game lost
    func stop() {
        playCount += 1
        
        kitty.removeAllActions()
        isStop = true
        
        let failureGenerator = UINotificationFeedbackGenerator()
        failureGenerator.notificationOccurred(.error)
        backgroundMusicPlayer.stop()
        
        if (!soundState) {
            let stopSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "stop", ofType: "mp3")!)
            do {
                soundEffectPlayer = try AVAudioPlayer(contentsOf: stopSound as URL)
                soundEffectPlayer.numberOfLoops = 1
                soundEffectPlayer.prepareToPlay()
                soundEffectPlayer.volume = 0.7
                soundEffectPlayer.play()
            } catch {
                print("Cannot play the file")
            }
        }
        
        // soundEffectPlayer.stop()
        
        // Add score to lifetimeScore
        if score != 0 {
            SharingManager.sharedInstance.lifetimeScore = roundCoins
        }
        
        // Store high score if necessary
        if score > SharingManager.sharedInstance.highScore {
            SharingManager.sharedInstance.highScore = score
        }
        
        // Store current score
        SharingManager.sharedInstance.currentScore = score
        
        // Stop the game
        self.gamePaused = true
        self.physicsWorld.removeAllJoints()
        self.removeAllActions()
        self.isPaused = true
        // Segue to gameOverVC
        
        ////        App.gViewController = se;
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.viewController?.performSegue(withIdentifier: "toGameOver", sender: self.viewController)
        }
    }
    
    
    func pauseGame() {
        
        backgroundMusicPlayer.stop()
        
        // Stop the game
        self.gamePaused = true
        self.isPaused = true
        savePause = true
        setPauseState()
        
        for i in 0..<rightTrainArray.count {
            let righttrain = rightTrainArray[i]
            righttrain.removeAllActions()
        }
        
        for i in 0..<leftTrainArray.count {
            let righttrain = leftTrainArray[i]
            righttrain.removeAllActions()
        }
    }
    
    func muteSound() {
        backgroundMusicPlayer.stop()
    }
    
    func playSound() {
        if (!soundState) {
            backgroundMusicPlayer.play()
        }
    }
    func playGame() {
        
        savePause = false
        setPauseState()
        
        backgroundMusicPlayer.stop()
        
        if (!soundState) {
            let backgroundMusic = NSURL(fileURLWithPath: Bundle.main.path(forResource: "background", ofType: "mp3")!)
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: backgroundMusic as URL)
                backgroundMusicPlayer.numberOfLoops = 1
                backgroundMusicPlayer.prepareToPlay()
                backgroundMusicPlayer.play()
            } catch {
                print("Cannot play the file")
            }
            let audioSession = AVAudioSession.sharedInstance()
            try!audioSession.setCategory(AVAudioSessionCategoryAmbient, with: AVAudioSessionCategoryOptions.mixWithOthers)
        }
        
        // Play the game
        self.gamePaused = false
        self.isPaused = false
    }
}

// Random
func randRange (lower: Int , upper: Int) -> Int {
    return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
}

extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
