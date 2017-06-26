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

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var viewController: UIViewController?
    
    var pastScoreArray = [Int]()
    
    var trainBeforeJump: String?
    
    // MARK: Postion variable
    var isStart = false
    let trainYpostion: CGFloat = -600.0
    let trainDiffpostion: CGFloat = 185.0
    var gamePaused = false
    
    var scoreLabel: SKLabelNode!
    
    enum kittyCurrentTrain {
        case LeftTrain
        case RightTrain
    }
    enum kittyState {
        case onAir
        case onTrain
    }
    
    var kittyCurrentState  = kittyState.onTrain
    var kittyPostion = kittyCurrentTrain.RightTrain
    
    // MARK: Screen sprite variable
    
    var kittyCamera = KCamera()
    
    var trainTrackArray = [TrainTrack] ()
    var grassArray = [Grass] ()
    let deadline = Deadline()
    var newDeadlinePosY:CGFloat = 0
    
    let leftTrain1 =  LeftTrain()
    let rightTrain1 = RightTrain()
    
    var leftTrainArray = [LeftTrain]()
    var newLeftTrainIndex = -1
    
    var rightTrainArray = [RightTrain]()
    var newRightTrainIndex = -1
    
    var beforeColorIndex = -1
    
    var newTrainPosY:CGFloat = -600.0
    
    let kitty = Kitty()
    
    var joint1 : SKPhysicsJointPin!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    var highScore: Int = 0 {
        didSet {
            Label.highScoreLabel.text = "High Score: \(SharingManager.sharedInstance.highScore)"
        }
    }
    
    // MARK: Init functions
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
        self.physicsBody?.categoryBitMask = category_border
        
        beforeColorIndex = [0, 1, 2].randomItem()
        
        trackArraySetup()
        grassArraySetup()
        
        newDeadlinePosY = trainYpostion + trainDiffpostion + 160
        deadlineSetup()
        
        setupFirstSixRightAndLeftTrains()
        createHud()
        
        kitty.position.x  = rightTrainArray[0].frame.minX + kitty.size.width / 2
        kitty.position.y  = rightTrainArray[0].frame.maxY
        
        self.addChild(kitty)
        
        joint1 = SKPhysicsJointPin.joint(withBodyA: rightTrainArray[0].physicsBody! , bodyB: kitty.physicsBody!, anchor: CGPoint(x: self.rightTrainArray[0].frame.minX, y: self.rightTrainArray[0].frame.midY))
        self.physicsWorld.add(joint1)
        
    }
    // MARK: Movement
    
    // Called when a touch begins
    func switchJoint(iWagon :RightTrain )  {
        
        if let jointN = joint1 {
            
            self.physicsWorld.remove(jointN)
            
            if let wagonPhysicBody = iWagon.physicsBody , let kittyPhysicBody = kitty.physicsBody {
                
                kitty.position.x  = iWagon.frame.minX + kitty.size.width / 2
                kitty.position.y  = iWagon.frame.maxY
                
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
    
    // MARK: Touches
    override func  touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if kittyCurrentState == .onTrain{
            self.physicsWorld.removeAllJoints()
            kitty.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 60.0))
            kittyCurrentState = .onAir
        }
    }
    
    func locationDetectR(train:RightTrain, location:CGPoint) {
        if (location.x < (train.frame.minX + 100)) {
            
            switchJoint(iWagon:train)
            if (train.name == "rightTrain3"){
                showStop(reason : "GameOver!")
            }
        }
        else {
            showStop(reason :"Game Over!")
        }
    }
    
    func locationDetectL(train:LeftTrain, location:CGPoint) {
        
        if (location.x > (train.frame.maxX - 100)){
            switchJointL(iWagon:train)
        }
        else {
            showStop(reason :"Game Over!")
        }
    }
    
    // MARK: Init functions to build screen
    
    // MARK: HUD
    func createHud()  {
        let hud = SKSpriteNode(color: UIColor.init(red: 0.1, green: 0.5, blue: 0.9, alpha: 0), size: CGSize(width: self.frame.width, height: trainDiffpostion * 2
        ))
        hud.anchorPoint=CGPoint(x:0.5, y:0.5)
        hud.position = CGPoint(x:0 , y:self.size.height/2  - hud.size.height/2)
        hud.zPosition=4
        scoreLabel = SKLabelNode(fontNamed: "Avenir")
        scoreLabel.zPosition = 1
        scoreLabel.fontSize=250
        scoreLabel.text = "0"
        
        scoreLabel.fontColor=UIColor.white
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
    
    // MARK: Train Track & Grass
    func trackArraySetup()  {
        
        for i in 0...4 {
            let trainTrack = TrainTrack()
            trainTrack.position = getTrainTrackPosition(row : i)
            trainTrack.name = "Track" + String(i)
            self.addChild(trainTrack)
            trainTrackArray.append(trainTrack)
        }
    }
    
    func newTrackSetup(index: Int, posY: CGFloat) {
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
    
    func getTrainTrackPosition( row:Int) -> CGPoint {
        let x = self.frame.minX
        let y = trainYpostion + trainDiffpostion * CGFloat(row)
        return CGPoint(x: x, y: y)
    }
    
    func grassArraySetup()  {
        
        for i in 0...4 {
            let grass = Grass()
            grass.position = getGrassPosition(row : i)
            self.addChild(grass)
            grassArray.append(grass)
        }
    }
    
    func getGrassPosition( row:Int) -> CGPoint{
        
        let x = self.frame.minX
        let y = trainYpostion  + trainDiffpostion * CGFloat(row)  + TrainTrack.getHeight()
        return CGPoint(x: x, y: y)
    }
    
    func deadlineSetup(){
        deadline.position = getDeadlinePosition(posY: newDeadlinePosY)
        self.addChild(deadline)
    }
    
    func getDeadlinePosition(posY: CGFloat) -> CGPoint{
        let x = self.frame.minX
        return CGPoint(x: x, y: posY)
    }
    
    func rightTrainSetup() {
        let  htrainWidth = rightTrain1.size.width
        let  trackHeight = TrainTrack.getHeight()
        
        rightTrain1.position = CGPoint(x: self.frame.minX + (htrainWidth-200) , y:trainTrackArray[0].position.y  + trackHeight )
        rightTrain1.name = "rightTrain1"
        self.addChild(rightTrain1)
    }
    
    func leftTrainSetup()  {
        
        leftTrain1.position = CGPoint(x: self.frame.maxX + leftTrain1.size.width/2 , y:trainTrackArray[1].position.y + TrainTrack.getHeight())
        leftTrain1.name = "leftTrain1"
        self.addChild(leftTrain1)
    }
    
    func setupFirstSixRightAndLeftTrains() {
        
        for i in 0..<3{
            let rightTrain = RightTrain()
            rightTrain.position = CGPoint(x:self.frame.minX + (rightTrain.size.width - 200), y: -1000)
            
            rightTrain.name = "right" + String(i)
            var wagon = selectColorImage()
            rightTrain.addChild(wagon)
            
            self.addChild(rightTrain)
            rightTrainArray.append(rightTrain);
            
            newTrainPosY += trainDiffpostion
            
            let leftTrain = LeftTrain()
            leftTrain.position = CGPoint(x:self.frame.maxX + leftTrain.size.width/2,
                                         y:-1000)
            leftTrain.name = "left" + String(i)
            
            wagon = selectColorImage(rightSide: false)
            leftTrain.addChild(wagon)
            
            self.addChild(leftTrain)
            leftTrainArray.append(leftTrain)
            newTrainPosY += trainDiffpostion
        }
    }
    
    func selectColorImage(rightSide: Bool = true) -> SKSpriteNode{
        // Get random one color except the color before
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
        
        // Locate imate at the specified point
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
    
    // MARK: Set the train on motion
    
    func moveRightWagon(irWagon:RightTrain, itrack:TrainTrack)  {
        
        let yPostionC :CGFloat = itrack.position.y + itrack.size.height + irWagon.size.height/2
        let path = CGMutablePath()
        
        if  irWagon.name == "rightTrain1"{
            path.move(to: CGPoint(x: self.frame.minX + irWagon.size.width - 200, y: yPostionC))
        }
        else {
            path.move(to: CGPoint(x: self.frame.minX + irWagon.size.width - 300, y: yPostionC))
        }
        path.addLine(to: CGPoint(x: self.frame.size.width , y: yPostionC))
        
        let followLine = SKAction.follow(path, asOffset: false, orientToPath: false, duration: TimeInterval(randRange(lower: 10, upper: 11)))
        
        irWagon.run(followLine)
    }
    
    func moveRightWagon2()  {
        
        // Track height: 20
        // Train height: 45
        let yPostionC :CGFloat = CGFloat(newTrainPosY + 20 + 45)
        let path = CGMutablePath()
        
        newRightTrainIndex += 1
        if newRightTrainIndex > 2{
            newRightTrainIndex %= 3
        }
        
        let irWagon = rightTrainArray[newRightTrainIndex]
        
        if  irWagon.name == "rightTrain1"{
            path.move(to: CGPoint(x: self.frame.minX + irWagon.size.width - 200, y: yPostionC))
            
        }
        else {
            path.move(to: CGPoint(x: self.frame.minX + irWagon.size.width - 300, y: yPostionC))
        }
        
        path.addLine(to: CGPoint(x: self.frame.size.width , y: yPostionC))
        
        let followLine = SKAction.follow(path, asOffset: false, orientToPath: false, duration: TimeInterval(randRange(lower: 8, upper: 9)))
        
        irWagon.run(SKAction.repeatForever(followLine))
        
        newTrainPosY += trainDiffpostion
    }
    
    func moveLeftTrain(ilTrain:LeftTrain, itrack:TrainTrack)  {
        
        let yPostionC :CGFloat = itrack.position.y  + itrack.size.height + ilTrain.size.height/2
        let path = CGMutablePath()
        path.move(to: CGPoint(x: self.frame.maxX  + ilTrain.size.width/2 , y: yPostionC))
        path.addLine(to: CGPoint(x: -self.frame.size.width , y: yPostionC))
        let followLine = SKAction.follow(path, asOffset: false, orientToPath: false, duration: TimeInterval(randRange(lower: 10, upper: 11)))
        ilTrain.run(followLine)
    }
    
    func moveLeftTrain2()  {
        
        // Track height: 20
        // Train height: 45
        let yPostionC :CGFloat = CGFloat(newTrainPosY + 20 + 45)
        
        newLeftTrainIndex += 1
        if newLeftTrainIndex > 2{
            newLeftTrainIndex %= 3
        }
        
        let ilTrain = leftTrainArray[newLeftTrainIndex]
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: self.frame.maxX  + ilTrain.size.width/2 , y: yPostionC))
        
        path.addLine(to: CGPoint(x: -self.frame.size.width , y: yPostionC))
        
        let followLine = SKAction.follow(path, asOffset: false, orientToPath: false, duration: TimeInterval(randRange(lower: 6, upper: 8)))
        ilTrain.run(SKAction.repeatForever(followLine))
        
        newTrainPosY += trainDiffpostion
    }
    
    // MARK: Contact delegate functions
    
    var currentTrain: Int = 1
    
    func didBegin(_ contact: SKPhysicsContact) {
        
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
        
        if (firstBody.categoryBitMask == category_kitty && secondBody.categoryBitMask == category_border) || (firstBody.categoryBitMask == category_kitty && secondBody.categoryBitMask == category_deadline) {
            showStop(reason:"Game Over!")
        }
        
        // Handles left train & creates a right train (first call)
        if kittyPostion == .RightTrain {
            
            if firstBody.categoryBitMask == category_kitty && secondBody.categoryBitMask == categoryTrain {
                
                if (contact.contactPoint.x > (secondBody.node!.frame.maxX - 100)) {
                    switchJointL(iWagon:secondBody.node! as! LeftTrain)
                    
                    changeTrackAndGrassInNewLocation()
                    
                    moveRightWagon2()
                    
                    kittyPostion = .LeftTrain
                    
                    // Remove old deadline & add new deadline
                    newDeadlinePosY += trainDiffpostion
                    setNewDeadline()
                }
                else {
                    showStop(reason :"Game Over!")
                }
            }
        }
        
        // Handles right train and creates a left train - first call
        if kittyPostion == .LeftTrain {
            if firstBody.categoryBitMask == category_kitty && secondBody.categoryBitMask == category_wagon {
                
                if (contact.contactPoint.x < (secondBody.node!.frame.minX + 100)) {
                    
                    switchJoint(iWagon:secondBody.node! as! RightTrain)
                    changeTrackAndGrassInNewLocation()
                    
                    moveLeftTrain2()
                    
                    kittyPostion = .RightTrain
                    
                    // Remove old deadline & add new deadline
                    newDeadlinePosY += trainDiffpostion
                    setNewDeadline()
                }
                else {
                    showStop(reason :"Game Over!")
                }
            }
        }
    }
    
    func setNewDeadline() {
        self.enumerateChildNodes(withName: "Deadline") {
            node, stop in
            node.removeFromParent();
        }
        deadlineSetup()
    }
    
    func changeTrackAndGrassInNewLocation() {
        let lastTrain = currentTrain
        currentTrain += 1
        if currentTrain > 4{
            currentTrain %= 5
        }
        
        let newCurrentTrainPosY = trainTrackArray[lastTrain].position.y + trainDiffpostion
        newTrackSetup(index: currentTrain, posY: newCurrentTrainPosY)
        
        grassArray[currentTrain].position.y = grassArray[lastTrain].position.y + trainDiffpostion
    }
    
    // MARK: SKScene functions
    
    override func update(_ currentTime: TimeInterval) {
        kittyCamera.position.y = -kitty.position.y
    }
    
    func updateNodesYPosition(){
        let temp: CGFloat = 1000
        var newYPos:CGFloat = 0
        
        // Track and grass
        for i in 0...4 {
            
            // Track
            newYPos = trainTrackArray[i].position.y - temp
            newTrackSetup(index: i, posY: newYPos)
            
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
            
            // Train on right
            rightTrainName = "right" + String(i)
            self.enumerateChildNodes(withName: rightTrainName) {
                node, stop in
                node.removeFromParent();
            }
            
            rightTrainArray[i].position.y -= temp
            
            self.addChild(rightTrainArray[i])
            
            // Train on left
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
            self.physicsWorld.contactDelegate = self
            
            kittyCamera.kitty  = kitty
            kittyCamera.createCamera(kitty: kitty, frameMax: self.frame.maxY)
            addChild(kittyCamera)
            self.camera = kittyCamera
            
            // Move the first 6 trains
            newTrainPosY = trainYpostion
            moveRightWagon2()
            moveLeftTrain2()
        }
    }
    
    func showStop(reason:String) {
        
        if score >  SharingManager.sharedInstance.highScore {
            SharingManager.sharedInstance.highScore = score
        }
        
        SharingManager.sharedInstance.currentScore = score
        
        self.gamePaused = true
        
        self.physicsWorld.removeAllJoints()
        self.removeAllActions()
        self.isPaused = true
        
        self.view!.window!.rootViewController!.performSegue(withIdentifier: "toGameOver", sender: self)
    }
    
    func randRange (lower: Int , upper: Int) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
}

extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
