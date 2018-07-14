//
//  RecognizeViewController.swift
//  Recognizer
//
//  Created by Chun Kong on 2018/6/12.
//  Copyright © 2018年 chenzhengang. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import Vision
import AVFoundation

var mo = 0 //是否生成怪物
var press = 0 //是否主动生成

class RecognizeViewController: UIViewController, UIGestureRecognizerDelegate, ARSKViewDelegate, ARSessionDelegate {
    var type = 1
    var overlayScene = Scene()
    var audioPlayer: AVAudioPlayer!
    //MARK : IBOutlets
    @IBOutlet weak var sceneView: ARSKView!
    
    @IBOutlet weak var statusView: UIView!
    
    @IBAction func State(_ sender: UISwitch) {
        if type == 0
        {
            type = 1
            }
        else {
            type = 0
        }
        //type 0 识别模式
        //type 1 即可扫描图片
    }
    @IBAction func monster(_ sender: UISwitch) {
        if mo == 0
        {
            playBgMusic()
            mo = 1
           }
        else {
            audioPlayer.stop()
            mo = 0
        }
        //mo默认0 
        //mo 1 即可随机生成怪物
    }
    // The view controller that displays the status and "restart experience" UI.
    private lazy var statusViewController: StatusViewController = {
        return childViewControllers.lazy.flatMap({ $0 as? StatusViewController }).first!
    }()

    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overlayScene = Scene(size: sceneView.bounds.size)
        overlayScene.scaleMode = .resizeFill
        sceneView.delegate = self
        sceneView.presentScene(overlayScene)
        sceneView.session.delegate = self
        //playBgMusic()
        //statusViewController.changetext(string: "aaaaaaaaaaa")
                
