//
//  AWPickerViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 26/11/2023.
//

import Foundation
import RxSwift
import RxDataSources

fileprivate struct SlotsData {
    let dates: [Date]
    let slots: [[DeliverySlotDTO]]
}

protocol AWPickerViewModelInput {
    var fetchDeliveryObserver: AnyObserver<Void> { get }
    var sliderSelectObserver: AnyObserver<IndexPath> { get }
    var slotSelectedObserver: AnyObserver<IndexPath> { get }
}

protocol AWPickerViewModelOutput {
    var title: Observable<String> { get }
    var sliderDataSource: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
    var slotsDataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var defaultSelection: Observable<(date: IndexPath, slot: IndexPath)?> { get }
    var loading: Observable<Bool> { get }
    var slotSelected: Observable<DeliverySlotDTO> { get }
    var error: Observable<(String, Bool)> { get }
}

protocol AWPickerViewModelType {
    var inputs: AWPickerViewModelInput { get }
    var outputs: AWPickerViewModelOutput { get }
}

class AWPickerViewModel: AWPickerViewModelType, AWPickerViewModelInput, AWPickerViewModelOutput {
    /// I/O Ports
    var inputs: AWPickerViewModelInput { self }
    var outputs: AWPickerViewModelOutput { self }
    
    /// Inputs
    var fetchDeliveryObserver: RxSwift.AnyObserver<Void> { fetchDeliverySubject.asObserver() }
    var sliderSelectObserver: AnyObserver<IndexPath> { sliderSelectedSubject.asObserver() }
    var slotSelectedObserver: AnyObserver<IndexPath> { slotSelectedSubject.asObserver() }
    
    /// Outputs
    var title: Observable<String> { titleSubject.asObservable() }
    var sliderDataSource: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { sliderDataSourceSubject.asObservable() }
    var slotsDataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { slotsDataSourceSubject.asObservable() }
    var defaultSelection: Observable<(date: IndexPath, slot: IndexPath)?> { defaultSelectionSubject.asObservable()}
    var loading: RxSwift.Observable<Bool> { loadingSubject.asObservable() }
    var slotSelected: Observable<DeliverySlotDTO> {
        Observable.combineLatest(slotSelectedSubject, sliderSelectedSubject, slotsDataSubject).compactMap { slotIndexPath, sliderIndexPath, slotsData in
            return slotsData?.slots[sliderIndexPath.row][slotIndexPath.row]
        }
    }
    var error: RxSwift.Observable<(String, Bool)> { errorSubject.asObservable() }
    
    /// Subjects
    private var titleSubject: BehaviorSubject<String> = .init(value: localizedString("lbl_change_delivery", comment: ""))
    private let sliderDataSourceSubject: BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> = .init(value: [])
    private let slotsDataSourceSubject: BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]> = .init(value: [])
    
    private let fetchDeliverySubject: PublishSubject<Void> = .init()
    private let slotsDataSubject: BehaviorSubject<SlotsData?> = .init(value: nil)
    private let sliderSelectedSubject: PublishSubject<IndexPath> = .init()
    private let defaultSelectionSubject: BehaviorSubject<(date: IndexPath, slot: IndexPath)?> = .init(value: nil)
    private let loadingSubject: BehaviorSubject<Bool> = .init(value: false)
    private let slotSelectedSubject: PublishSubject<IndexPath> = .init()
    private let selectedSlotIDSubject: BehaviorSubject<Int?> = .init(value: nil)
    private let errorSubject: BehaviorSubject<(String, Bool)> = .init(value: (localizedString("no_slot_available_message", comment: ""), false))
    
    /// Properites
    let disposeBag = DisposeBag()
    
    /// Initializations
    init(grocery: Grocery?, selectedSlotId: Int? = nil) {
        selectedSlotIDSubject.onNext(selectedSlotId)
        
        // Fetching delivery slots
        let slotsFetchResult = self.fetchDeliverySubject
            .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(true) })
            .flatMapLatest {[unowned self] in self.getDeliverySlots(groceryId: grocery?.dbID, deliveryZoneId: grocery?.deliveryZoneId) }
            .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(false) })
            .share()
        
        let slots = slotsFetchResult
            .compactMap { $0.element }
            .share()
            
        // storing slots with grouped by start date
        slots
            .map { self.groupDeliverySlotByDate(slots: $0) }
            .bind(to: slotsDataSubject)
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                slotsFetchResult
                    .compactMap { $0.error }
                    .map { _ in (localizedString("no_slot_available_message", comment: ""), true) },
                slots
                    .filter { $0.isEmpty }
                    .map { _ in (localizedString("no_slot_available_message", comment: ""), true) }
            )
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
        
        // binding slider datasource
        slotsDataSubject
            .compactMap{ $0?.dates }
            .map { $0.map { DateSliderCollectionViewCellViewModel(date: $0) } }
            .map { [SectionModel(model: 0, items: $0)] }
            .bind(to: sliderDataSourceSubject)
            .disposed(by: disposeBag)
        
        defaultSelectionSubject
            .compactMap { $0?.date }
            .bind(to: sliderSelectedSubject)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(selectedSlotIDSubject, slotsDataSubject)
            .delay(.milliseconds(10), scheduler: MainScheduler.instance)
            .filter { $0.1?.slots.isNotEmpty ?? false }
            .map { self.getSelectedIndexes(selectedId: $0, data: $1) }
            .bind(to: self.defaultSelectionSubject)
            .disposed(by: disposeBag)
        
        // binding slots datasource
        Observable
            .combineLatest(slotsDataSubject, sliderSelectedSubject)
            .filter { ($0.0?.slots.count ?? 0) > $0.1.row }
            .compactMap { $0?.slots[$1.row] }
            .map { $0.map { SlotTableViewCellViewModel(deliverySlot: $0) }}
            .map { [SectionModel(model: 0, items: $0)]}
            .bind(to: self.slotsDataSourceSubject)
            .disposed(by: disposeBag)
    }
}


