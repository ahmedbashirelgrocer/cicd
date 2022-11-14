//
//  ActiveCartListingViewModel.swift
//  Adyen
//
//  Created by Rashid Khan on 14/11/2022.
//

import Foundation
import RxSwift

protocol ActiveCartListingViewModelInput {
    
}

protocol ActiveCartListingViewModelOutput {
    
}

protocol ActiveCartListingViewModelType: ActiveCartListingViewModelInput, ActiveCartListingViewModelOutput {
    var inputs: ActiveCartListingViewModelInput { get }
    var outputs: ActiveCartListingViewModelOutput { get }
}

extension ActiveCartListingViewModelType {
    var inputs: ActiveCartListingViewModelInput { self }
    var outputs: ActiveCartListingViewModelOutput { self }
}

class ActiveCartListingViewModel: ActiveCartListingViewModelType {
    // MARK: Inputs
    
    // MARK: Outputs
    
    
    // MARK: Subjects
    
    
    // MARK: Properties
    private var apiClinet: ElGrocerApi
    private var disposeBag = DisposeBag()
    
    // MARK: Initlizations
    init(apiClinet: ElGrocerApi, latitude: Double, longitude: Double) {
        self.apiClinet = apiClinet
        
    }
}

// MARK: Helpers
private extension ActiveCartListingViewModel { }
