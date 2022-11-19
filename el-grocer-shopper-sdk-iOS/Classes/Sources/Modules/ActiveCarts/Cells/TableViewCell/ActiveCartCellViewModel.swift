//
//  ActiveCartCellViewModel.swift
//  Adyen
//
//  Created by Rashid Khan on 14/11/2022.
//

import Foundation
import RxSwift
import RxDataSources

protocol ActiveCartCellViewModelInput {
    var nextButtonTapObserver: AnyObserver<Void> { get }
    var bannerTapObserver: AnyObserver<Void> { get }
}

protocol ActiveCartCellViewModelOutput {
    var storeIconUrl: Observable<URL?> { get }
    var storeName: Observable<String?> { get }
    var deliveryTypeIconName: Observable<String> { get }
    var deliveryText: Observable<NSAttributedString?> { get }
    var banners: Observable<[BannerDTO]> { get }
    var cellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
    var isArbic: Observable<Bool> { get }
    
    var nextButtonTap: Observable<ActiveCartDTO> { get }
    var bannerTap: Observable<String> { get }
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
    var nextButtonTapObserver: AnyObserver<Void> { self.nextButtonTapSubject.asObserver() }
    var bannerTapObserver: AnyObserver<Void> { self.bannerTapSubject.asObserver() }
    
    // MARK: Outputs
    var storeIconUrl: Observable<URL?> { storeIconUrlSubject.asObservable() }
    var storeName: Observable<String?> { storeNameSubject.asObservable() }
    var deliveryTypeIconName: Observable<String> { deliveryTypeIconNameSubject.asObservable() }
    var deliveryText: Observable<NSAttributedString?> { deliveryTextSubject.asObservable() }
    var cellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }
    var banners: Observable<[BannerDTO]> { bannersSubject.asObservable() }
    var isArbic: Observable<Bool> { isArbicSubject.asObservable() }
    var nextButtonTap: Observable<ActiveCartDTO> { nextButtonTapSubject.map { [unowned self] in self.activeCart }.asObservable() }
    var bannerTap: Observable<String> { bannerTapSubject.map { "Replace this with actual banner object" }.asObservable() }
    
    // MARK: Subject
    private var storeIconUrlSubject = BehaviorSubject<URL?>(value: nil)
    private var storeNameSubject = BehaviorSubject<String?>(value: nil)
    private var deliveryTypeIconNameSubject = BehaviorSubject<String>(value: "ClockIcon")
    private var deliveryTextSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private var bannersSubject = BehaviorSubject<[BannerDTO]>(value: [])
    private let isArbicSubject = BehaviorSubject<Bool>(value: false)
    private let nextButtonTapSubject = PublishSubject<Void>()
    private let bannerTapSubject = PublishSubject<Void>()
    private var cellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    
    // MARK: Properties
    var reusableIdentifier: String { ActiveCartTableViewCell.defaultIdentifier }
    var activeCart: ActiveCartDTO
    
    // MARK: Initlizations
    init(activeCart: ActiveCartDTO) {
        self.activeCart = activeCart
        self.cellViewModelsSubject.onNext([
            SectionModel(model: 0, items: activeCart.products.map { ActiveCartProductCellViewModel(product: $0)})
        ])
        
        self.storeIconUrlSubject.onNext(URL(string: activeCart.bgPhotoUrl ?? ""))
        self.storeNameSubject.onNext(activeCart.companyName)
        self.isArbicSubject.onNext(ElGrocerUtility.sharedInstance.isArabicSelected())
        
        self.setDeliverySlot()
        self.fetchBanner()
        
        self.bannersSubject.onNext([BannerDTO(), BannerDTO(), BannerDTO()])
    }
}

// MARK: Helper Methods
private extension ActiveCartCellViewModel {
    func setDeliverySlot() {
        let cart = self.activeCart
        
        if cart.isOpened ?? true {
            switch cart.deliveryType {
            case .instant:
                let text = NSLocalizedString("instant_delivery", bundle: .resource, comment: "")
                let attributedString = NSMutableAttributedString(string: text)
                
                attributedString.addAttribute(.font, value: UIFont.SFProDisplayNormalFont(13), range: NSRange(location: 0, length: text.count))
                attributedString.addAttribute(.foregroundColor, value: UIColor.newBlackColor(), range:NSRange(location: 0, length: text.count))
                
                self.deliveryTextSubject.onNext(attributedString)
                self.deliveryTypeIconNameSubject.onNext("ic-instant-delivery")
                break
                
            case .scheduled:
                let prefix = NSLocalizedString("lbl_next_delivery", bundle: .resource, comment: "")
                let formattedTimesString = self.formattedSlot()
                let text = prefix + formattedTimesString
                let attributedString = NSMutableAttributedString(string: text)
                
                attributedString.addAttribute(.font, value: UIFont.SFProDisplayNormalFont(13), range: NSRange(location: 0, length: prefix.count))
                attributedString.addAttribute(.font, value: UIFont.SFProDisplaySemiBoldFont(13), range: NSRange(location: prefix.count, length: formattedTimesString.count))
                attributedString.addAttribute(.foregroundColor, value: UIColor.newBlackColor(), range:NSRange(location: 0, length: text.count))
                
                self.deliveryTextSubject.onNext(attributedString)
                self.deliveryTypeIconNameSubject.onNext("ClockIcon")
            }
        } else {
            let text = NSLocalizedString("screen_active_cart_listing_store_close_message", bundle: .resource, comment: "")
            let attributedString = NSMutableAttributedString(string: text)
            
            attributedString.addAttribute(.font, value: UIFont.SFProDisplayNormalFont(13), range: NSRange(location: 0, length: text.count))
            attributedString.addAttribute(.foregroundColor, value: UIColor.textfieldErrorColor(), range:NSRange(location: 0, length: text.count))
            
            self.deliveryTextSubject.onNext(attributedString)
            self.deliveryTypeIconNameSubject.onNext("clock_red")
        }
    }
    
    func fetchBanner() {
        ElGrocerApi.sharedInstance.getBannersFor(location: .sdk_all_carts_tier_2, retailer_ids: [String(self.activeCart.id)]) { result in
            switch result {
                
            case .success(let data):
                
                break
                
            case .failure(let error):
                print("Error >>> \(error)")
                break
            }
        }
    }
    
    func formattedSlot() -> String {
        let startDate = self.activeCart.deliverySlot?.startTime
        let endDate = self.activeCart.deliverySlot?.endTime
        
        guard let startDate = startDate?.convertStringToCurrentTimeZoneDate(), let endDate = endDate?.convertStringToCurrentTimeZoneDate() else { return "N/A" }
        
        let day = startDate.getDayName() ?? ""
        let formattedStart = startDate.formatDateForCandCFormateString()
        let formattedEnd = endDate.formatDateForCandCFormateString()
        
        return " " + day + " " + formattedStart + "-" + formattedEnd
    }
}
