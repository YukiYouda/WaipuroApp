//
//  UserViewController.swift
//  WaipuroApp
//
//  Created by YUKI YOUDA on 2021/11/24.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess
import Kingfisher

class UserViewController: UIViewController {
    
    let consts = Constants.shared
    var user_id = ""
   
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var skillLabel: UILabel!
    @IBOutlet weak var carrerLabel: UILabel!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var facebookLabel: UILabel!
    @IBOutlet weak var instagramLabel: UILabel!
    @IBOutlet weak var qiitaLabel: UILabel!
    @IBOutlet weak var githubLabel: UILabel!
    @IBOutlet weak var prLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserInfo(user_id: user_id)
    }
    
    func getUserInfo(user_id: String) {
        //キーチェーンからアクセストークンを取り出す
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return print("no token") }
        
        //リクエストのURLの生成
        let url = URL(string: consts.baseUrl + "/user/" + user_id)!
        
        //ヘッダにアクセストークンを含める
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "ACCEPT": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let user = User(
                    name: json["name"].string!,
                    skill: json["skill"].string ?? "",
                    career: json["career"].string ?? "",
                    twitter: json["twitter_account"].string ?? "",
                    facebook: json["facebook_account"].string ?? "",
                    instagram: json["instagram_account"].string ?? "",
                    qiita: json["qiita_account"].string ?? "",
                    github: json["github_account"].string ?? "",
                    pr: json["self_pr"].string ?? ""
                )
                self.setUser(user: user)
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func setUser(user: User) {
    
        nameLabel.text = user.name
        skillLabel.text = user.skill
        carrerLabel.text = user.career
        twitterLabel.text = user.twitter
        facebookLabel.text = user.facebook
        instagramLabel.text = user.instagram
        qiitaLabel.text = user.qiita
        githubLabel.text = user.github
        prLabel.text = user.pr
    }
}
