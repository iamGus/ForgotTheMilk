//
//  ShowAlert.swift
//  ForgotTheMilk
//
//  Created by Angus Muller on 28/11/2017.
//  Copyright © 2017 Angus Muller. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String, style: UIAlertControllerStyle = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertApplicationSettings(forErorType: LocationError) {
        
        // Choose message to use
        var message: String {
            switch forErorType {
            case .setToWhenInUse: return "Location permission is currently set to in use only, please change in settings to \"Always\" so app can find your location"
            case .unknownError: return "Sorry as your Location Permission is not set to \"Always\" the location function in this app will work"
            default: return "Location permission is currently not allowed, please change in settings so app can find your location"
            }
        }
        
        
        // Meaning authorization is denied so ask user to allow permissions in settings
        let alertController = UIAlertController(title: "Location Permission Error", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) {
            UIAlertAction in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:],
                                              completionHandler: { (success) in
                                                print("Open \(UIApplicationOpenSettingsURLString): \(success)")
                    })
                } else {
                    let success = UIApplication.shared.openURL(url)
                    print("Open \(UIApplicationOpenSettingsURLString): \(success)")
                }
            }
        }
        
        alertController.addAction(okAction)
        alertController.addAction(settingsAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}


