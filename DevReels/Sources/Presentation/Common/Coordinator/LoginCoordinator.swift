//
//  LoginCoordinator.swift
//  DevReels
//
//  Created by 강현준 on 2023/05/16.
//  Copyright © 2023 DevReels. All rights reserved.
//

import UIKit
import RxSwift

// finish : 화면 전환 완료
// Back : 뒤로가기.

enum LoginCoordinatorResult {
    case finish
}

final class LoginCoordinator: BaseCoordinator<LoginCoordinatorResult> {
    
    let finish = PublishSubject<LoginCoordinatorResult>()
    
    override func start() -> Observable<LoginCoordinatorResult> {
//        showLogin()
        showEditProfile()
        return finish
    }
    
    func showLogin() {
        guard let viewModel = DIContainer.shared.container.resolve(LoginViewModel.self) else { return }
        
        viewModel.navigation
            .subscribe(onNext: { [weak self] in
                switch $0 {
                case .finish:
                    self?.finish.onNext(.finish)
                case .createUser:
                    self?.showEditProfile()
                }
            })
        let viewController = LoginViewController(viewModel: viewModel)
        push(viewController, animated: true, isRoot: true)
    }
    
    
    func showEditProfile() {
        let viewModel = EditProfileViewModel()
        
        let viewController = EditProfileViewController(viewModel: viewModel)
        push(viewController, animated: true)
    }
}
