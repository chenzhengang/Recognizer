//
//  MainViewController.swift
//  Recognizer
//
//  Created by Chun Kong on 2018/6/12.
//  Copyright © 2018年 chenzhengang. All rights reserved.
//

import UIKit
import QuartzCore
import CoreGraphics

class MainViewController: UIViewController,CAAnimationDelegate {

    
    @IBOutlet weak var textExampleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //滑动动画
        textExampleLabel.backgroundColor = UIColor.black // background color -> black
        textExampleLabel.textColor = UIColor.white
        textExampleLabel.text = "滑动开启，滑动开启"
        let testGradient = CAGradientLayer()
        testGradient.frame = self.textExampleLabel.bounds
        testGradient.colors = [UIColor(white: 1.0, alpha: 0.3).cgColor, UIColor.yellow.cgColor, UIColor(white: 1.0, alpha: 0.3).cgColor]
        testGradient.startPoint = CGPoint(x: -0.3, y: 0.5)
        testGradient.endPoint = CGPoint(x: 1.3, y: 0.5)
        testGradient.locations = [0, 0.15, 0.3]

        textExampleLabel.layer.mask = testGradient
        
        //animation
        let testAnimation = CABasicAnimation(keyPath: "locations")
        testAnimation.fromValue = [0, 0.15, 0.3]
        testAnimation.toValue = [1 - 0.3, 1 - 0.15, 1.0];
        testAnimation.repeatCount = 10000
        testAnimation.duration = 1.5
        testAnimation.delegate = self
        testGradient.add(testAnimation, forKey: "TEST")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    private var advertiseView: UIView?
    var adView: UIView? {
        didSet {
            advertiseView = adView!
            advertiseView?.frame = self.view.bounds
            self.view.addSubview(advertiseView!)
            //渐变动画
            UIView.animate(withDuration: 2, animations: { [weak self] in
                self?.advertiseView?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self?.advertiseView?.alpha = 0
            }) { [weak self] (isFinish) in
                self?.advertiseView?.removeFromSuperview()
                self?.advertiseView = nil
            }
        }
    }
}
