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

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var stopSoundPlayer: AVAudioPlayer = AVAudioPlayer()
    
    var viewController: UIViewController?
    
    // Variables for position
    let trainYpostion: CGFloat = -600.0
    let trainDiffpostion: CGFloat = 185.0
    
    // Variables for game play
    var isStart = false
    var gamePaused = false
    
    // Label for current score
    var scoreLabel: SKLabelNode!
    
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
    var kittyPostion = kittyCurrentTrain.RightTrain
    
    // Screen sprite variable
    var kittyCamera = KCamera()
    var isUpdateCameraPosY = false
    var cameraFocus = SKSpriteNode()
    
    var trainTrackArray = [TrainTrack] ()
    var grassArray = [Grass] ()
    let deadline = Deadline()
    var newDeadlinePosY:CGFloat = 0
    
    let leftTrain1 = LeftTrain()
    let rightTrain1 = RightTrain()
    
    var leftTrainArray = [LeftTrain]()
    var newLeftTrainIndex = -1
    
    var rightTrainArray = [RightTrain]()
    var newRightTrainIndex = -1
    
    var newTrainPosY:CGFloat = -600.0
    
    let kitty = Kitty()
    
    var joint1: SKPhysicsJointPin!
    
    var currentTrain: Int = 2
    
    var beforeColorIndex = -1
    
    // Starting score label set to zero & changes with current score
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    // Starting high score set to zero & changes as high score updates
    var highScore: Int = 0 {
        didSet {
            Label.highScoreLabel.text = "High Score: \(SharingManager.sharedInstance.highScore)"
        }
    }
    
    // Init functions
    override init() {
        super.init()
        isStart = false
    }
    
    override init(size: CGSize ) {
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
                height:self.frame.height * 10))
        borderBody.friction = 0
        self.physicsBody = borderBody
        self.physicsBody?.categoryBitMask = categoryBorder
        
        beforeColorIndex = [0, 1, 2].randomItem()
        
        setupTrackArray()
        setupGrassArray()
        
        newDeadlinePosY = trainYpostion + trainDiffpostion + 160
        setupDeadline()
        
        setupFirstRightAndLeftTrains()
        createHud()
    }
    
    // Movement
    func switchJoint(iWagon: RightTrain )  {
        
        if let jointN = joint1 {
            
            self.physicsWorld.remove(jointN)
            
            if let wagonPhysicBody = iWagon.physicsBody , let kittyPhysicBody = kitty.physicsBody {
                
                kitty.position.x = iWagon.frame.minX + kitty.size.width / 2
                kitty.position.y = iWagon.frame.maxY
                
                joint1 = SKPhysicsJointPin.joint(withBodyA: wagonPhysicBody , bodyB: kittyPhysicBody, anchor: CGPoint(x: iWagon.frame.minX, y: iWagon.frame.midY))
                self.physicsWorld.add(joint1)
                score = score + 1
                kittyCurrentState = .onTrain
            }
        }
    }
    
    func switchJointL(iWagon :LeftTrain )  {
        
        self.physicsWorld.removeAllJoints()
        
        if let wagonPhysicBody = iWagon.physicsBody , let kittyPhysicBody = kitty.physicsBody {
            
            kitty.position.x  = iWagon.frame.maxX - kitty.size.width / 2
            kitty.position.y  = iWagon.frame.maxY
            
            joint1 = SKPhysicsJointPin.joint(withBodyA: wagonPhysicBody , bodyB: kittyPhysicBody, anchor: CGPoint(x: iWagon.frame.midX, y: iWagon.frame.midY))
            self.physicsWorld.add(joint1)
            score = score + 1
            kittyCurrentState = .onTrain
        }
    }
    
    // Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if kittyCurrentState == .onTrain{
            self.physicsWorld.removeAllJoints()
            kitty.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 60.0))
            let jumpSound = SKAction.playSoundFileNamed("jump.mp3", waitForCompletion: false)
            self.run(jumpSound)
            kittyCurrentState = .onAir
        }
    }
    
    // Init functions to build screen
    
    // HUD
    func createHud()  {
        let hud = SKSpriteNode(color: UIColor.init(red: 0.1, green: 0.5, blue: 0.9, alpha: 0), size: CGSize(width: self.frame.width, height: trainDiffpostion * 2
        ))
        
        hud.anchorPoint = CGPoint(x:0.5, y:0.5)
        hud.position = CGPoint(x:0 , y:self.size.height/2  - hud.size.height/2)
        hud.zPosition=4
        scoreLabel = SKLabelNode(fontNamed: "Avenir")
        scoreLabel.zPosition = 1
        scoreLabel.fontSize = 250
        scoreLabel.text = "0"
        
        scoreLabel.fontColor = UIColor.white
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .center
        hud.addChild(scoreLabel)
        
        kittyCamera.addChild(hud)
        
        Label.createScoreHelper()
        Label.scoreLabelHelper.position = CGPoint(x: self.frame.midX, y: -(hud.size.height/2)+60)
        hud.addChild(Label.scoreLabelHelper)
        
        
        Label.createHighScore()
        Label.highScoreLabel.position = CGPoint(x: self.frame.maxX - 30 , y: 90)
        
        hud.addChild(Label.highScoreLabel)
    }
    
    // Train Track & Grass
    func setupTrackArray()  {
        for i in 0...5 {
            let trainTrack = TrainTrack()
            if i == 5 {
                trainTrack.alpha = 0
            }
            trainTrack.position = getTrainTrackPosition(row : i)
            trainTrack.name = "Track" + String(i)
            self.addChild(trainTrack)
            trainTrackArray.append(trainTrack)
        }
    }
    
    func getTrainTrackPosition( row:Int) -> CGPoint{
        let x = self.frame.minX
        let y = trainYpostion  + trainDiffpostion * CGFloat(row)
        return CGPoint(x: x, y: y)
    }
    
    func setupNewTrack(index: Int, posY: CGFloat) {
        let nodeName = "Track" + String(index)
        self.enumerateChildNodes(withName: nodeName) {
            node, stop in
            node.removeFromParent();
        }
        
        let trainTrack = trainTrackArray[index]
        trainTrack.position.y = posY
        trainTrack.name = nodeName
        self.addChild(trainTrack)
    }
    
    func setupGrassArray() {
        for i in 0...5 {
            let grass = Grass()
            if i == 5 {
                grass.alpha = 0
            }
            grass.position = getGrassPosition(row : i)
            self.addChild(grass)
            grassArray.append(grass)
        }
    }
    
    func getGrassPosition( row:Int) -> CGPoint {
        let x = self.frame.minX
        let y = trainYpostion  + trainDiffpostion * CGFloat(row)  + TrainTrack.getHeight()
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
        
        var posY1:CGFloat = newTrainPosY + 20 + 45
        var posY2:CGFloat = posY1 + trainDiffpostion
        
        for i in 0..<3 {
            if i != 0 {
                posY1 = -1000
                posY2 = -1000
            }
            
            // Right train
            let rightTrain = RightTrain()
            rightTrain.position = CGPoint(x:self.frame.minX + (rightTrain.size.width - 200), y: posY1)
            rightTrain.name = "right" + String(i)
            var wagon = createWagon()
            rightTrain.addChild(wagon)
            self.addChild(rightTrain)
            
            rightTrainArray.append(rightTrain);
            
            // Left train
            let leftTrain = LeftTrain()
            leftTrain.position = CGPoint(x:self.frame.maxX + leftTrain.size.width/2,
                                         y:posY2)
            leftTrain.name = "left" + String(i)
            wagon = createWagon(rightSide: false)
            leftTrain.addChild(wagon)
            self.addChild(leftTrain)
            leftTrainArray.append(leftTrain)
        }
    }
    
    func createWagon(rightSide: Bool = true) -> SKSpriteNode {
        
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
        
        // Locate imate at specified point
        let rightTrain = RightTrain()
        let xPos = rightTrain.size.width/2
        let yPos = rightTrain.size.height/2
        let size = CGSize(width: 110, height: 45)
        wagon.scale(to: size)
        if rightSide{
            wagon.anchorPoint = CGPoint(x:0, y:0)
            wagon.position = CGPoint(x: -xPos, y: -yPos)
        } else {
            wagon.anchorPoint = CGPoint(x:1, y:0)
            wagon.position = CGPoint(x: xPos, y: -yPos)
        }
        wagon.zPosition = 2
        return wagon
    }
    
    // Set the train in motion
    func moveRightWagon2()  {
        
        // Track height: 20 & train height: 45
        let yPostionC :CGFloat = CGFloat(newTrainPosY + 20 + 45)
        let path = CGMutablePath()
        
        newRightTrainIndex += 1
        if newRightTrainIndex > 2 {
            newRightTrainIndex %= 3
        }
        
        let irWagon = rightTrainArray[newRightTrainIndex]
        
        if irWagon.name == "rightTrain1"{
            path.move(to: CGPoint(x: self.frame.minX + irWagon.size.width - 200, y: yPostionC))
        }
        else {
            path.move(to: CGPoint(x: self.frame.minX + irWagon.size.width - 300, y: yPostionC))
        }
        path.addLine(to: CGPoint(x: self.frame.size.width , y: yPostionC))
        
        let followLine = SKAction.follow(path, asOffset: false, orientToPath: false, duration: TimeInterval(randRange(lower: 5, upper: 7)))
        
        irWagon.run(SKAction.repeatForever(followLine))
        
        newTrainPosY += trainDiffpostion
    }
    
    func moveLeftTrain2()  {
        
        // Track height: 20 & train height: 45
        let yPostionC :CGFloat = CGFloat(newTrainPosY + 20 + 45)
        
        newLeftTrainIndex += 1
        if newLeftTrainIndex > 2 {
            newLeftTrainIndex %= 3
        }
        
        let ilTrain = leftTrainArray[newLeftTrainIndex]
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: self.frame.maxX  + ilTrain.size.width/2 , y: yPostionC))
        
        path.addLine(to: CGPoint(x: -self.frame.size.width , y: yPostionC))
        
        let followLine = SKAction.follow(path, asOffset: false, orientToPath: false, duration: TimeInterval(randRange(lower: 5, upper: 7)))
        ilTrain.run(SKAction.repeatForever(followLine))
        
        newTrainPosY += trainDiffpostion
    }
    
    // Contact delegate functions
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask == categoryKitty && secondBody.categoryBitMask == categoryBorder) || (firstBody.categoryBitMask == categoryKitty && secondBody.categoryBitMask == categoryDeadline) {
            
            self.stop()
        }
        
        // Handles left train & creates a right train
        if kittyPostion == .RightTrain {
            
            if firstBody.categoryBitMask == categoryKitty && secondBody.categoryBitMask == categoryTrain{
                
                if (contact.contactPoint.x > (secondBody.node!.frame.maxX - 100)){
                    switchJointL(iWagon:secondBody.node! as! LeftTrain)
                    
                    changeTrackAndGrassInNewLocation()
                    
                    moveRightWagon2()
                    
                    kittyPostion = .LeftTrain
                    
                    // Remove old deadline & add new deadline
                    newDeadlinePosY += trainDiffpostion
                    setNewDeadline()
                    
                    // camera
                    isUpdateCameraPosY = true
                }
                else {
                    stop()
                }
            }
        }
        
        // Handles right train and creates a left train
        if kittyPostion == .LeftTrain {
            if firstBody.categoryBitMask == categoryKitty && secondBody.categoryBitMask == categoryWagon {
                
                if (contact.contactPoint.x < (secondBody.node!.frame.minX + 100)) {
                    
                    switchJoint(iWagon:secondBody.node! as! RightTrain)
                    changeTrackAndGrassInNewLocation()
                    
                    moveLeftTrain2()
                    
                    kittyPostion = .RightTrain
                    
                    // Remove old deadline & add new deadline
                    newDeadlinePosY += trainDiffpostion
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
    
    func setNewDeadline(){
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
        
        let newCurrentTrainPosY = trainTrackArray[lastTrain].position.y + trainDiffpostion
        setupNewTrack(index: currentTrain, posY: newCurrentTrainPosY)
        
        grassArray[currentTrain].position.y = grassArray[lastTrain].position.y + trainDiffpostion
    }
    
    // SKScene functions
    override func didSimulatePhysics() {
        if isUpdateCameraPosY && (kitty.position.y > -100.0){
            grassArray[5].alpha = 1
            trainTrackArray[5].alpha = 1
            
            let action = SKAction.moveTo(y: kitty.position.y + trainDiffpostion, duration: 0.5)
            action.timingMode = .easeInEaseOut
            kittyCamera.run(action)
            
            isUpdateCameraPosY = false
        }
    }
    
    func updateNodesYPosition(){
        let temp: CGFloat = 1000
        var newYPos:CGFloat = 0
        
        // Track & grass
        for i in 0...4 {
            
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
        
        for i in 0..<3 {
            
            // Right train
            rightTrainName = "right" + String(i)
            self.enumerateChildNodes(withName: rightTrainName) {
                node, stop in
                node.removeFromParent();
            }
            rightTrainArray[i].position.y -= temp
            
            self.addChild(rightTrainArray[i])
            
            // Left train
            leftTrainName = "left" + String(i)
            self.enumerateChildNodes(withName: leftTrainName) {
                node, stop in
                node.removeFromParent();
            }
            leftTrainArray[i].position.y -= temp
            self.addChild(leftTrainArray[i])
            newTrainPosY -= temp
        }
    }
    
    override func didMove(to view: SKView) {
        
        if isStart {
            self.physicsWorld.removeAllJoints()
            self.removeAllActions()
            
            self.physicsWorld.contactDelegate = self
            
            // Move the first 2 trains
            newTrainPosY = trainYpostion
            moveRightWagon2()
            moveLeftTrain2()
            
            kitty.position.x = rightTrainArray[0].frame.minX + kitty.size.width / 2
            kitty.position.y = rightTrainArray[0].frame.maxY
            
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
        
        backgroundMusicPlayer.stop()
        
        let stopSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "stop", ofType: "mp3")!)
        do {
            stopSoundPlayer = try AVAudioPlayer(contentsOf: stopSound as URL)
            stopSoundPlayer.numberOfLoops = 1
            stopSoundPlayer.prepareToPlay()
            stopSoundPlayer.play()
        } catch {
            print("Cannot play the file")
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.view!.window!.rootViewController!.performSegue(withIdentifier: "toGameOver", sender: self)
        }
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
