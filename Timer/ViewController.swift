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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.timerView.strokeColor = UIColor.white.cgColor
    self.timerView.lineWidth = 6
    self.timerView.duration = 10
    self.timerView.timerFontSize = 20
  }
  
  @IBAction func playPressed(_ sender: UIButton) {
    timerView.startAnimation()
  }
  


}

