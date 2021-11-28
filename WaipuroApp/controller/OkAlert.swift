//
//  OkAlert.swift
//  WaipuroApp
//
//  Created by YUKI YOUDA on 2021/11/25.
//

import UIKit

class OkAlert: UIAlertController {
    func showOkAlert(title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        viewController.present(alert, animated: true)
    }
}
