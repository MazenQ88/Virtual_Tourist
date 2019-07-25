//
//  File.swift
//  OnTheMap
//
//  Created by Mazen Al Quliti on 05/07/2019.
//  Copyright © 2019 Mazen Al Quliti. All rights reserved.
//

import Foundation
import UIKit

class AlertViewController : NSObject {
    
    var presenter : Any?
    
    init(aPresenter: Any) {
        presenter = aPresenter
    }
    
    func showAlert(title: String, body: String) {
        guard let aPresenter = presenter as? UIViewController else {
            return
        }
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: title, message: body, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            aPresenter.present(alertVC, animated: true)
        }
    }
}
