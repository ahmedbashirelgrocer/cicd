//
//  RetailersOnLocationUseCase.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 30/11/2022.
//

import Foundation
import RxSwift
import RxCocoa

protocol RetailersOnLocationUseCaseInput {
    var launchOptionsObserver: AnyObserver<LaunchOptions> { get }
}

protocol RetailersOnLocationUseCaseOutput {
    var retailers: Observable<[RetailLight]> { get }
}

protocol RetailersOnLocationUseCaseType: RetailersOnLocationUseCaseInput, RetailersOnLocationUseCaseOutput {
    var inputs: RetailersOnLocationUseCaseInput { get }
    var outputs: RetailersOnLocationUseCaseOutput { get }
}

extension RetailersOnLocationUseCaseType {
    var inputs: RetailersOnLocationUseCaseInput { self }
    var outputs: RetailersOnLocationUseCaseOutput { self }
}

final class RetailersOnLocationUseCase: RetailersOnLocationUseCaseType {
    // Inputs
    var launchOptionsObserver: AnyObserver<LaunchOptions> { launchOptionsSubject.asObserver() }
    
    // Outputs
    var retailers: Observable<[RetailLight]> { retailersSubject.asObservable() }
    
    // Subjects
    private let launchOptionsSubject = PublishSubject<LaunchOptions>()
    private let retailersSubject = BehaviorSubject<[RetailLight]>(value: [])
    
    private let disposeBag = DisposeBag()
    
    init(with launchOptions: LaunchOptions) {
        launchOptionsSubject
            .map{ Location.init(latitude: $0.latitude ?? 0, longitude: $0.longitude ?? 0) }
            .filter{ !($0.latitude == 0 && $0.longitude == 0) }
            .distinctUntilChanged()
            .flatMap{ [unowned self] location in self.fetchRetails(location) }
            .filter{ $0.count > 0 }
            .bind(to: retailersSubject)
            .disposed(by: disposeBag)
        
        launchOptionsSubject.onNext(launchOptions)
    }
    
    private func fetchRetails(_ location: Location) -> Observable<[RetailLight]> {
        Observable<[RetailLight]>.create { observer in
            ElGrocerApi.sharedInstance.getRetailersListLight(lat: location.latitude, lng: location.longitude) { result in
                switch result {
                case .success(let data):
                    let retailers = data["data"] as? [[String: Any]]
                    observer.onNext(retailers?.map{ RetailLight(data: $0) } ?? [])
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
        .retry()
    }
    
    struct Location: Equatable {
        var latitude: Double
        var longitude: Double
    }
}