        // Hook up status view controller callback.
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartSession()
            self.anchorNum = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("AR Resources 资源文件不存在 。")
        }
        configuration.detectionImages = referenceImages
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    // MARK: - ARSessionDelegate
    // 把图像传递给Vision
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // 保证一次处理一张
        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
            return
        }
        self.currentBuffer = frame.capturedImage
        classifyCurrentImage()
    }
    
    // MARK: - Vision classification
    // 调用模型进行识别
    private lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: Inceptionv3().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            
            // 获取模型需要的图片大小
            request.imageCropAndScaleOption = .centerCrop
            
            // 只用CPU处理 保证GPU用于渲染
            request.usesCPUOnly = true
            
            return request
        } catch {
            fatalError("无法加载ML模型: \(error)")
        }
    }()
    
    // 当前图片buffer
    private var currentBuffer: CVPixelBuffer?
    
    // 使用队列
    private let visionQueue = DispatchQueue(label: "com.chenzhengang.Recognizer.serialVisionQueue")
    
    // 对当前图片进行识别
    private func classifyCurrentImage() {
        // 获取相机的位姿、对图片进行旋转之后处理
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(UIDevice.current.orientation.rawValue))
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentBuffer!, orientation: orientation!)
        visionQueue.async {
            do {
                // 释放
                defer { self.currentBuffer = nil }
                try requestHandler.perform([self.classificationRequest])
            } catch {
                print("请求失败 \"\(error)\"")
            }
        }
    }
    
    // 获取识别结果
    private var identifierString = ""
    private var confidence: VNConfidence = 0.0
    
    func processClassifications(for request: VNRequest, error: Error?) {
        guard let results = request.results else {
            print("无法识别.\n\(error!.localizedDescription)")
            return
        }
        
        let classifications = results as! [VNClassificationObservation]
        
        // 读取结果
        if let bestResult = classifications.first(where: { result in result.confidence > 0.3 }),
            let label = bestResult.identifier.split(separator: ",").first {
            identifierString = String(label)
            confidence = bestResult.confidence
        } else {
            identifierString = ""
            confidence = 0
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.displayClassifierResults()
        }
    }
    
    // 提示结果
    private func displayClassifierResults() {
        guard !self.identifierString.isEmpty else {
            return // 没有识别结果
        }
        let message = String(format: "Detected \(self.identifierString)")
        statusViewController.showMessage(message)
        
        
    }
    
    private func playBgMusic(){
        
        let musicPath = Bundle.main.path(forResource: "bgmusic", ofType: "MP3")
        
        //指定音乐路径
        
        let url = NSURL(fileURLWithPath: musicPath!)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url as URL)}
        catch {}
        
        audioPlayer.numberOfLoops = -1
        
        //设置音乐播放次数，-1为循环播放
        
        audioPlayer.volume = 1
        
        //设置音乐音量，可用范围为0~1
        
        audioPlayer.prepareToPlay()
        
        audioPlayer.play()
        
    }
    
    
    // MARK: - Tap gesture handler
    
    // Labels for classified objects by ARAnchor UUID
    private var anchorLabels = [UUID: String]()
    
    private var anchorNum = 0
    
    // 放置
    @IBAction func placeLabelAtLocation(_ sender: UITapGestureRecognizer) {
        guard let nodes = overlayScene.nodes(at: sender.location(in: self.view)).first else {return}
        if (nodes.name == "hero"){
            nodes.removeFromParent()
            self.restartSession()
        }
    }
    
    let killSound = SKAction.playSoundFileNamed("hit", waitForCompletion: false)
    
    var lastScaleFactor : CGFloat! = 1  //放大、缩小
    
    @IBAction func Zoom(_ sender: UIPinchGestureRecognizer) {
//        print("zoom")
        guard let nodes = overlayScene.childNode(withName: "hero") else {return}  //这个找到的是父节点  即添加的node   而不是nodes
//        nodes.removeFromParent()
        let factor = sender.scale
        if factor > 1 {
            let Action4 = SKAction.scale(to: factor + lastScaleFactor - 1, duration: 0)
            nodes.children.first?.run(Action4)
        }
        else {
            let Action4 = SKAction.scale(to: factor * lastScaleFactor, duration: 0)
            nodes.children.first?.run(Action4)
        }
        
        if sender.state == UIGestureRecognizerState.ended
        {
            if factor > 1{
                lastScaleFactor = lastScaleFactor + factor - 1
            }else{
                lastScaleFactor = lastScaleFactor * factor
            }
        }
    }
    
    
    func view(_ view: ARSKView, didUpdate node: SKNode, for anchor: ARAnchor)
    {
        
    }
    
    func view(_ view: ARSKView, didRemove node: SKNode, for anchor: ARAnchor)
    {
        
    }
    
    func view(_ view: ARSKView, didAdd node: SKNode, for anchor: ARAnchor) {
        if type == 1 {
        guard let imageAnchor = anchor as? ARImageAnchor else {return}
        
        //let photoname = imageAnchor.referenceImage.name!
        // 创建
        let alertController = UIAlertController(title: "检测到隐藏信息", message: "显示信息或者弹出网页", preferredStyle:.alert)
        
        // 设置2个UIAlertAction
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "好的", style: .default) { (UIAlertAction) in
        }
        
        // 添加
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        // 弹出
        self.present(alertController, animated: true, completion: nil)
        return
        }
        else if (type==0 && mo == 1 && press == 0){
            let nodes = SKSpriteNode(imageNamed: "ghost")
            nodes.name = "ghost"
            //动作
            //旋转
            let Action = SKAction.rotate(byAngle: CGFloat(float_t.pi * 0.2), duration: 0.6)
            let Action3 = SKAction.rotate(toAngle: 0, duration: 0.6)
            let Action2 = SKAction.rotate(byAngle: CGFloat(float_t.pi * -0.2), duration: 0.6)
            let sequence = SKAction.sequence([Action,Action3,Action2,Action3])
            //放大缩小
            let Action4 = SKAction.scale(by: 2, duration: 0.9)
            let Action5 = SKAction.scale(by: 0.5, duration: 0.9)
            let sequence2 = SKAction.sequence([Action4,Action5])
            //透明度
            let Action6 = SKAction.fadeAlpha(by: -0.5, duration: 0.6)
            let Action8 = SKAction.wait(forDuration: 0.6)
            let Action7 = SKAction.fadeIn(withDuration: 0.6)
            let sequence3 = SKAction.sequence([Action6,Action8,Action7])
            
            let group = SKAction.group([sequence, sequence2, sequence3])
            
            nodes.run(SKAction.repeatForever(group))
            
            node.addChild(nodes)
        }
        else if (type == 0 && press == 1){    //按下
            
        var nodes :SKNode
        if identifierString.contains("cat") {
            nodes = SKSpriteNode(imageNamed: "cat")
            }
        else if identifierString.contains("panda") {
            nodes = SKSpriteNode(imageNamed: "panda")
        }
            //默认是狗
        else { nodes = SKSpriteNode(imageNamed: "dog")}
        nodes.name = "hero"
        let Action = SKAction.rotate(byAngle: CGFloat(float_t.pi * 0.2), duration: 1)
        let Action3 = SKAction.rotate(toAngle: 0, duration: 1)
        let Action2 = SKAction.rotate(byAngle: CGFloat(float_t.pi * -0.2), duration: 1)
        //        var Action = SKAction.scale(by: 2, duration: 3)
        //        var Action2 = SKAction.scale(by: 0.5, duration: 3)
        //        nodes.run(SKAction.repeatForever(Action))
        //        nodes.run(SKAction.repeatForever(Action2))
        //            nodes.run(Action) {
        //               nodes.run(Action2)
        //只能做一次
        //            }
        let sequence = SKAction.sequence([Action,Action3,Action2,Action3])
        nodes.run(SKAction.repeatForever(sequence))
        node.addChild(nodes)
        node.name = "hero"
        press = 0
        }
        else {
            
        }
    }
    
    
    
    // MARK: - AR Session Handling
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        statusViewController.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
        
        switch camera.trackingState {
        case .notAvailable, .limited:
            statusViewController.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
        case .normal:
            statusViewController.cancelScheduledMessage(for: .trackingStateEscalation)
            // 隐藏
            setOverlaysHidden(false)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Filter out optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        setOverlaysHidden(true)
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        /*
         Allow the session to attempt to resume after an interruption.
         This process may not succeed, so the app must be prepared
         to reset the session if the relocalizing status continues
         for a long time -- see `escalateFeedback` in `StatusViewController`.
         */
        return true
    }
    
    private func setOverlaysHidden(_ shouldHide: Bool) {
        sceneView.scene!.children.forEach { node in
            if shouldHide {
                // Hide overlay content immediately during relocalization.
                node.alpha = 0
            } else {
                // Fade overlay content in after relocalization succeeds.
                node.run(.fadeIn(withDuration: 0.5))
            }
        }
    }
    
    private func restartSession() {
        statusViewController.cancelAllScheduledMessages()
        statusViewController.showMessage("Restart")
        
        anchorLabels = [UUID: String]()
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - Error
    //弹窗重新启动
    private func displayErrorMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.restartSession()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func TEST(_ sender: UIBarButtonItem) {
        // 通过摄像头当前的位置创建锚点
        if let currentFrame = sceneView.session.currentFrame {
            // 创建一个往摄像头前面平移 0.2 米的转换
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -1
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // 在会话上添加一个锚点
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
        press = 1
    }
    @IBAction func new(_ sender: UIButton) {
        // 通过摄像头当前的位置创建锚点
        if let currentFrame = sceneView.session.currentFrame {
            // 创建一个往摄像头前面平移 0.2 米的转换
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -1
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // 在会话上添加一个锚点
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
        press = 1
    }
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
