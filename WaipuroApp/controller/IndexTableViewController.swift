//
//  IndexTableViewController.swift
//  WaipuroApp
//
//  Created by YUKI YOUDA on 2021/11/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess
import Kingfisher

class IndexTableViewController: UITableViewController {
    let consts = Constants.shared
    var recruitments: [Recruitment] = []
    
    func getIndex(){
        //キーチェーンからアクセストークンを取り出す
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return print("no token") }
        
        //リクエストのURLの生成
        let url = URL(string: consts.baseUrl + "/recruitments")!
        
        //ヘッダにアクセストークンを含める
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "ACCEPT": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        //Alamofireでリクエストする
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                //successの時
            case .success(let value):
                self.recruitments = []
                //SwiftyJSONでDecode
                let json = JSON(value).arrayValue

                //jsonから記事1件ずつの情報を取り出してRecruitment型のオブジェクトをつくり、配列に追加
                for recruitment in json {
                    let article = Recruitment(
                        name: recruitment["name"].string!,
                        description: recruitment["description"].string!,
                        due_date: recruitment["due_date"].string!,
                        user_name: recruitment["user"]["name"].string!,
                        category_name: recruitment["category"]["name"].string!,
                        id: recruitment["id"].int!
                    )
                    self.recruitments.append(article)
                }
                //自分の投稿記事一覧のテーブルビューを更新
                self.Index.reloadData()
                //failureの時
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Index.dataSource = self
        Index.delegate = self
        getIndex()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recruitments.count
    }
    
    @IBOutlet var Index: UITableView!
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IndexCell", for: indexPath)
        
        let category = cell.viewWithTag(1) as! UILabel
        category.text = recruitments[indexPath.row].category_name
        
        
        let duedate = cell.viewWithTag(2) as! UILabel
        duedate.text = recruitments[indexPath.row].due_date
        
        let apname = cell.viewWithTag(3) as! UILabel
        apname.text = recruitments[indexPath.row].name
        
        let description = cell.viewWithTag(4) as! UILabel
        description.text = recruitments[indexPath.row].description
        
        let user_name = cell.viewWithTag(5) as! UILabel
        user_name.text = recruitments[indexPath.row].user_name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * 0.5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //編集・削除画面を生成
        let showVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowVC") as! ShowViewController
        //選択された記事の固有のIDを編集・削除画面の変数に渡す
        showVC.articleID = String(recruitments[indexPath.row].id)
        showVC.modalPresentationStyle = .fullScreen
        //編集・削除画面を表示!
        present(showVC, animated: true, completion: nil)
    }
}
