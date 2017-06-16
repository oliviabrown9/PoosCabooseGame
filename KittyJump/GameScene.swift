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
    
    // MARK: postion variable
    let trainYpostion:CGFloat    = -600.0
    let trainDiffpostion:CGFloat = 185.0
    var gamePaused = false
    
    var scoreLabel :SKLabelNode!
    
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
    // MARK: screen sprite variable
    
    var kittyCamera = KCamera()

    var trainTrackArray = [TrainTrack] ()
    var grassArray = [Grass] ()

    
    let leftTrain1 =  LeftTrain()
    let rightTrain1 = RightTrain()
    
    let kitty = Kitty()
 
    var joint1 : SKPhysicsJointPin!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
            if score ==  50 {
                showStop(reason: "Game Won")
            }
            
        }
    }
    
    var highScore: Int = 0 {
        didSet {
            Label.highScoreLabel.text = "High Score : \(SharingManager.sharedInstance.highScore)"
        }
    }
    
    // MARK: Init functions

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
   
        trackSetup()
        grassSetup()

        leftTrainSetup()
        rightTrainSetup()
        createHud()

        kitty.position.x  = rightTrain1.frame.minX + kitty.size.width / 2
        kitty.position.y  = rightTrain1.frame.maxY

        self.addChild(kitty)
 
        
        joint1 = SKPhysicsJointPin.joint(withBodyA: rightTrain1.physicsBody! , bodyB: kitty.physicsBody!, anchor: CGPoint(x: self.rightTrain1.frame.minX, y: self.rightTrain1.frame.midY))
        self.physicsWorld.add(joint1)


        
    }
    // MARK:    functions to make actors move
    
    //track position setup

    
    /* Called when a touch begins */
    
    func switchJoint(iWagon :RightTrain )  {
        
        if let trainBeforeJump  = joint1.bodyA.node , let jointN = joint1 {
       
        self.physicsWorld.remove(jointN)
        
        trainBeforeJump.removeAllActions()
        
        if let wagonPhysicBody = iWagon.physicsBody , let kittyPhysicBody = kitty.physicsBody {
            
            kitty.position.x  = iWagon.frame.minX + kitty.size.width / 2
            kitty.position.y  = iWagon.frame.maxY

            joint1 = SKPhysicsJointPin.joint(withBodyA: wagonPhysicBody , bodyB: kittyPhysicBody, anchor: CGPoint(x: iWagon.frame.minX, y: iWagon.frame.midY))
            self.physicsWorld.add(joint1)
            score = score + 1
            kittyCurrentState =
 .onTrain
            }
        }
    }
    
    func switchJointL(iWagon :LeftTrain )  {
        
        let trainBeforeJump  = joint1.bodyA.node
        
        self.physicsWorld.removeAllJoints()
        
        trainBeforeJump?.removeAllActions()
        
         if let wagonPhysicBody = iWagon.physicsBody , let kittyPhysicBody = kitty.physicsBody {
            
            kitty.position.x  = iWagon.frame.maxX - kitty.size.width / 2
            kitty.position.y  = iWagon.frame.maxY
            
            joint1 = SKPhysicsJointPin.joint(withBodyA: wagonPhysicBody , bodyB: kittyPhysicBody, anchor: CGPoint(x: iWagon.frame.midX, y: iWagon.frame.midY))
            self.physicsWorld.add(joint1)
            score = score + 1
            kittyCurrentState =
                .onTrain
        }
    }

    // MARK:- Touches


    override func  touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        

        for touch: UITouch in touches {
            
            let location = touch.location(in: self)
            let node = self.atPoint(location)
 
             if let touchNode = node.name {
                
                switch touchNode {
                case "Kitty":
                    if kittyCurrentState == .onTrain{
                        self.physicsWorld.removeAllJoints()
                        kitty.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 60.0))
                        kittyCurrentState = .onAir
                    }
                    
                default:
               
                    break
                    
                }
            }
            
        }
        
    }
    
    func locationDetectR(train:RightTrain, location:CGPoint) {
        if (location.x < (train.frame.minX + 100)){
            
            switchJoint(iWagon:train)
            if (train.name == "rightTrain3"){
                showStop(reason : "Score 100!")
            }
            
        }else{
            showStop(reason :"Game Over! ")
            
        }
        
    }
    func locationDetectL(train:LeftTrain, location:CGPoint) {
        
        if (location.x > (train.frame.maxX - 100)){
            
            switchJointL(iWagon:train)
        }else{
            showStop(reason :"Game Over! ")
            
        }
    }
    
     // MARK:- Init  functions to build screen
   
    // MARK: HUD
    func createHud()  {
        let hud = SKSpriteNode(color: UIColor.init(red: 0.1, green: 0.5, blue: 0.9, alpha: 0), size: CGSize(width: self.frame.width, height: trainDiffpostion * 2
        ))
        hud.anchorPoint=CGPoint(x:0.5, y:0.5)
        hud.position = CGPoint(x:0 , y:self.size.height/2  - hud.size.height/2)
        hud.zPosition=4
        scoreLabel = SKLabelNode(fontNamed: "Arial")
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
        Label.highScoreLabel.position = CGPoint(x: self.frame.maxX - 50 , y: -25)

          hud.addChild(Label.highScoreLabel)
        
        
    }
    // MARK: TrainTrack & Grass
    
    func trackSetup()  {
  
        for i in 0...49 {
            
            let trainTrack = TrainTrack()
            trainTrack.position = getTrainTrackPosition(row : i)
            self.addChild(trainTrack)
            trainTrackArray.append(trainTrack)
            
            if ( i > 4 ){
                
                trainTrack.alpha = 0
            }
        }
    }
    
    func getTrainTrackPosition( row:Int) -> CGPoint{

        let x = self.frame.minX
        let y = trainYpostion  + trainDiffpostion * CGFloat(row)
        return CGPoint(x: x, y: y)
    }
    
    func grassSetup()  {
        
        for i in 0...49 {
            let grass = Grass()
            grass.position = getGrassPosition(row : i)
            self.addChild(grass)
            grassArray.append(grass)

            if ( i > 4 ){
                
                grass.alpha = 0
            }
        }
    }
    
    func getGrassPosition( row:Int) -> CGPoint{
        
        let x = self.frame.minX
        let y = trainYpostion  + trainDiffpostion * CGFloat(row)  + TrainTrack.getHeight()
        return CGPoint(x: x, y: y)
    }
    
    
    func leftTrainSetup()  {
        
        //second train from  down
        leftTrain1.position = CGPoint(x: self.frame.maxX + leftTrain1.size.width/2 , y:trainTrackArray[1].position.y  + TrainTrack.getHeight())
        leftTrain1.name = "leftTrain1"
        self.addChild(leftTrain1)
        
    }
    
    func rightTrainSetup()  {
        
        let  htrainWidth = rightTrain1.size.width
        let  trackHeight = TrainTrack.getHeight()
        
        rightTrain1.position = CGPoint(x: self.frame.minX + (htrainWidth-200) , y:trainTrackArray[0].position.y  + trackHeight )
        rightTrain1.name = "rightTrain1"
        self.addChild(rightTrain1)
        
    }
    
    // MARK:- Set the train on motion

    
    func moveRightWagon(irWagon:RightTrain, itrack:TrainTrack)  {
        
        let yPostionC :CGFloat = itrack.position.y  + itrack.size.height + irWagon.size.height/2
        let path = CGMutablePath()
        
        if  irWagon.name == "rightTrain1"{
            path.move(to: CGPoint(x: self.frame.minX + irWagon.size.width - 200, y: yPostionC))
            
        }else{
            path.move(to: CGPoint(x: self.frame.minX + irWagon.size.width - 300, y: yPostionC))
            
        }
        path.addLine(to: CGPoint(x: self.frame.size.width , y: yPostionC))
        let followLine = SKAction.follow(path, asOffset: false, orientToPath: false, duration: TimeInterval(randRange(lower: 10, upper: 11)))
        
         irWagon.run (followLine)
        
    }
    
    func moveLeftTrain(ilTrain:LeftTrain, itrack:TrainTrack)  {
        
        let yPostionC :CGFloat = itrack.position.y  + itrack.size.height + ilTrain.size.height/2
        let path = CGMutablePath()
        path.move(to: CGPoint(x: self.frame.maxX  + ilTrain.size.width/2 , y: yPostionC))
        path.addLine(to: CGPoint(x: -self.frame.size.width , y: yPostionC))
        let followLine = SKAction.follow(path, asOffset: false, orientToPath: false, duration: TimeInterval(randRange(lower: 10, upper: 11)))
        ilTrain.run(followLine)
    }
    
    // MARK:- Contact Delegate  functions

    var currentTrain :Int = 1
    
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
        
 
 
        if firstBody.categoryBitMask == category_kitty && secondBody.categoryBitMask == category_border {
           // print("Kitty hit border. First contact has been made.")
            showStop(reason:"Game Over! ")
            
        }
        // handles  left train and creates a right train - first call
        if kittyPostion ==  .RightTrain {
            if firstBody.categoryBitMask == category_kitty   && secondBody.categoryBitMask == category_train{
                if (contact.contactPoint.x > (secondBody.node!.frame.maxX - 100)){
                    
                    print ("success left")
                    switchJointL(iWagon:secondBody.node! as! LeftTrain)
                    currentTrain += 1
                    trainTrackArray[currentTrain].alpha=1
                    grassArray[currentTrain].alpha=1
                     moveRightWagon(irWagon: rightTrain1, itrack:trainTrackArray[ currentTrain ])
                    kittyPostion = .LeftTrain
                }else{
                    
                    print ("failure left")
                    showStop(reason :"Game Over! ")
                }
            }
        }
        // handles  right train and creates a left train - first call

        if kittyPostion ==  .LeftTrain {
            if firstBody.categoryBitMask == category_kitty   && secondBody.categoryBitMask == category_wagon{
                
                if (contact.contactPoint.x < (secondBody.node!.frame.minX + 100)){
                    
                    print ("success right")
                    switchJoint(iWagon:secondBody.node! as! RightTrain)
                    currentTrain += 1
                    trainTrackArray[currentTrain].alpha=1
                    grassArray[currentTrain].alpha=1
                    moveLeftTrain(ilTrain: leftTrain1, itrack: trainTrackArray[currentTrain])
                    kittyPostion = .RightTrain

                }else{
                    
                    print ("failure right")
                    showStop(reason :"Game Over! ")
                    
                }
            }
        }
    }
    
    //MARK: - SKScene functions
    
    override func update(_ currentTime: TimeInterval) {
        kittyCamera.position.y = -kitty.position.y
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self

        kittyCamera.kitty  = kitty
        kittyCamera.createCamera(kitty: kitty, frameMax: self.frame.maxY)
        addChild(kittyCamera)
        self.camera = kittyCamera
     
        //code to move the first two train
        moveRightWagon(irWagon: rightTrain1, itrack:trainTrackArray[0] )
        moveLeftTrain(ilTrain: leftTrain1, itrack: trainTrackArray[1])
    }
    
    func showStop(reason:String) {
        
        if score >  SharingManager.sharedInstance.highScore {
            SharingManager.sharedInstance.highScore = score
        }
        self.gamePaused = true
        let attributedString = NSAttributedString(string: reason + "Play again?", attributes: [
            NSFontAttributeName : UIFont(name: "Copperplate", size: 25.0),
            NSForegroundColorAttributeName : UIColor.init(red: 255, green: 0, blue: 0, alpha: 0.8)
            ])
        let alert = UIAlertController(title: "" , message:  "", preferredStyle: UIAlertControllerStyle.alert)
            alert.setValue(attributedString, forKey: "attributedTitle")

           alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default)  { _ in
            self.isPaused = false

            let transition = SKTransition.doorsCloseHorizontal(withDuration: 1)
            if let scene = SKScene(fileNamed: "GameScene") {
                
                 scene.scaleMode = .aspectFill
                self.view?.presentScene(scene,transition: transition)
            }
        })

        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        self.physicsWorld.removeAllJoints()
        self.removeAllActions()
        self.isPaused = true
        
    }
    
    func randRange (lower: Int , upper: Int) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }

}


