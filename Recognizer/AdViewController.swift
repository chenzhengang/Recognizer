//
//  AdViewController.swift
//  Recognizer
//
//  Created by Chun Kong on 2018/6/14.
//  Copyright © 2018年 chenzhengang. All rights reserved.
//

import UIKit

class AdViewController: UIViewController {

    // 用于 AdViewController 销毁后的回调
    var completion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("Ad")
        
        let viewBounds:CGRect = UIScreen.main.bounds
        
        self.view.backgroundColor = #colorLiteral(red: 0.7280698614, green: 0.9076298398, blue: 1, alpha: 1)
        
        let imageView1 = UIImageView(image:UIImage(named:"相机"))
        imageView1.frame = CGRect(x:viewBounds.width/2-50,y:0,width:100,height:80);
        self.view.addSubview(imageView1)
        
        let imageView2 = UIImageView(image:UIImage(named:"放大镜"))
        imageView2.frame = CGRect(x:viewBounds.width/2-50,y:viewBounds.height,width:100,height:100);
        self.view.addSubview(imageView2)
        
        
        UIView.animate(withDuration: 2, animations: {
            self.view.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
            imageView1.frame = CGRect(x:viewBounds.width/2-50,y:viewBounds.height/2,width:100,height:80)
            imageView2.frame = CGRect(x:viewBounds.width/2-50,y:viewBounds.height/2,width:100,height:100);
        }, completion: { _ in
            imageView1.removeFromSuperview()
            imageView2.removeFromSuperview()
        })
        
        //延迟
        let time: TimeInterval = 1.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
            self.dismissAdView()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func dismissAdView() {
        self.view.removeFromSuperview()
        //print("完成")
        self.completion?()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


