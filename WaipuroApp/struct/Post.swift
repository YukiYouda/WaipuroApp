//
//  Post.swift
//  WaipuroApp
//
//  Created by YUKI YOUDA on 2021/11/25.
//

import Foundation

struct Post: Codable {
    let name: String
    let language_id: Int
    let description: String
    let period: String
    let number: String
    let due_date: String
    let gain: String
    let caution: String
    let comment: String
}
