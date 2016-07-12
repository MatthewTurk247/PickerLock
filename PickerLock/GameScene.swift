//
//  GameScene.swift
//  PickerLock
//
//  Created by Matthew Turk on 7/9/16.
//  Copyright (c) 2016 Turk. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var Circle = SKSpriteNode()
    var Person = SKSpriteNode()
    var Dot = SKSpriteNode()
    var Path = UIBezierPath()
    
    var LevelLabel = UILabel()
    var currentLevel = Int()
    var currentScore = Int()
    var highLevel = Int()
    
    var gameStarted = Bool()
    var movingClockWise = Bool()
    var intersected = false
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        loadView()
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.integerForKey("HighLevel") != 0 {
            highLevel = defaults.integerForKey("HighLevel") as Int!
            currentLevel = highLevel
            currentScore = currentLevel
            LevelLabel.text = "\(currentScore)"
        } else {
            defaults.setInteger(1, forKey: "HighLevel")
        }
    }
    
    func loadView() {
        self.view?.backgroundColor = UIColor.whiteColor()
        movingClockWise = true
        Circle = SKSpriteNode(imageNamed: "Circle")
        Circle.size = CGSize(width: 300, height: 300)
        Circle.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(Circle)
        Person = SKSpriteNode(imageNamed: "Person")
        Person.size = CGSize(width: 40, height: 7)
        Person.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + 112)
        Person.zRotation = 3.14 / 2
        Person.zPosition = Circle.zPosition + 2
        self.addChild(Person)
        addDot()
        LevelLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 100))
        LevelLabel.center = (self.view?.center)!
        LevelLabel.text = "\(currentScore)"
        LevelLabel.textAlignment = NSTextAlignment.Center
        LevelLabel.font = UIFont.systemFontOfSize(60)
        LevelLabel.textColor = SKColor.darkGrayColor()
        self.view?.addSubview(LevelLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        if gameStarted == false {
            moveClockWise()
            movingClockWise = true
            gameStarted = true
        } else if gameStarted == true {
            if movingClockWise == true {
                moveCounterClockWise()
                movingClockWise = false
            } else if movingClockWise == false {
                moveClockWise()
                movingClockWise = true
            }
            DotTouched()
        }
    }
   
    func moveClockWise() {
        let dx = Person.position.x - self.frame.width / 2
        let dy = Person.position.y - self.frame.height / 2
        let rad = atan2(dy, dx)
        Path = UIBezierPath(arcCenter: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2), radius: 120, startAngle: rad, endAngle: rad + CGFloat(M_PI * 4), clockwise: true)
        let follow = SKAction.followPath(Path.CGPath, asOffset: false, orientToPath: true, speed: 200)
        Person.runAction(SKAction.repeatActionForever(follow).reversedAction())
    }
    
    func moveCounterClockWise() {
        let dx = Person.position.x - self.frame.width / 2
        let dy = Person.position.y - self.frame.height / 2
        let rad = atan2(dy, dx)
        Path = UIBezierPath(arcCenter: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2), radius: 120, startAngle: rad, endAngle: rad + CGFloat(M_PI * 4), clockwise: true)
        let follow = SKAction.followPath(Path.CGPath, asOffset: false, orientToPath: true, speed: 200)
        Person.runAction(SKAction.repeatActionForever(follow))
    }
    
    
    func addDot() {
        Dot = SKSpriteNode(imageNamed: "Dot")
        Dot.size = CGSize(width: 30, height: 30)
        Dot.zPosition = Circle.zPosition + 1
        let dx = Person.position.x - self.frame.width / 2
        let dy = Person.position.y - self.frame.height / 2
        let rad = atan2(dy, dx)
        
        if movingClockWise == true {
            let tempAngle = CGFloat.random(min: rad - 1.0, max: rad - 2.5)
            let Path2 = UIBezierPath(arcCenter: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2), radius: 120, startAngle: tempAngle, endAngle: tempAngle + CGFloat(M_PI * 4), clockwise: true)
            Dot.position = Path2.currentPoint
        } else if movingClockWise == false {
            let tempAngle = CGFloat.random(min: rad + 1.0, max: rad + 2.5)
            let Path2 = UIBezierPath(arcCenter: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2), radius: 120, startAngle: tempAngle, endAngle: tempAngle + CGFloat(M_PI * 4), clockwise: true)
            Dot.position = Path2.currentPoint
        }
        self.addChild(Dot)
    }
    
    func DotTouched() {
        if intersected == true {
            Dot.removeFromParent()
            addDot()
            intersected = false
            currentScore--
            LevelLabel.text = "\(currentScore)"
            if currentScore <= 0 {
                nextLevel()
            }
        } else if intersected == false {
            died()
        }
    }
    
    func nextLevel() {
        currentLevel++
        currentScore = currentLevel
        LevelLabel.text = "\(currentScore)"
        won()
        if currentLevel > highLevel {
            highLevel = currentLevel
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setInteger(highLevel, forKey: "HighLevel")
        }
    }
    
    func died() {
        self.removeAllChildren()
        let action1 = SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 1.0, duration: 0.2)
        let action2 = SKAction.colorizeWithColor(UIColor.whiteColor(), colorBlendFactor: 1.0, duration: 0.2)
        //self.scene?.runAction(SKAction.sequence([action1, action2])
        self.scene?.runAction(SKAction.sequence([action1, action2]))
        intersected = false
        gameStarted = false
        currentScore = currentLevel
        LevelLabel.removeFromSuperview()
        self.loadView()
    }
    
    func won() {
    self.removeAllChildren()
    let action1 = SKAction.colorizeWithColor(UIColor.greenColor(), colorBlendFactor: 1.0, duration: 0.2)
    let action2 = SKAction.colorizeWithColor(UIColor.whiteColor(), colorBlendFactor: 1.0, duration: 0.2)
    //self.scene?.runAction(SKAction.sequence([action1, action2])
    self.scene?.runAction(SKAction.sequence([action1, action2]))
    intersected = false
    gameStarted = false
    LevelLabel.removeFromSuperview()
    self.loadView()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if Person.intersectsNode(Dot) {
            intersected = true
        } else {
            if intersected == true {
                if Person.intersectsNode(Dot) == false {
                    
                    died()
                }
            }
        }
    }
}