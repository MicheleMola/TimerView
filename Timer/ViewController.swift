//
//  ViewController.swift
//  Timer
//
//  Created by Michele Mola on 18/05/2019.
//  Copyright © 2019 Michele Mola. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  var timerView: TimerView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let frame = CGRect(x: view.bounds.midX - 150, y: view.bounds.midY - 150, width: 300, height: 300)
    
    self.timerView = TimerView(frame: frame)
    self.timerView.strokeColor = UIColor.blue.cgColor
    self.timerView.lineWidth = 10
    self.timerView.duration = 20
    
    self.view.addSubview(timerView)
  }
  
  @IBAction func playPressed(_ sender: UIButton) {
    timerView.startAnimation()
  }
  


}

