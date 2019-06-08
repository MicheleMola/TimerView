//
//  ExperienceScene.swift
//  Timer
//
//  Created by Michele Mola on 6/3/19.
//  Copyright © 2019 Michele Mola. All rights reserved.
//

import AVFoundation
import Foundation
import SceneKit
import SpriteKit

class ExperienceScene: SKScene {
  
  var player: AVPlayer?
  
  let videoResource: String
  let _extension: String
  
  init(size: CGSize, videoResource: String, _extension: String) {
    self.videoResource = videoResource
    self._extension = _extension
    
    super.init(size: size)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func sceneDidLoad() {
    super.sceneDidLoad()
    
    guard let url = Bundle.main.url(forResource: self.videoResource, withExtension: self._extension) else {
      print("Can't find example video")
      return
    }
    
    // Creating our player
    let playerItem = AVPlayerItem(url: url)
    player = AVQueuePlayer(playerItem: playerItem)
    
    // Getting the size of our video
    //    let videoTrack = playerItem.asset.tracks(withMediaType: .video).first!
    
    // Adding a `SKVideoNode` to display video in our scene
    guard let player = player else { return }
    let videoNode = SKVideoNode(avPlayer: player)
    videoNode.position = CGPoint(x: frame.midX, y: frame.midY)
    
    videoNode.size = CGSize(width: frame.width, height: frame.height)
    
    // Let's make it transparent, using an SKEffectNode,
    // since a shader cannot be applied to a SKVideoNode directly
    let effectNode = SKEffectNode()
    // Loving Swift's multiline syntax here:
    effectNode.shader = SKShader(source:
    """
    void main() {
      vec2 texCoords = v_tex_coord;
      vec2 colorCoords = vec2(texCoords.x, (1.0 + texCoords.y) * 0.5);
      vec2 alphaCoords = vec2(texCoords.x, texCoords.y * 0.5);
      vec4 color = texture2D(u_texture, colorCoords);
      float alpha = texture2D(u_texture, alphaCoords).r;
      gl_FragColor = vec4(color.rgb, alpha);
    }
    """)
    
    addChild(effectNode)
    effectNode.addChild(videoNode)
    
    player.play()
  }
  
  deinit {
    player = nil
  }
  
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
  }
}

