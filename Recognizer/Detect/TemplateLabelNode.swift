//
//  LabelNode.swift
//  Recognizer
//
//  Created by Chun Kong on 2018/6/13.
//  Copyright © 2018年 chenzhengang. All rights reserved.
//

import SpriteKit

/// - Tag: TemplateLabelNode
class TemplateLabelNode: SKReferenceNode {
    
    private let text: String
    //var fontsize: CGFloat
    
    init(text: String) {
        self.text = text
        //self.fontsize = fontsize
        // Force call to designated init(fileNamed: String?), not convenience init(fileNamed: String)
        super.init(fileNamed: Optional.some("LabelScene"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didLoad(_ node: SKNode?) {
        // Apply text to both labels loaded from the template.
        guard let parent = node?.childNode(withName: "LabelNode") else {
            fatalError("misconfigured SpriteKit template file")
        }
        for case let label as SKLabelNode in parent.children {
            label.name = text
            label.text = text
            //label.fontSize = self.fontsize
        }
    }
}

