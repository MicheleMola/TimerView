//
//  ViewController.swift
//  Timer
//
//  Created by Michele Mola on 18/05/2019.
//  Copyright © 2019 Michele Mola. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var timerView: TimerView!
  
  @IBOutlet weak var cameraImageView: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.timerView.strokeColor = UIColor.white.cgColor
    self.timerView.lineWidth = 6
    self.timerView.duration = 10
    self.timerView.timerFontSize = 20
    
    setup()
  }
  
  @IBAction func playPressed(_ sender: UIButton) {
    timerView.startAnimation()
  }
  
  func setup() {
    var images: [UIImage] = []
    
    for i in 1...186 {
      print("here")
      let bundlePath = Bundle.main.path(forResource: "Camera_\(i)", ofType: "png")!
      let image = UIImage(contentsOfFile: bundlePath)!
      images.append(image)
    }
//    let images = (1...186).map { UIImage(named: "Camera_\($0)")! }
    
    self.cameraImageView.animationImages = images
    self.cameraImageView.animationDuration = 5
    self.cameraImageView.animationRepeatCount = 1
    self.cameraImageView.startAnimating()
  }
  


}

