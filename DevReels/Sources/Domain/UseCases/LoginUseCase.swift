//
//  LoginUseCase.swift
//  DevReels
//
//  Created by 강현준 on 2023/05/23.
//  Copyright © 2023 DevReels. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseAuth

struct LoginUseCase: LoginUseCaseProtocol {
        
    var authRepository: AuthRepositoryProtocol?
    var userRepository: UserRepositoryProtocol?
    var tokenRepository: TokenRepositoryProtocol?
       
    func singIn(with credential: OAuthCredential) -> Observable<Void> {
        return (authRepository?.signIn(with: credential) ?? .empty())
            .flatMap { tokenRepository?.save($0) ?? .empty() }
            .compactMap { $0 }
            .map { ($0.localId, $0.email) }
            .flatMap { userRepository?.create(uid: $0.0, email: $0.1) ?? .empty() }
            .map { _ in () }
    }
}
