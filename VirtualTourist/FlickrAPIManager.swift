//
//  FlickerAPIManager.swift
//  VirtualTourist
//
//  Created by Mazen Al Quliti on 08/07/2019.
//  Copyright © 2019 Mazen Al Quliti. All rights reserved.
//

import Foundation


class FlickrAPIManager: NSObject {
    
    static let API_KEY = "3d403ecdb7bc26e16d5f11e7f9961e19"
    
    private let API_KEY_PRIVATE = "4c2e61f57cc5459c"
    
    static let API_URL_BASE = "https://www.flickr.com"
    static let API_URL_PATH = "/services/rest/?method=flickr.photos.search&"
    
    func getPrivateKey() -> String {
        return API_KEY_PRIVATE
    }
    
    class func getQueryUrl(lat: String, lon: String, radius: Int = 5, perPage: Int = 100, page: Int = 1) -> String {
        return API_URL_BASE+API_URL_PATH+"api_key=\(API_KEY)&lat=\(lat)&lon=\(lon)&radius=\(radius)&per_page=\(perPage)&page=\(page)&format=json&nojsoncallback=1"
    }
    
    class func gettImageUrl(farm: Int, serverId: String, photoId: String, secret: String) -> String {
        return "https://farm\(farm).staticflickr.com/\(serverId)/\(photoId)_\(secret).jpg"
    }
}
