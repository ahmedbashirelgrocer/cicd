//
//  UserDataPreloadManager.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 04/12/2022.
//

//import Foundation
//import RxSwift
//
//class UserDataPreloadManager {
//
//    var isDataLoaded: Bool = false
//    var disposeBag = DisposeBag()
//    var completion: ((Bool) -> Void)?
//
//    init(launchOptions: LaunchOptions, completion: ((Bool) -> Void)? ) {
//        self.completion = completion
//        let dataPreLoadUseCase = DataPreLoadUseCase.init(launchOptions: launchOptions)
//        dataPreLoadUseCase.outputs.loadingStatus
//            .subscribe(onNext: { [weak self] status in
//                if status == .didLoadData {
//                    self?.isDataLoaded = true
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        self?.completion?(true)
//                    }
//                }
//            })
//            .disposed(by: disposeBag)
//    }
//}
