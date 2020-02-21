//
//  PhotoSet.swift
//  NotesList
//
//  Created by ios_school on 2/21/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import Foundation

import UIKit

struct Photo {
  var image: UIImage
  
  init(image: UIImage) {
    self.image = image
  }
  
  static func allPhotos() -> [Photo] {
    let photoNames = ["screen_1","screen_2","screen_3"]
    var photos: [Photo] = []
    for name in photoNames {
        if let image = UIImage(named: name) {
        photos.append(Photo(image: image))
        }
    }
    return photos
  }
}
