//
//  MainCategoriesViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 12/01/2023.
//

import Foundation
import RxSwift
import RxDataSources

protocol MainCategoriesViewModelInput {
    var scrollObserver: AnyObserver<IndexPath> { get }
}

protocol MainCategoriesViewModelOutput {
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var loading: Observable<Bool> { get }
}

protocol MainCategoriesViewModelType: MainCategoriesViewModelInput, MainCategoriesViewModelOutput {
    var inputs: MainCategoriesViewModelInput { get }
    var outputs: MainCategoriesViewModelOutput { get }
}

extension MainCategoriesViewModelType {
    var inputs: MainCategoriesViewModelInput { self }
    var outputs: MainCategoriesViewModelOutput { self }
}


class MainCategoriesViewModel: MainCategoriesViewModelType {
    // MARK: Inputs
    var scrollObserver: AnyObserver<IndexPath> { self.scrollSubject.asObserver() }
    
    // MARK: outputs
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { self.cellViewModelsSubject.asObservable() }
    var loading: Observable<Bool> { self.loadingSubject.asObservable() }
    
    // MARK: subjects
    private var cellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    private var scrollSubject = PublishSubject<IndexPath>()
    
    // MARK: properties
    private var apiClient: ElGrocerApi
    private var deliveryAddress: DeliveryAddress?
    private var grocery: Grocery?
    
    private var categories = [CategoryDTO]()
    private var bannerVMs = [ReusableTableViewCellViewModelType]()
    private var homeCellVMs = [ReusableTableViewCellViewModelType]()
    
    private var dispatchGroup = DispatchGroup()
    private var disposeBag = DisposeBag()
    private var apiCallingStatus: [IndexPath: Bool] = [:]

    // MARK: initlizations
    init(apiClient: ElGrocerApi = ElGrocerApi.sharedInstance, grocery: Grocery?, deliveryAddress: DeliveryAddress?) {
        self.apiClient = apiClient
        self.grocery = grocery
        self.deliveryAddress = deliveryAddress
        
        self.fetchGroceryDeliverySlots()
        self.fetchBanners(for: .store_tier_1)
        
        self.loadingSubject.onNext(true)
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            self.cellViewModelsSubject.onNext([
                SectionModel(model: 0, items: self.bannerVMs),
                SectionModel(model: 1, items: [CategoriesCellViewModel(categories: self.categories)]),
                SectionModel(model: 2, items: self.homeCellVMs),
            ])
            self.loadingSubject.onNext(false)
        }
        
        self.scrollSubject.asObservable().subscribe(onNext: { indexPath in
            if self.apiCallingStatus[indexPath] == nil && indexPath.section == 2 {
                guard let vm = self.homeCellVMs[indexPath.row] as? HomeCellViewModel else { return }
                
                vm.inputs.fetchProductsObserver.onNext(self.categories[indexPath.row])
                self.apiCallingStatus[indexPath] = true
            }
        }).disposed(by: self.disposeBag)
    }
}

