//
//  ShowViewController.swift
//  WaipuroApp
//
//  Created by YUKI YOUDA on 2021/11/22.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess

class ShowViewController: UIViewController {
    
    @IBOutlet weak var due_date: UILabel!
    @IBOutlet weak var language: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var user_name: UILabel!
    @IBOutlet weak var appDescription: UILabel!
    @IBOutlet weak var period: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var gain: UILabel!
    @IBOutlet weak var caution: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    let consts = Constants.shared
    var articleID = ""
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        getShow(articleID: articleID)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getShow(articleID: articleID)
    }
    
    func getShow(articleID: String) {
        
        //キーチェーンからアクセストークンを取り出す
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return print("no token") }
        
        //リクエストのURLの生成
        let url = URL(string: consts.baseUrl + "/recruitments/" + articleID)!
        
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
                
                //レスポンスで受け取った値から、User型のオブジェクトを作成
                let show = Show(
                    name: json["name"].string!,
                    description: json["description"].string!,
                    due_date: json["due_date"].string!,
                    user_name: json["user"]["name"].string!,
                    category_name: json["category"]["name"].string!,
                    caution: json["caution"].string!,
                    comment: json["comment"].string!,
                    gain: json["gain"].string!,
                    number: json["number"].string!,
                    period: json["period"].string!
                )
                self.setShow(show: show)
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    func setShow(show: Show) {
        due_date.text = show.due_date
        language.text = show.category_name
        name.text = show.name
        user_name.text = show.user_name
        appDescription.text = show.description
        period.text = show.period
        number.text = show.number
        gain.text = show.gain
        caution.text = show.caution
        comment.text = show.comment
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
