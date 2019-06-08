//
//  ARResources.swift
//  Timer
//
//  Created by Michele Mola on 6/7/19.
//  Copyright © 2019 Michele Mola. All rights reserved.
//

import Foundation

struct ARResources: Codable {
  let size: Double
  let resources: [ARResource]
}

struct ARResource: Codable {
  let experienceID: String
  let video: String
  let refImage: String
  let refARImage: String
  let model3D: String
}