// MARK: Helper Methods
private extension MainCategoriesViewModel {
    func fetchGroceryDeliverySlots() {
        self.dispatchGroup.enter()
        
        self.apiClient.getGroceryDeliverySlotsWithGroceryId(self.grocery?.dbID, andWithDeliveryZoneId: self.grocery?.deliveryZoneId, false) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                do {
                    if let rootJson = response as? [String: Any] {
                        let data = try JSONSerialization.data(withJSONObject: rootJson)
                        let deliverySlotsResponse = try JSONDecoder().decode(DeliverySlotsResponse.self, from: data)

                        if let selectedSlot = deliverySlotsResponse.data.deliverySlots?.first, let deliveryTime = selectedSlot.timeMilli {
                            self.fetchCategories(deliveryTime: deliveryTime)
                            self.fetchPreviousPurchasedProducts(deliveryTime: deliveryTime)
                        }
                        return
                    }

                    // handle parsing error
                } catch {
                    // handle parsing error
                    print("parsing error >> \(error)")
                }
                
                break
                
            case .failure(_):
                break
            }
        }
    }
    
    func fetchCategories(deliveryTime: Int) {
        self.apiClient.getAllCategories(self.deliveryAddress, parentCategory: nil, forGrocery: self.grocery, deliveryTime: deliveryTime) { [weak self] result in
            guard let self = self else { return }
            
            self.dispatchGroup.leave()
            switch result {
                
            case .success(let response):
                do {
                    if let rootJson = response as? [String: Any] {
                        let data = try JSONSerialization.data(withJSONObject: rootJson)
                        let categories = try JSONDecoder().decode(CategoriesResponse.self, from: data).categories
                        
                        self.categories = categories
                        self.homeCellVMs = self.categories.map { HomeCellViewModel(apiClient: self.apiClient, category: $0, grocery: self.grocery, deliveryTime: deliveryTime) }
                        return
                    }
                    
                    // handle parsing error
                } catch {
                    // handle parsing error
                    print("parsing error >> \(error)")
                }
                break
                
            case .failure(let error):
                // handle error
                break
            }
        }
    }
    
    func fetchBanners(for location: BannerLocation) {
        self.dispatchGroup.enter()
        self.apiClient.getBannersFor(location: location.getType(), retailer_ids: [ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID)]) { [weak self] result in
            guard let self = self else { return }
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let response):
                do {
                    if let rootJson = response as? [String: Any] {
                        let data = try JSONSerialization.data(withJSONObject: rootJson)
                        let banners = try JSONDecoder().decode(CampaignsResponse.self, from: data).data
                        self.bannerVMs.append(GenericBannersCellViewModel(banners: banners))
                        return
                    }
                    
                    // handle parsing error
                } catch {
                    // handle parsing error
                    print("parsing error >> \(error)")
                }
                break
                
            case .failure(let error):
                break
            }
        }
    }
    
    func fetchPreviousPurchasedProducts(deliveryTime: Int?) {
        if !UserDefaults.isUserLoggedIn() {
            return
        }
    
        let parameters = NSMutableDictionary()
        parameters["limit"] = 10
        parameters["offset"] = 0
        parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID)
        parameters["shopper_id"] = UserDefaults.getLogInUserID()
        parameters["delivery_time"] =  deliveryTime as AnyObject
        
        self.dispatchGroup.enter()
        ElGrocerApi.sharedInstance.getTopSellingProductsOfGrocery(parameters , false) { [weak self] (result) in
            guard let self = self else { return }
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let response):
                do {
                    if let rootJson = response as? [String: Any] {
                        let data = try JSONSerialization.data(withJSONObject: rootJson)
                        let products = try JSONDecoder().decode(ProductResponse.self, from: data).data
                        
                        return
                    }
                    
                    // handle parsing error
                } catch {
                    // handle parsing error
                    print("parsing error >> \(error)")
                }
                break
            case .failure(let error):
                break
            }
        }
    }
}


// MARK: DTOs
struct CategoriesResponse: Codable {
    let status: String
    let categories: [CategoryDTO]
    
    enum CodingKeys: String, CodingKey {
        case status
        case categories = "data"
    }
}

struct CategoryDTO: Codable {
    let id: Int
    let name: String
    let coloredImageUrl: String?
    let description: String?
    let isFood: Bool
    let isShowBrand: Bool
    let message: String
    let pg18: Bool // ask backend for type of this
    let photoUrl: String?
    let slug: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case coloredImageUrl = "colored_img_url"
        case description
        case isFood = "is_food"
        case isShowBrand = "is_show_brand"
        case message
        case pg18 = "pg_18"
        case photoUrl = "photo_url"
        case slug
    }
}

// MARK: - ProductResponse
struct ProductResponse: Codable {
    let status: String?
    let data: [ProductDTO]
}

struct ProductDTO: Codable {
    let id: Int
    let retailerID: Int?
    let name, slug, description, barcode: String?
    let imageURL, fullImageURL: String?
    let sizeUnit: String?
    let fullPrice: Double?
    let priceCurrency: String?
    let promotion: Bool?
    let brand: BrandDTO?
    let categories, subcategories: [CategoryDTO]?
    let isAvailable, isPublished, isP: Bool?
    let availableQuantity: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case retailerID = "retailer_id"
        case name, slug, description, barcode
        case imageURL = "image_url"
        case fullImageURL = "full_image_url"
        case sizeUnit = "size_unit"
        case fullPrice = "full_price"
        case priceCurrency = "price_currency"
        case promotion, brand, categories, subcategories
        case isAvailable = "is_available"
        case isPublished = "is_published"
        case isP = "is_p"
        case availableQuantity = "available_quantity"
    }
    
    // added this method for parsing Algolia response
    static func fromDictionary(dictionary: [[String: Any]]) -> [ProductDTO] {
        var results = [ProductDTO]()

        dictionary.forEach { productDictionary in
            let id = productDictionary["id"] as! Int
            let imageUrl = productDictionary["photo_url"] as? String
            let name = productDictionary["name"] as? String

            let product = ProductDTO(id: id, retailerID: nil, name: name, slug: nil, description: nil, barcode: nil, imageURL: imageUrl, fullImageURL: nil, sizeUnit: nil, fullPrice: nil, priceCurrency: nil, promotion: nil, brand: nil, categories: nil, subcategories: nil, isAvailable: false, isPublished: false, isP: false, availableQuantity: nil)
            
            results.append(product)
        }

        return results

    }
}
