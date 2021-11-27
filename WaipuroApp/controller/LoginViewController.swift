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
    var user_id = ""
    var session: ASWebAuthenticationSession?
    
    
    
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let keychain = Keychain(service: consts.service)
        if keychain["access_token"] != nil {
            keychain["access_token"] = nil //keychainに保存されたtokenを削除
        }
        
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
                let user_id = json["user"]["id"].int!
                let userVC = self.storyboard?.instantiateViewController(withIdentifier: "userVC") as! UserViewController
                userVC.user_id = String(user_id)

                print(userVC.user_id)
                guard let accessToken = token else { return }
                self.token = accessToken
                let keychain = Keychain(service: self.consts.service) //このアプリ用のキーチェーンを生成
                keychain["access_token"] = accessToken //キーを設定して保存
                self.transitionToTabBar() //画面遷移
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func transitionToTabBar() {
        let tabBarContorller = self.storyboard?.instantiateViewController(withIdentifier: "TabBarC") as! UITabBarController
        tabBarContorller.modalPresentationStyle = .fullScreen
        present(tabBarContorller, animated: true, completion: nil)
    }
    
    @IBAction func login(_ sender: Any) {
        let keychain = Keychain(service: consts.service)
        if keychain["access_token"] != nil {
            token = keychain["access_token"]!
            transitionToTabBar() //画面遷移
            
        } else {
            self.getAccessToken()
        }
    }
}
