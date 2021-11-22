//
//  Constants.swift
//  WaipuroApp
//
//  Created by YUKI YOUDA on 2021/11/20.
//

import Foundation

struct Constants {
    static let shared = Constants()
    private init() {}
    
    let baseUrl = "http://localhost/api"
    let loginUrl = "http://localhost/api/login"
    let registerUrl = "http://localhost/api/register"
    let service = "WaipuroApp"
}
