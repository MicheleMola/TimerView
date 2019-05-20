//
//  Timer.swift
//  Timer
//
//  Created by Michele Mola on 18/05/2019.
//  Copyright © 2019 Michele Mola. All rights reserved.
//

import UIKit

class TimerView: UIView {

  fileprivate var timer: Timer?
  fileprivate var timerLabel = UILabel()
  fileprivate let shapeLayer = CAShapeLayer()
  
  var strokeColor = UIColor.white.cgColor {
    didSet {
      shapeLayer.strokeColor = strokeColor
    }
  }
  
  var lineWidth: CGFloat = 10 {
    didSet {
      shapeLayer.lineWidth = lineWidth
      
      generateCircle()
    }
  }
  
  var timerFontSize: CGFloat = 20 {
    didSet {
      self.timerLabel.font = self.timerLabel.font.withSize(timerFontSize)
    }
  }
  
  var duration: Double = 10 {
    didSet {
      self.timerLabel.text = "\(Int(duration))"
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    addTimer()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)

    addTimer()
  }
  
  func startAnimation() {
    startCountdown()
    addAnimations()
  }
  
  private func addTimer() {
    
    let width = self.bounds.midX/2
    let height = self.bounds.midY/2
    let frame = CGRect(x: self.bounds.midX - width/2, y: self.bounds.midY - height/2, width: width, height: height)
    self.timerLabel = UILabel(frame: frame)
    self.timerLabel.textColor = UIColor(cgColor: self.strokeColor)
    self.timerLabel.text = "\(Int(duration))"
    self.timerLabel.textAlignment = .center
    self.timerLabel.font = self.timerLabel.font.withSize(timerFontSize)
    
    self.addSubview(timerLabel)
  }
  
  private func generateCircle() {
    
    let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    let radius = min(self.bounds.midX, self.bounds.midY) - lineWidth/2
    
    let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 1.5 * CGFloat.pi, endAngle: 3.5 * CGFloat.pi, clockwise: true)
    
    shapeLayer.path = circularPath.cgPath
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.lineCap = CAShapeLayerLineCap.round
    
    shapeLayer.strokeEnd = 1
    
    self.layer.addSublayer(shapeLayer)
  }
  
  func addAnimations() {
    
    let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
    progressAnimation.fromValue = 1
    progressAnimation.toValue = 0
    progressAnimation.duration = self.duration
    progressAnimation.beginTime = 0.0
    
    let fillAnimation = CABasicAnimation(keyPath: "fillColor")
    fillAnimation.toValue = self.strokeColor
    fillAnimation.beginTime = progressAnimation.beginTime + progressAnimation.duration
    fillAnimation.duration = 0.1
    
    let groupAnimation = CAAnimationGroup()
    groupAnimation.animations = [progressAnimation, fillAnimation]
    groupAnimation.duration = fillAnimation.beginTime + fillAnimation.duration
    groupAnimation.fillMode = CAMediaTimingFillMode.forwards
    groupAnimation.isRemovedOnCompletion = false
    groupAnimation.delegate = self
    
    shapeLayer.add(groupAnimation, forKey: "animations")
  }
  
  func startCountdown() {
    generateCircle()
    
    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
  }
  
  @objc func updateTime() {
    
    duration -= 1
    self.timerLabel.text = "\(Int(duration))"
    
    if duration == 0 {
      self.timer?.invalidate()
      self.timer = nil
    }
  }
  
  func createPlayButton() {
    
    let width = self.bounds.midX
    let height = self.bounds.midY
    
    // Only for our triangle
    let magicOffset = self.bounds.width * 0.061
    
    let path = UIBezierPath()
    path.move(to: CGPoint(x: width/2 + magicOffset, y: height/2))
    path.addLine(to: CGPoint(x: width + width/2 + magicOffset, y: height))
    path.addLine(to: CGPoint(x: width/2 + magicOffset, y: height + height/2))
    path.close()
    
    let triangleLayer = CAShapeLayer()
    triangleLayer.lineCap = CAShapeLayerLineCap.round
    triangleLayer.lineJoin = CAShapeLayerLineJoin.round
    triangleLayer.path = path.cgPath
    triangleLayer.fillColor = UIColor(red: 242/255, green: 141/255, blue: 115/255, alpha: 1).cgColor
    
    self.shapeLayer.addSublayer(triangleLayer)
  }
  
  func addTapGesture() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(TimerView.tapFunction))
    self.isUserInteractionEnabled = true
    self.addGestureRecognizer(tap)
  }
  
  @objc func tapFunction(sender: UITapGestureRecognizer) {
    self.layer.sublayers?.removeAll()
    print("tap working")
  }
}

extension TimerView: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag {
      addTapGesture()
      createPlayButton()
    }
  }
}
