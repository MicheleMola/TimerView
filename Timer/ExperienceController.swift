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
  
  @IBOutlet weak var timerView: TimerView!
  
  @IBOutlet weak var buildingImageViewTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var buildingImageViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var buildingImageViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var buildingImageViewHeightConstraint: NSLayoutConstraint!
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
    self.timerView.duration = 5
    self.timerView.timerFontSize = 20
  }
  
  override func viewDidAppear(_ animated: Bool) {
    // Prevent the screen from being dimmed to avoid interuppting the AR experience.
    UIApplication.shared.isIdleTimerDisabled = true
  
    setupView()
    
    print(self.view.safeAreaInsets)
    
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
    
    //statusViewController.scheduleMessage("Look around to detect images", inSeconds: 7.5, messageType: .contentPlacement)
    startTutorial()
  }
  
  func startTutorial() {
    buildingImageView.isHidden = false
    // Start Gif
    
    // Start timer and then move image to the bottom-right corner
    animateBuildingImageView()
  }
  
  func animateBuildingImageView() {
    
    let safeAreaInsets = self.view.safeAreaInsets
    let buildingImageViewWidth = self.buildingImageView.frame.width
    
    UIView.animate(withDuration: 1, delay: 5, options: [], animations: {
      
      print(safeAreaInsets)
      let leadingConstraint = self.view.frame.width - (buildingImageViewWidth/2) - safeAreaInsets.left - safeAreaInsets.right - 16
      let topConstraint = self.view.frame.height - safeAreaInsets.top - safeAreaInsets.bottom - (buildingImageViewWidth/2) - 8
      
      self.buildingImageViewLeadingConstraint.constant = leadingConstraint
      self.buildingImageViewTopConstraint.constant = topConstraint
      
      self.buildingImageViewWidthConstraint.constant /= 2
      self.buildingImageViewHeightConstraint.constant /= 2
      
      self.view.layoutIfNeeded()
    })
  
  }

  func setupView() {
    
    let safeAreaInsets = self.view.safeAreaInsets
    
    let leadingConstraint = self.view.frame.width/2 - self.buildingImageView.frame.width/2 - safeAreaInsets.left
    let topConstraint = self.view.frame.height/2 - self.buildingImageView.frame.height/2 - safeAreaInsets.top
    
    self.buildingImageViewLeadingConstraint.constant = leadingConstraint
    self.buildingImageViewTopConstraint.constant = topConstraint
    
    self.view.layoutIfNeeded()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    
    updateLayout(with: size)
  }
  
  
  func updateLayout(with view: CGSize) {
    
    var leadingConstraint: CGFloat = 0
    var topConstraint: CGFloat = 0
    
    if isCentered(view: self.buildingImageView.frame, in: view) {
      leadingConstraint = view.width/2 - self.buildingImageView.frame.width/2
      topConstraint = view.height/2 - self.buildingImageView.frame.height/2
    } else {
      if view.width < view.height {
        leadingConstraint = view.width - self.buildingImageView.frame.width - 16
        topConstraint = view.height - self.buildingImageView.frame.height - 34 - 44 - 8
      } else {
        leadingConstraint = view.width - self.buildingImageView.frame.width - 44 - 34
        topConstraint = view.height - self.buildingImageView.frame.height - 21 - 8
      }
      
    }
    
    self.buildingImageViewLeadingConstraint.constant = leadingConstraint
    self.buildingImageViewTopConstraint.constant = topConstraint
    
    self.view.layoutIfNeeded()
  }
  
  func isCentered(view: CGRect, in superview: CGSize) -> Bool {
    if view.origin.x == superview.width/2 - view.width/2 {
      return true
    }
    return false
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
      
      // Add the plane visualization to the scene.
      node.addChildNode(planeNode)
    }
    
    DispatchQueue.main.async {
      let imageName = referenceImage.name ?? ""
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
