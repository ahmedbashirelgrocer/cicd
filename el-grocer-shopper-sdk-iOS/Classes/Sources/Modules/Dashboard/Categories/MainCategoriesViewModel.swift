//
//  MainCategoriesViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 12/01/2023.
//

import Foundation
import RxSwift

protocol MainCategoriesViewModelInput {
    
}

protocol MainCategoriesViewModelOutput {
    func cellViewModel(forIndex indexPath: IndexPath) -> ReusableTableViewCellViewModelType
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
    // MARK: outputs
    func cellViewModel(forIndex indexPath: IndexPath) -> ReusableTableViewCellViewModelType {
        return self.cellViewModels[indexPath.row]
    }
    
    // MARK: subjects
    
    // MARK: properties
    private var apiClient: ElGrocerApi
    private var cellViewModels: [ReusableTableViewCellViewModelType] = []
    private var deliveryAddress: DeliveryAddress?
    private var grocery: Grocery?

    // MARK: initlizations
    init(apiClient: ElGrocerApi = ElGrocerApi.sharedInstance, grocery: Grocery?, deliveryAddress: DeliveryAddress?) {
        self.apiClient = apiClient
        self.grocery = grocery
        self.deliveryAddress = deliveryAddress
        
        self.fetchCategories()
    }
}

// MARK: Helper Methods
private extension MainCategoriesViewModel {
    private func fetchCategories() {
        self.apiClient.getAllCategories(self.deliveryAddress, parentCategory: nil, forGrocery: self.grocery) { result in
            switch result {
                
            case .success(let response):
                do {
                    if let rootJson = response as? [String: Any] {
                        let data = try JSONSerialization.data(withJSONObject: rootJson)
                        let categories = try JSONDecoder().decode(CategoriesResponse.self, from: data).categories
                        print(categories.count)
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
    
    private func fetchProducts(for categoryId: String) { }
}

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
    let isWeighted: Bool
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
        case isWeighted = "is_weighted"
        case message
        case pg18 = "pg_18"
        case photoUrl = "photo_url"
        case slug
    }
}
