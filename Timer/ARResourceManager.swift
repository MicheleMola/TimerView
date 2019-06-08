//
//  ARResourceManager.swift
//  Timer
//
//  Created by Michele Mola on 6/5/19.
//  Copyright © 2019 Michele Mola. All rights reserved.
//

import Foundation
import ARKit

class ARResourceManager {
  static let shared = ARResourceManager()
  
  var customReferenceSet = Set<ARReferenceImage>()
  
  func get() -> Set<ARReferenceImage> {
    return customReferenceSet
  }
  
  func add(image: CGImage, withName name: String, andWidth width: CGFloat) {
    
    let referenceImage = ARReferenceImage(image, orientation: .up, physicalWidth: width)
    referenceImage.name = name
    
    customReferenceSet.insert(referenceImage)
  }
}
