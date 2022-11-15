//
//  ActiveCartCellViewModel.swift
//  Adyen
//
//  Created by Rashid Khan on 14/11/2022.
//

import Foundation
import RxSwift
import RxDataSources

protocol ActiveCartCellViewModelInput { }

protocol ActiveCartCellViewModelOutput {
    var storeIconUrl: Observable<URL?> { get }
    var storeName: Observable<String?> { get }
    var deliveryTypeIconName: Observable<String> { get }
    var deliveryText: Observable<NSAttributedString?> { get }
    var isBannerAvailable: Observable<Bool> { get }
    var cellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
}

protocol ActiveCartCellViewModelType: ActiveCartCellViewModelInput, ActiveCartCellViewModelOutput {
    var inputs: ActiveCartCellViewModelInput { get }
    var outputs: ActiveCartCellViewModelOutput { get }
}

extension ActiveCartCellViewModelType {
    var inputs: ActiveCartCellViewModelInput { self }
    var outputs: ActiveCartCellViewModelOutput { self }
}

class ActiveCartCellViewModel: ActiveCartCellViewModelType, ReusableTableViewCellViewModelType {
    // MARK: Inputs
    
    // MARK: Outputs
    var storeIconUrl: Observable<URL?> { storeIconUrlSubject.asObservable() }
    var storeName: Observable<String?> { storeNameSubject.asObservable() }
    var deliveryTypeIconName: Observable<String> { deliveryTypeIconNameSubject.asObservable() }
    var deliveryText: Observable<NSAttributedString?> { deliveryTextSubject.asObservable() }
    var cellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }
    var isBannerAvailable: Observable<Bool> { isBannerAvailableSubject.asObservable() }
    
    // MARK: Subject
    private var storeIconUrlSubject = BehaviorSubject<URL?>(value: nil)
    private var storeNameSubject = BehaviorSubject<String?>(value: nil)
    private var deliveryTypeIconNameSubject = BehaviorSubject<String>(value: "ClockIcon")
    private var deliveryTextSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private var isBannerAvailableSubject = BehaviorSubject<Bool>(value: true)
    
    
    private var cellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    
    // MARK: Properties
    var reusableIdentifier: String { ActiveCartTableViewCell.defaultIdentifier }
    var activeCart: ActiveCartDTO
    
    init(activeCart: ActiveCartDTO) {
        self.activeCart = activeCart
        self.cellViewModelsSubject.onNext([SectionModel(model: 0, items: activeCart.products.map { ActiveCartProductCellViewModel(product: $0)})])
        
        self.storeIconUrlSubject.onNext(URL(string: activeCart.bgPhotoUrl ?? ""))
        self.storeNameSubject.onNext(activeCart.companyName)
        
        self.setDeliverySlot()
    }
}

private extension ActiveCartCellViewModel {
    func setDeliverySlot() {
        let cart = self.activeCart
        
        if cart.isOpened ?? false {
            switch cart.deliveryType {
            case .instant:
                let text = NSLocalizedString("instant_delivery", comment: "")
                let attributedString = NSMutableAttributedString(string: text)
                
                attributedString.addAttribute(.font, value: UIFont.SFProDisplayNormalFont(13), range: NSRange(location: 0, length: text.count))
                attributedString.addAttribute(.foregroundColor, value: UIColor.newBlackColor(), range:NSRange(location: 0, length: text.count))
                
                self.deliveryTextSubject.onNext(attributedString)
                self.deliveryTypeIconNameSubject.onNext("ic-instant-delivery")
                break
                
            case .scheduled:
                let prefix = "Next delivery: "
                let formattedTimesString = "Wed 3pm - 4pm"
                let text = prefix + formattedTimesString
                let attributedString = NSMutableAttributedString(string: text)
                
                attributedString.addAttribute(.font, value: UIFont.SFProDisplayNormalFont(13), range: NSRange(location: 0, length: prefix.count))
                attributedString.addAttribute(.font, value: UIFont.SFProDisplaySemiBoldFont(13), range: NSRange(location: prefix.count, length: formattedTimesString.count))
                attributedString.addAttribute(.foregroundColor, value: UIColor.newBlackColor(), range:NSRange(location: 0, length: text.count))
                
                self.deliveryTextSubject.onNext(attributedString)
                self.deliveryTypeIconNameSubject.onNext("ClockIcon")
            }
        } else {
            let text = NSLocalizedString("screen_store_listing_store_close_message", comment: "")
            let attributedString = NSMutableAttributedString(string: text)
            
            attributedString.addAttribute(.font, value: UIFont.SFProDisplayNormalFont(13), range: NSRange(location: 0, length: text.count))
            attributedString.addAttribute(.foregroundColor, value: UIColor.textfieldErrorColor(), range:NSRange(location: 0, length: text.count))
            
            self.deliveryTextSubject.onNext(attributedString)
            self.deliveryTypeIconNameSubject.onNext("clock_red")
        }
    }
}
