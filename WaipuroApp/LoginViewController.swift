//
//  LoginViewController.swift
//  WaipuroApp
//
//  Created by YUKI YOUDA on 2021/11/21.
//

import UIKit
import AuthenticationServices //認証用のモジュール(標準ライブラリ)
import Alamofire
import SwiftyJSON
import KeychainAccess

class LoginViewController: UIViewController {
    let consts = Constants.shared
    var token = ""
    var session: ASWebAuthenticationSession?
    
    
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //取得したcodeを使ってアクセストークンを発行
    func getAccessToken() {
        
        let url = URL(string: consts.baseUrl + "/login")!
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "ACCEPT": "application/json"
        ]
        
        let parameters: Parameters = [
            "email": mail.text!,
            "password": password.text!
        ]
        
        //Alamofireでリクエスト
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let token: String? = json["token"].string
                guard let accessToken = token else { return }
                self.token = accessToken
                let keychain = Keychain(service: self.consts.service) //このアプリ用のキーチェーンを生成
                keychain["access_token"] = accessToken //キーを設定して保存
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }

    @IBAction func login(_ sender: Any) {
        let keychain = Keychain(service: consts.service)
        if keychain["access_token"] != nil {
            token = keychain["access_token"]!
        } else {
            self.getAccessToken()
        }
    }
}
