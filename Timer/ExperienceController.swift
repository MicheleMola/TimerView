//
//  ExperienceController.swift
//  Timer
//
//  Created by Michele Mola on 5/24/19.
//  Copyright © 2019 Michele Mola. All rights reserved.
//

import UIKit
import ARKit

class ExperienceController: UIViewController {
  
  @IBOutlet weak var ARSceneView: ARSCNView!
  
  @IBOutlet weak var buildingImageView: UIImageView!
  @IBOutlet weak var smallBuildingImageView: UIImageView!
  
  @IBOutlet weak var timerView: TimerView!
  
  @IBOutlet weak var buildingImageViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var buildingImageViewHeightConstraint: NSLayoutConstraint!
  /// A serial queue for thread safety when modifying the SceneKit node graph.
  let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".serialSceneKitQueue")
  
  // Convenience accessor for the session owned by ARSCNView.
  var session: ARSession {
    return ARSceneView.session
  }
  
  var isPlaced = false
  
  var initialLeadingConstraint: CGFloat = 0
  var initialTopConstraint: CGFloat = 0
  
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
  }
  
  override func viewDidAppear(_ animated: Bool) {
    // Prevent the screen from being dimmed to avoid interuppting the AR experience.
    UIApplication.shared.isIdleTimerDisabled = true
  
    setupView()
    
    // Start the AR experience
    resetTracking()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    session.pause()
  }
  
  func resetTracking() {
    
    guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
      fatalError("Missing expected asset catalog resources.")
    }
    
    let configuration = ARWorldTrackingConfiguration()
    configuration.detectionImages = referenceImages
    session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    
    startTutorial()
  }
  
  func startTutorial() {
    buildingImageView.isHidden = false
    
    // Start Gif
    
    // Start timer and then move image to the bottom-right corner
    animateBuildingImageView()
  }
  
  func animateBuildingImageView() {
    
    UIView.animate(withDuration: 1, delay: 5, options: [], animations: { [unowned self] in
      
      self.buildingImageView.alpha = 0
      self.smallBuildingImageView.alpha = 1
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
      // Create a plane to visualize the initial position of the detected image.
      let plane = SCNPlane(width: referenceImage.physicalSize.width,
                           height: referenceImage.physicalSize.height)
      let planeNode = SCNNode(geometry: plane)
      planeNode.opacity = 0.25
      
      /*
       `SCNPlane` is vertically oriented in its local coordinate space, but
       `ARImageAnchor` assumes the image is horizontal in its local space, so
       rotate the plane to match.
       */
      planeNode.eulerAngles.x = -.pi / 2
      
      planeNode.runAction(self.imageHighlightAction)
      
      // Add the plane visualization to the scene.
      node.addChildNode(planeNode)
    }
    
    DispatchQueue.main.async {
      let imageName = referenceImage.name ?? ""
      
      self.smallBuildingImageView.alpha = 0
      self.timerView.startAnimation()
    }
  }
  
  var imageHighlightAction: SCNAction {
    return .sequence([
      .wait(duration: 0),
      .fadeOpacity(to: 0.85, duration: 2),
      .fadeOpacity(to: 0.15, duration: 2),
      .fadeOpacity(to: 0.85, duration: 2),
      .fadeOut(duration: 2),
      .removeFromParentNode()
      ])
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
