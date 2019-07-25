//
//  Model.swift
//  VirtualTourist
//
//  Created by Mazen Al Quliti on 08/07/2019.
//  Copyright © 2019 Mazen Al Quliti. All rights reserved.
//

import Foundation

struct FlickrPhotosResults : Codable {
    let photos : FlickrPhotos
    let stat : String
}

struct FlickrPhotos : Codable {
    let page : Int
    let pages : Int
    let perpage : Int
    let total : String
    let photo : [FlickrPhoto]
}

struct FlickrPhoto : Codable {
    let id : String
    let owner : String
    let secret : String
    let server : String
    let farm : Int
    let title : String
    let ispublic : Int
    let isfriend : Int
    let isfamily : Int
}

class Model {
    
    static var shared : FlickrPhotos?
    
}
