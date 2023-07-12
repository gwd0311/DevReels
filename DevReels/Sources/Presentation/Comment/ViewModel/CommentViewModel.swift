//
//  CommentViewModel.swift
//  DevReels
//
//  Created by 강현준 on 2023/06/30.
//  Copyright © 2023 DevReels. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum CommentNavigation {
    case back
}

final class CommentViewModel: ViewModel {
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let backButtonTapped: Observable<Void>
        let inputButtonDidTap: Observable<Void>
        let inputViewText: Observable<String>
        let selectedComment: Observable<Comment>
    }
    
    struct Output {
        let commentList: Driver<[Comment]>
        let presentAlert: Signal<Alert>
        let commentUploadCompleted: Driver<Void>
        let profileImageURL: Observable<String>
        let reels: Reels?
        let deleteAlert: Signal<Alert>
    }
    
    var commentListUseCase = DIContainer.shared.container.resolve(CommentListUseCaseProtocol.self)
    var commentUploadUseCase = DIContainer.shared.container.resolve(CommentUploadUseCaseProtocol.self)
    var loginCheckUseCase = DIContainer.shared.container.resolve(LoginCheckUseCaseProtocol.self)
    let navigation = PublishSubject<CommentNavigation>()
    private let commentList = PublishSubject<[Comment]>()
    private let currentUser = BehaviorSubject<User?>(value: nil)
    private let refresh = PublishSubject<Void>()
    private let alert = PublishSubject<Alert>()
    var reels: Reels?
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        // 알럿
        let presentAlert = PublishSubject<Alert>()
        
        Observable.merge(refresh, input.viewWillAppear)
            .withUnretained(self)
            .flatMap { viewModel, _ in
                viewModel.commentListUseCase?.commentList(reelsID: viewModel.reels?.id ?? "").asResult() ?? .empty()
            }
            .withUnretained(self)
            .subscribe(onNext: { viewModel, result in
                switch result {
                case .success(let data):
                    let sorted = data.sorted { $0.date < $1.date }
                    viewModel.commentList.onNext(sorted)
                case .failure:
                    viewModel.commentList.onNext([])
                }
            })
            .disposed(by: disposeBag)
        
        input.viewWillAppear
            .withUnretained(self)
            .flatMap { viewModel, _ in
                viewModel.loginCheckUseCase?.currentUser().asResult() ?? .empty()
            }
            .withUnretained(self)
            .subscribe(onNext: { viewModel, result in
                switch result {
                case .success(let user):
                    viewModel.currentUser.onNext(user)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .map { CommentNavigation.back }
            .bind(to: navigation)
            .disposed(by: disposeBag)
        
        input.inputButtonDidTap
            .withUnretained(self)
            .flatMap { viewModel, _ in
                viewModel.loginCheckUseCase?.loginCheck().asResult() ?? .empty()
            }
            .withUnretained(self)
            .subscribe(onNext: { _, result in
                switch result {
                case .success:
                   break
                case .failure:
                    let alert = Alert(title: "로그인이 필요합니다.", message: "댓글을 남기시려면 로그인을 하셔야 합니다. 로그인을 해주세요", observer: nil)
                    presentAlert.onNext(alert)
                }
            })
            .disposed(by: disposeBag)
        
        input.inputButtonDidTap
            .withLatestFrom(Observable.combineLatest(
                currentUser.compactMap { $0 },
                input.inputViewText))
            .map { user, commentString -> Comment in
                return Comment(
                    reelsID: self.reels?.id ?? "",
                    writerUID: user.uid,
                    writerProfileImageURL: user.profileImageURLString,
                    content: commentString,
                    writerNickName: user.nickName
                )
            }
            .withUnretained(self)
            .flatMap { viewModel, comment in
                viewModel.commentUploadUseCase?.upload(comment: comment).asResult() ?? .empty()
            }
            .withUnretained(self)
            .subscribe(onNext: { viewModel, result in
                switch result {
                case .success:
                    viewModel.refresh.onNext(())
                case .failure:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        let removeCommentAlertObserver = PublishSubject<Bool>()
        
        Observable.combineLatest(input.selectedComment, currentUser)
            .compactMap { $0 }
            .map { comment, user -> Alert? in
                if comment.writerUID == user?.uid {
                   return Alert(title: "댓글 삭제", message: "댓글을 삭제하시겠습니까?", observer: removeCommentAlertObserver.asObserver())
                }
                return nil
            }
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { viewModel, alert in
                viewModel.alert.onNext(alert)
            })
            .disposed(by: disposeBag)
        
        removeCommentAlertObserver
            .withLatestFrom(input.selectedComment)
            .withUnretained(self)
            .flatMap { $0.commentUploadUseCase?.delete(comment: $1).asResult() ?? .empty() }
            .withUnretained(self)
            .subscribe(onNext: { viewModel, result in
                switch result {
                case .success:
                    viewModel.refresh.onNext(())
                case .failure:
                    break
                }
            })
            .disposed(by: disposeBag)
      
        return Output(
            commentList: commentList.asDriver(onErrorJustReturn: []),
            presentAlert: presentAlert.asSignal(onErrorSignalWith: .empty()),
            commentUploadCompleted: refresh.asDriver(onErrorJustReturn: ()),
            profileImageURL: currentUser
                .compactMap { $0?.profileImageURLString },
            reels: reels,
            deleteAlert: alert.asSignal(onErrorSignalWith: .empty())
        )
    }
}
