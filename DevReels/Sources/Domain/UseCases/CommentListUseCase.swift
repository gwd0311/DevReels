//
//  CommentListUseCase.swift
//  DevReels
//
//  Created by 강현준 on 2023/06/30.
//  Copyright © 2023 DevReels. All rights reserved.
//

import Foundation
import RxSwift

struct CommentListUseCase: CommentListUseCaseProtocol {
    var commentRepository: CommentRepositoryProtocol?
    
    func commentList(reelsID: String) -> Observable<[Comment]> {
        return commentRepository?.fetch(reelsID: reelsID) ?? .empty()
    }
}
