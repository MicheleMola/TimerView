//
//  Timer.swift
//  Timer
//
//  Created by Michele Mola on 18/05/2019.
//  Copyright © 2019 Michele Mola. All rights reserved.
//

import UIKit

class TimerView: UIView {

  var timer: Timer?
  var timerLabel = UILabel()
  
  fileprivate let shapeLayer = CAShapeLayer()
  
  var strokeColor = UIColor.red.cgColor
  var lineWidth: CGFloat = 10
  var duration: Double = 10

  required init?(coder aDecoder: NSCoder) {    
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  func startAnimation() {
    addTimer()
    startCountdown()
  }
  
  private func addTimer() {
    
    let frame = CGRect(x: self.bounds.midX - 25, y: self.bounds.midY - 15, width: 50, height: 30)
    self.timerLabel = UILabel(frame: frame)
    self.timerLabel.textColor = UIColor.black
    self.timerLabel.text = "\(Int(duration))"
    self.timerLabel.textAlignment = .center
    
    self.timerLabel.font = self.timerLabel.font.withSize(30.0)
    
    self.timerLabel.adjustsFontSizeToFitWidth = true
    self.timerLabel.minimumScaleFactor = 0.1
    self.timerLabel.numberOfLines = 1
    
    self.addSubview(timerLabel)
  }
  
  private func generateCircle() {
    
    let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    let radius = self.bounds.midX / 2
    
    let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
    
    shapeLayer.path = circularPath.cgPath
    
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = self.strokeColor
    shapeLayer.lineWidth = self.lineWidth
    shapeLayer.lineCap = CAShapeLayerLineCap.round
    
    shapeLayer.strokeEnd = 0
    
    self.layer.addSublayer(shapeLayer)
    
//    addAnimations()
  }
  
  func addAnimations() {
    
    let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
    progressAnimation.fromValue = 0
    progressAnimation.toValue = 1
    progressAnimation.duration = self.duration
    progressAnimation.beginTime = 0.0
    progressAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

    let fillAnimation = CABasicAnimation(keyPath: "fillColor")
    fillAnimation.toValue = self.strokeColor
    fillAnimation.beginTime = progressAnimation.beginTime + progressAnimation.duration - 1
    fillAnimation.duration = 0.5
    
    let groupAnimation = CAAnimationGroup()
    groupAnimation.animations = [progressAnimation, fillAnimation]
    groupAnimation.duration = fillAnimation.beginTime + fillAnimation.duration
    groupAnimation.fillMode = CAMediaTimingFillMode.forwards
    groupAnimation.isRemovedOnCompletion = false
    
    shapeLayer.add(groupAnimation, forKey: "progressAndFillAnimation")
  }
  
  func startCountdown() {
    generateCircle()
    
    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
  }
  
  @objc func updateTime() {
    duration -= 1
    self.timerLabel.text = "\(Int(duration))"
    
    let normalizedDuration = CGFloat(1 - duration/20)
    shapeLayer.strokeEnd = normalizedDuration
    
    if duration == 0 {
      self.timer?.invalidate()
      self.timer = nil
    }
  }
}
