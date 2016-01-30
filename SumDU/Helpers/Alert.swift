//
//  Alert.swift
//  SumDU
//
//  Created by Maksym Skliarov on 1/28/16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import UIKit
import SVProgressHUD

class Alert {
    class func showWithStatus(status: String) {
        dispatch_async(dispatch_get_main_queue(), {
            SVProgressHUD.showSuccessWithStatus(status, maskType: SVProgressHUDMaskType.Gradient)
        })
    }
    
    class func showWithError(error: String) {
        dispatch_async(dispatch_get_main_queue(), {
            SVProgressHUD.showErrorWithStatus(error, maskType: SVProgressHUDMaskType.Gradient)
        })
    }
    
    // MARK: - Helpers
    
    class func showSuccessStatus() {
        Alert.showWithStatus(NSLocalizedString("Success!", comment: ""))
    }
    
    class func showNetworkingError() {
        Alert.showWithError(NSLocalizedString("Check your internet connection", comment: ""))
    }
}