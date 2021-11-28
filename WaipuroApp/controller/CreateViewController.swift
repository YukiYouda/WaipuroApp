//
//  CreateViewController.swift
//  WaipuroApp
//
//  Created by YUKI YOUDA on 2021/11/25.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess

class CreateViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    let consts = Constants.shared
    let okAlert = OkAlert()
    private var token = "" //アクセストークンを格納しておく変数
    var pickerView: UIPickerView = UIPickerView()
    let list = ["Laravel", "PHP", "JavaScript", "Django", "Python", "React", "Ruby", "Ruby on Rails", "Vue.js"]
    
    var languageId: Int = 1
    
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var languageField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var periodField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var due_dateField: UITextField!
    @IBOutlet weak var gainField: UITextView!
    @IBOutlet weak var cautionField: UITextView!
    @IBOutlet weak var commentField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        languageField.delegate = self
        
        descriptionField.layer.borderColor =  UIColor.placeholderText.cgColor
        descriptionField.layer.borderWidth = 0.5
        descriptionField.layer.cornerRadius = 5.0
        descriptionField.layer.masksToBounds = true
        gainField.layer.borderColor =  UIColor.placeholderText.cgColor
        gainField.layer.borderWidth = 0.5
        gainField.layer.cornerRadius = 5.0
        gainField.layer.masksToBounds = true
        cautionField.layer.borderColor =  UIColor.placeholderText.cgColor
        cautionField.layer.borderWidth = 0.5
        cautionField.layer.cornerRadius = 5.0
        cautionField.layer.masksToBounds = true
        commentField.layer.borderColor =  UIColor.placeholderText.cgColor
        commentField.layer.borderWidth = 0.5
        commentField.layer.cornerRadius = 5.0
        commentField.layer.masksToBounds = true
        
        //pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        
        let toolbar = UIToolbar(frame: CGRectMake(100, 100, 100, 100))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CreateViewController.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(CreateViewController.cancel))
        toolbar.setItems([cancelItem, doneItem], animated: true)
        
        self.languageField.inputView = pickerView
        self.languageField.inputAccessoryView = toolbar
        
        //datepicker
        datePicker.frame = CGRectMake(0, 50, self.view.frame.width, 200)
        
        datePicker.layer.cornerRadius = 5.0
        
        createDatePicker()
    }
    
    func createDatePicker(){
        
        // DatePickerModeをDate(日付)に設定
        datePicker.datePickerMode = .date
        
        // DatePickerを日本語化
        datePicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        
        // textFieldのinputViewにdatepickerを設定
        due_dateField.inputView = datePicker
        
        // UIToolbarを設定
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // Doneボタンを設定(押下時doneClickedが起動)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClicked))
        // Doneボタンを追加
        toolbar.setItems([doneButton], animated: true)
        
        // FieldにToolbarを追加
        self.due_dateField.inputAccessoryView = toolbar
    }
    
    @objc func doneClicked(){
        let dateFormatter = DateFormatter()
        
        // 持ってくるデータのフォーマットを設定
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale    = NSLocale(localeIdentifier: "ja_JP") as Locale?
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        // textFieldに選択した日付を代入
        due_dateField.text = dateFormatter.string(from: datePicker.date)
        
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    func postRequest(article: Post) {
        
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return print("no token") }
        let url = URL(string: consts.baseUrl + "/recruitments/")!
        let parameters: Parameters = [
            "name": article.name,
            "description": article.description,
            "period": article.period,
            "number": article.number,
            "due_date": article.due_date,
            "gain": article.gain,
            "caution": article.caution,
            "comment": article.comment,
            "category_id": article.language_id
        ]
        
        //ヘッダにアクセストークンを含める
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "ACCEPT": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        
        //Alamofireで投稿をリクエスト
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                //Success
            case .success(let value):
                let json = JSON(value)
                self.okAlert.showOkAlert(title: "投稿しました", message: "募集情報を送信できました", viewController: self)
                //failure
            case .failure(let err):
                self.okAlert.showOkAlert(title: "エラー", message: err.localizedDescription, viewController: self)
                print(err.localizedDescription)
            }
        }
    }
    
    func createArticle() -> Post {
        if nameField.text == "" || languageField.text == "" || descriptionField.text == "" || periodField.text == "" || numberField.text == "" || due_dateField.text == "" || gainField.text == "" || cautionField.text == "" || commentField.text == "" {
            okAlert.showOkAlert(title: "空欄があります", message: "全ての欄に入力してください。", viewController: self)
        }
        //PosiingArticle型のオブジェクトを生成して返す。
        let article = Post(
            name: nameField.text!,
            language_id: languageId,
            description: descriptionField.text!,
            period: periodField.text!,
            number: numberField.text!,
            due_date: due_dateField.text!,
            gain: gainField.text!,
            caution: cautionField.text!,
            comment: commentField.text!
        )
        return article
    }
    
    @IBAction func postRecruitment(_ sender: Any) {
        let article = createArticle()
        postRequest(article: article)
        
        nameField.text = ""
        descriptionField.text = ""
        periodField.text = ""
        numberField.text = ""
        due_dateField.text = ""
        gainField.text = ""
        cautionField.text = ""
        commentField.text = ""
        languageField.text = ""
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.languageField.text = list[row]
        languageId = row + 1
    }
    
    @objc func cancel() {
        self.languageField.text = ""
        self.languageField.endEditing(true)
    }
    
    @objc func done() {
        self.languageField.endEditing(true)
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if languageField.text == "" {
            languageField.text = "Laravel"
        }
    }
}
