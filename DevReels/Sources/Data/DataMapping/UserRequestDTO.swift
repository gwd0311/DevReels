//
//  UserRequestDTO.swift
//  DevReels
//
//  Created by 강현준 on 2023/07/03.
//  Copyright © 2023 DevReels. All rights reserved.
//

import Foundation

struct UserRequestDTO: Encodable {
    let identifier: String
    let profileImageURLString: String
    let nickName: String
    let githubURL: String
    let blogURL: String
    let introduce: String
    let uid: String
    
    init(user: User) {
        self.identifier = user.identifier
        self.profileImageURLString = user.profileImageURLString
        self.nickName = user.nickName
        self.githubURL = user.githubURL
        self.blogURL = user.blogURL
        self.introduce = user.introduce
        self.uid = user.uid
    }
    
    // 회원가입시
    init(uid: String, email: String) {
        self.identifier = email
        self.profileImageURLString = ""
        self.nickName = ""
        self.githubURL = ""
        self.blogURL = ""
        self.introduce = ""
        self.uid = uid
    }
}
