//
//  ExperienceController.swift
//  Timer
//
//  Created by Michele Mola on 5/24/19.
//  Copyright © 2019 Michele Mola. All rights reserved.
//

import UIKit
import ARKit
import SwiftyGif

class ExperienceController: UIViewController {
  
  @IBOutlet weak var ARSceneView: ARSCNView!
  
  @IBOutlet weak var buildingImageView: UIImageView!
  @IBOutlet weak var smallBuildingImageView: UIImageView!
  
  @IBOutlet weak var timerView: TimerView!
  
  var experienceScene: ExperienceScene?
  
  @IBOutlet weak var progressLabel: UILabel!
  
  @IBOutlet weak var progressStackView: UIStackView!
  
  @IBOutlet weak var gifImageView: UIImageView!
    
  /// A serial queue for thread safety when modifying the SceneKit node graph.
  let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".serialSceneKitQueue")
  
  // Convenience accessor for the session owned by ARSCNView.
  var session: ARSession {
    return ARSceneView.session
  }
  
  override func viewDidLoad() {
    ARSceneView.delegate = self
    ARSceneView.session.delegate = self
    
    setupTimerView()
  }
  
  func setupTimerView() {
    
    self.timerView.strokeColor = UIColor.white.cgColor
    self.timerView.lineWidth = 6
    self.timerView.duration = 8
    self.timerView.timerFontSize = 20
    self.timerView.delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    // Prevent the screen from being dimmed to avoid interuppting the AR experience.
    UIApplication.shared.isIdleTimerDisabled = true
  
    setupView()
    
    setupExperience()
    
    testDisk()
    
    // Start the AR experience
    //resetTracking()
  }
  
  func testDisk() {
    
    let resource = ARResource(experienceID: "ok", video: "ok", refImage: "ok", refARImage: "ok", model3D: "ok")
    let contents = ARResources(size: 30, resources: [resource])
    
    do {
      try DiskCaretaker.save(contents, to: "contents")
      
      let resources = try DiskCaretaker.retrieve(ARResources.self, from: "contents")
     
      print(resources)
      
    }catch let error {
      print(error)
    }
    
    
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    session.pause()
  }
  
  func setupExperience() {
    
    download() { result in
      
      if let image = UIImage(named: "Lunedì")?.cgImage {
        ARResourceManager.shared.add(image: image, withName: "Lunedì", andWidth: 15)
      }
    
      self.resetTracking()
      
      self.startTutorial()
    }
  }
  
  func download(completion: @escaping (_ result: Bool) -> ()) {
    
    var runCount = 0
    
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [unowned self] timer in
      
      runCount += 1
      
      self.progressLabel.text = "\(runCount) %"
      
      if runCount == 5 {
        timer.invalidate()
        
        completion(true)
      }
    }
  }
  
  func resetTracking() {
    let referenceImages = ARResourceManager.shared.get()
    
    let configuration = ARWorldTrackingConfiguration()
    configuration.detectionImages = referenceImages
    session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    
    self.experienceScene = nil
    
  }
  
  func startTutorial() {
//    buildingImageView.isHidden = false
    progressStackView.isHidden = true
    
    // Start Gif
    let gifImage = UIImage(gifName: "hand.gif")
    self.gifImageView.setGifImage(gifImage)
    
    // Start timer and then move image to the bottom-right corner
    animateBuildingImageView()
  }
  
  func animateBuildingImageView() {
    
    UIView.animate(withDuration: 1, delay: 5, options: [], animations: { [unowned self] in
      
      self.buildingImageView.alpha = 0
      self.smallBuildingImageView.alpha = 1
      self.gifImageView.alpha = 0
    })
  }

  func setupView() {
    
    
  }
  
}

extension ExperienceController: ARSCNViewDelegate {
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard let imageAnchor = anchor as? ARImageAnchor else { return }
    let referenceImage = imageAnchor.referenceImage
    
    updateQueue.async {
      let videoNode = SCNNode()
      
      let width = referenceImage.physicalSize.width
      let height = referenceImage.physicalSize.height
      
      videoNode.geometry = SCNPlane(width: width, height: height)
      
      videoNode.eulerAngles.x = -.pi / 2
      
      self.experienceScene = ExperienceScene(size: CGSize(width: 1000, height: 1000), videoResource: "videoL", _extension: "mp4")
    
      self.experienceScene?.backgroundColor = .clear
      
      videoNode.geometry?.firstMaterial?.diffuse.contents = self.experienceScene
      
      videoNode.rotation = SCNVector4(0, 1, 1, CGFloat.pi)
      videoNode.scale.x *= -1
      
      // Add the plane visualization to the scene.
      node.addChildNode(videoNode)
    }
    
    DispatchQueue.main.async {
      
      self.smallBuildingImageView.alpha = 0
      self.timerView.startAnimation()
    }
  }
}

extension ExperienceController: ARSessionDelegate {
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    
  }
  
  func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
    return true
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    resetTracking()
  }
  
  func restartExperience() {
    resetTracking()
  }
  
}

extension ExperienceController: TimerViewDelegate {
  func restart() {
    resetTracking()
  }
  
}
