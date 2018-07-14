//
//  StatusViewController.swift
//  Recognizer
//
//  Created by Chun Kong on 2018/6/12.
//  Copyright © 2018年 chenzhengang. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import Vision

class StatusViewController: UIViewController {
    
    enum MessageType {
        case trackingStateEscalation
        case planeEstimation
        case contentPlacement
        case focusSquare
        
        static var all: [MessageType] = [
            .trackingStateEscalation,
            .planeEstimation,
            .contentPlacement,
            .focusSquare
        ]
    }

    // MARK: - IBOutlets
    
    @IBOutlet weak var Panel: UIVisualEffectView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Panel.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: - Actions
    
    func changetext(string :String) {
        messageLabel.text = string
    }
    
    // MARK: - Properties
    
    var restartExperienceHandler: () -> Void = {}
    private let displayDuration: TimeInterval = 6
    private var messageHideTimer: Timer?
    private var timers: [MessageType: Timer] = [:]
    
    // MARK: - Message Handling
    
    func showMessage(_ text: String, autoHide: Bool = true) {
        messageHideTimer?.invalidate()
        
        messageLabel.text = text
        
        //显示框
        setMessageHidden(false, animated: true)
        
        if autoHide {
            messageHideTimer = Timer.scheduledTimer(withTimeInterval: displayDuration, repeats: false, block: { [weak self] _ in
                self?.setMessageHidden(true, animated: true)
            })
        }
    }
    
    func cancelScheduledMessage(`for` messageType: MessageType) {
        timers[messageType]?.invalidate()
        timers[messageType] = nil
    }
    
    func cancelAllScheduledMessages() {
        for messageType in MessageType.all {
            cancelScheduledMessage(for: messageType)
        }
    }
    
    func scheduleMessage(_ text: String, inSeconds seconds: TimeInterval, messageType: MessageType) {
        cancelScheduledMessage(for: messageType)
        
        let timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { [weak self] timer in
            self?.showMessage(text)
            timer.invalidate()
        })
        
        timers[messageType] = timer
    }
    
    // MARK: - IBActions
    

    @IBAction func restart(_ sender: UIButton) {
        restartExperienceHandler()
    }
    
    // MARK: - Panel Visibility
    
    private func setMessageHidden(_ hide: Bool, animated: Bool) {
        // 隐藏指示窗
        Panel.isHidden = false
        
        guard animated else {
            Panel.alpha = hide ? 0 : 1
            return
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
            self.Panel.alpha = hide ? 0 : 1
        }, completion: nil)
    }
    
    // MARK: - ARKit
    
    func showTrackingQualityInfo(for trackingState: ARCamera.TrackingState, autoHide: Bool) {
        showMessage(trackingState.presentationString, autoHide: autoHide)
    }
    
    func escalateFeedback(for trackingState: ARCamera.TrackingState, inSeconds seconds: TimeInterval) {
        cancelScheduledMessage(for: .trackingStateEscalation)
        
        let timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { [unowned self] _ in
            self.cancelScheduledMessage(for: .trackingStateEscalation)
            
            var message = trackingState.presentationString
            if let recommendation = trackingState.recommendation {
                message.append(": \(recommendation)")
            }
            
            self.showMessage(message, autoHide: false)
        })
        
        timers[.trackingStateEscalation] = timer
    }
}

extension ARCamera.TrackingState {
    var recommendation: String? {
        switch self {
        case .limited(.excessiveMotion):
            return "请降低速度"
        case .limited(.insufficientFeatures):
            return "请对准平面"
        case .limited(.relocalizing):
            return "请回到原来位置"
        default:
            return nil
        }
    }
    var presentationString: String {
        switch self {
        case .notAvailable:
            return "无法追踪"
        case .normal:
            return "追踪正常"
        case .limited(.excessiveMotion):
            return "动作过快"
        case .limited(.insufficientFeatures):
            return "细节过低"
        case .limited(.initializing):
            return "初始化中"
        case .limited(.relocalizing):
            return "恢复中"
        }
    }
    
    
}
