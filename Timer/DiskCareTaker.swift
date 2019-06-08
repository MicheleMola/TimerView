//
//  DiskCareTaker.swift
//  Timer
//
//  Created by Michele Mola on 6/7/19.
//  Copyright © 2019 Michele Mola. All rights reserved.
//

import Foundation

public final class DiskCaretaker {
  public static let decoder = PropertyListDecoder()
  public static let encoder = PropertyListEncoder()
  
  public static func createDocumentURL(
    withFileName fileName: String) -> URL {
    let fileManager = FileManager.default
    let url = fileManager.urls(for: .documentDirectory,
                               in: .userDomainMask).first!
    return url.appendingPathComponent(fileName)
      .appendingPathExtension("plist")
  }
  
  public static func save<T: Codable>(
    _ object: T, to fileName: String) throws {
    do {
      
      let url = createDocumentURL(withFileName: fileName)
      
      let data = try encoder.encode(object)
      
      try data.write(to: url, options: .atomic)
    } catch (let error) {
    
      print("Save failed: Object: `\(object)`, " +
        "Error: `\(error)`")
      throw error
    }
  }
  
  public static func retrieve<T: Codable>(
    _ type: T.Type, from fileName: String) throws -> T {
    let url = createDocumentURL(withFileName: fileName)
    return try retrieve(T.self, from: url)
  }
  
  public static func retrieve<T: Codable>(
    _ type: T.Type, from url: URL) throws -> T {
    do {

      let data = try Data(contentsOf: url)
     
      return try decoder.decode(T.self, from: data)
    } catch (let error) {
  
      print("Retrieve failed: URL: `\(url)`, Error: `\(error)`")
      throw error
    }
  }
  
}
