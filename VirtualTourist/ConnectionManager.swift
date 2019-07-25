//
//  ConnectionManager.swift
//  OnTheMap
//
//  Created by Mazen Al Quliti on 27/06/2019.
//  Copyright © 2019 Mazen Al Quliti. All rights reserved.
//

import Foundation
import UIKit

enum ConnectionMethod : String {
    case get = "GET", post = "POST", delete = "DELETE"
}

struct CustomError : Error {
    let title : String
    let status : String
    let body : String
}

class ConnectionManager  {
    
    func fetchImagesInLocation(requestUrl: String, completionHandler: @escaping (Bool, CustomError?) -> (Void)) {
        URLSession.shared.dataTask(with: URL(string: requestUrl)!) { (data, response, error) in
            guard data != nil else {
                completionHandler(false, self.handleError(response: response, error: error))
                return
            }
            do {
                let decoder = JSONDecoder()
                Model.shared = try decoder.decode(FlickrPhotosResults.self, from: data!).photos
                completionHandler(true, nil)
            } catch {
                completionHandler(false, self.handleError(response: response, error: error))
                return
            }
        }.resume()
    }
    
    
    func fetchImage(requestUrl: String, completionHandler: @escaping (UIImage?, CustomError?) -> (Void)) {
        URLSession.shared.dataTask(with: URL(string: requestUrl)!) { (data, response, error) in
            guard data != nil else {
                completionHandler(nil, self.handleError(response: response, error: error))
                return
            }
            if let image = UIImage(data: data!) {
                completionHandler(image, nil)
            }
            }.resume()
    }
    
    
    func handleError(response : URLResponse?, error: Error?) -> CustomError{
        guard let response = response else {
            let errorTemp = CustomError(title: "Error", status: "", body: error!.localizedDescription)
            return errorTemp
        }
        let errorTemp = CustomError(title: "Error", status: "\((response as! HTTPURLResponse).statusCode)", body: error!.localizedDescription)
        return errorTemp
    }
}
