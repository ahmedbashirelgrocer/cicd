//
//  FlavorsClientUseCaseType.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 16/01/2023.
//

import Foundation
import RxSwift

typealias LoadCompletion = ((Bool?,Grocery?) -> Void)?

protocol FlavorsClientUseCaseInput {
    var launchOptionsObserver: AnyObserver<LaunchOptions> { get }
}

protocol FlavorsClientUseCaseOutput {
    var flavourStore: Observable<Grocery?> { get }
}

protocol FlavorsClientUseCaseType: FlavorsClientUseCaseInput, FlavorsClientUseCaseOutput {
    var inputs: FlavorsClientUseCaseInput { get }
    var outputs: FlavorsClientUseCaseOutput { get }
}
extension FlavorsClientUseCaseType {
    var inputs: FlavorsClientUseCaseInput { self }
    var outputs: FlavorsClientUseCaseOutput { self }
}