// MARK: - Helpers
fileprivate extension AWPickerViewModel {
    func getDeliverySlots(groceryId: String?, deliveryZoneId: String?) -> Observable<Event<[DeliverySlotDTO]>> {
        Observable<[DeliverySlotDTO]>.create { observer in
            
            self.getDeliverySlots(groceryId: groceryId, deliveryZoneId: deliveryZoneId) { result in
                switch result {
                case .success(let slots):
                    observer.onNext(slots)
                    observer.onCompleted()
                    
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }.materialize()
    }
    
    func getDeliverySlots(groceryId: String?, deliveryZoneId: String?, completion: @escaping (Swift.Result<[DeliverySlotDTO], ElGrocerError>)->()) {
        guard let groceryId = groceryId, let deliveryZoneId = deliveryZoneId else {
            completion(.failure(.genericError()))
            return
        }
        
        if let groceryId = Int(groceryId), let deliveryZoneId = Int(deliveryZoneId) {
            let basketItems = ShoppingBasketItem.getBasketItemsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            var itemsCount = 0
            
            basketItems.forEach { basketItem in
                itemsCount += basketItem.count.intValue
            }
            
            ElGrocerApi.sharedInstance.getDeliverySlots(retailerID: groceryId, retailerDeliveryZondID: deliveryZoneId, orderID: nil, orderItemCount: itemsCount) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        
                        let data = try! JSONSerialization.data(withJSONObject: response, options: [])
                        let deliverySlots = try decoder.decode(DeliverySlotsData.self, from: data)

                        completion(.success(deliverySlots.deliverySlots ?? []))
                    } catch {
                        completion(.failure(.parsingError()))
                    }
                case .failure(let elGrocerError):
                    completion(.failure(elGrocerError))
                }
            }
        }
    }
    
    func groupDeliverySlotByDate(slots: [DeliverySlotDTO]) -> SlotsData? {
        let groupByStartDateDictionary = Dictionary(grouping: slots) { slot in
            return slot.startTime?.convertStringToCurrentTimeZoneDate()?.toFormattedString("dd-MM-yyyy") ?? ""
        }
        
        let sortedDictionary = groupByStartDateDictionary
            .sorted(by: { $0.key.toDate("dd-MM-yyyy") ?? Date() < $1.key.toDate("dd-MM-yyyy") ?? Date() })
        
        return SlotsData(dates: sortedDictionary.map { $0.key.toDate("dd-MM-yyyy") ?? Date() }, slots: sortedDictionary.map { $0.value })
    }
    
    func getSelectedIndexes(selectedId: Int?, data: SlotsData?) -> (date: IndexPath, slot: IndexPath)? {
        let slots = data?.slots.flatMap { $0 }
        let startDateArr = data?.dates

        let selectedSlot = slots?.first(where: { $0.id == selectedId || $0.usid == selectedId })

        if let startDate = selectedSlot?.startTime?.convertStringToCurrentTimeZoneDate()?.toFormattedString("dd-MM-yyyy") {
            let dateIndex = startDateArr?.index(where: { $0.day == startDate.toDate("dd-MM-yyyy")?.day }) ?? 0
            let slotIndex = data?.slots[dateIndex].firstIndex(where: { $0.id == selectedSlot?.id }) ?? 0

            return (IndexPath(row: dateIndex, section: 0), IndexPath(row: slotIndex, section: 0))
        }
        
        if selectedSlot == nil && data != nil {
            return (IndexPath(row: 0, section: 0), IndexPath(row: 0, section: 0))
        }
        
        return nil
    }
}

// MARK: Moved to extension file
extension String {
    func toDate(_ format: String = "yyyy-MM-dd'T'HH:mm:ssZ") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}

extension Date {
    func toFormattedString(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
