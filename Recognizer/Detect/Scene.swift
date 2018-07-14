//
//  Scene.swift
//  Recognizer
//
//  Created by Chun Kong on 2018/6/16.
//  Copyright © 2018年 chenzhengang. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

class Scene: SKScene {
//    let ghostsLabel = SKLabelNode(text: "Ghosts")
//    let numberOfGhostsLabel = SKLabelNode(text: "0")
    var creationTime : TimeInterval = 0
//    var ghostCount = 0 {
//        didSet{
//            self.numberOfGhostsLabel.text = "\(ghostCount)"
//        }
//    }
    
    let killSound = SKAction.playSoundFileNamed("hit.MP3", waitForCompletion: false)
    
    override func didMove(to view: SKView) {

    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if currentTime > creationTime {
            if (mo==1)
            {
                createGhostAnchor()
            }
            creationTime = currentTime + TimeInterval(randomFloat(min: 1.0, max: 3.0))
        }
    }
    
    //arc4random 返回一个任意整数
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    func createGhostAnchor(){
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // 360度
        let degrees = 2.0 * Float.pi
        
        // 旋转矩阵，x   角度，x,y,z
        let rotateX = simd_float4x4(SCNMatrix4MakeRotation(degrees * randomFloat(min: 0.0, max: 1.0), 1, 0, 0))
        
        // 旋转矩阵，y
        let rotateY = simd_float4x4(SCNMatrix4MakeRotation(degrees * randomFloat(min: 0.0, max: 1.0), 0, 1, 0))
        
        // z摄像前 -1到-2
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1 - randomFloat(min: 0.0, max: 1.0)
        
        // 矩阵乘法 组合
        let transform = simd_mul(simd_mul(rotateX, rotateY), translation)
        
        // 添加锚点
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        // 获取位置
        let location = touch.location(in: self)
        
        // 获取位置处的节点
        let hit = nodes(at: location)
        
        if let node = hit.first {
            // Check if the node is a ghost (remember that labels are also a node)
            if node.name == "hero" {
//            let node2 = node
//            let parent = node.parent!
//            node.removeFromParent()
//            node2.setScale(1.2*node.xScale)
//            parent.addChild(node2)
            }
        }
        //Get the first node (if any)
        
        if let node = hit.first {
            // Check if the node is a ghost (remember that labels are also a node)
            if node.name == "ghost" {
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                let remove = SKAction.removeFromParent()
                let groupKillingActions = SKAction.group([fadeOut, killSound])
                let sequenceAction = SKAction.sequence([groupKillingActions, remove])
                
                let parent = node.parent!
                let node2 = SKSpriteNode(imageNamed: "爆炸")
                let Action = SKAction.fadeOut(withDuration: 0.5)
                node2.run(Action)
                parent.addChild(node2)
                
                node.run(sequenceAction)
                
            }

        }
    }
}
