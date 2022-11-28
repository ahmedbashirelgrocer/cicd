//
//  AlgoliaApi+Extension.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 28/11/2022.
//

import Foundation
import AlgoliaSearchClient
import InstantSearch

extension AlgoliaApi {
    func searchProductQueryWithMultiStoreMultiIndex2(_ searchText : String , storeIDs : [String] , _ pageNumber : Int = 0 , _ hitsPerPage : UInt = 100 , _ brand : String = "" , _ category : String = "" , searchType: String  , completion : @escaping responseBlock ) -> Void {
        
        var filterString = ""
        
        for storeID in storeIDs{
            let facetFiltersForCurrentStoreID : String = "shops.retailer_id:\(ElGrocerUtility.sharedInstance.cleanGroceryID(storeID))"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(OROperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        
        var query = Query(searchText)
            .set(\.filters, to: filterString)
            .set(\.clickAnalytics, to: true)
            .set(\.getRankingInfo, to: true)
            .set(\.analytics, to: true)
            .set(\.analyticsTags, to: self.getAlgoliaTags(isUniversal: storeIDs.count > 1 , searchType: searchType))
      
        query.page = pageNumber
        query.hitsPerPage = Int(hitsPerPage)
        
        
        
        var filterStringRetailer = ""
        
        for storeID in storeIDs{
            let facetFiltersForCurrentStoreID : String = "id:\(ElGrocerUtility.sharedInstance.cleanGroceryID(storeID))"
            if filterStringRetailer.count == 0 {
                filterStringRetailer.append(facetFiltersForCurrentStoreID)
            }else{
                filterStringRetailer.append(OROperator)
                filterStringRetailer.append(facetFiltersForCurrentStoreID)
            }
        }
        
        
        var retailerQuery = Query(searchText)
            .set(\.filters, to: filterStringRetailer)
            .set(\.clickAnalytics, to: true)
            .set(\.getRankingInfo, to: true)
            .set(\.analytics, to: true)
            .set(\.analyticsTags, to: self.getAlgoliaTags(isUniversal: storeIDs.count > 1 , searchType: searchType))
            
        retailerQuery.page = pageNumber
        retailerQuery.hitsPerPage = Int(hitsPerPage)
        
        
        let queries: [IndexedQuery] = [
            IndexedQuery.init(indexName: algoliadefaultIndexName, query: query),
            IndexedQuery.init(indexName: algoliaRetailerIndexName, query: retailerQuery),
        ]
        
        var requestOptions = RequestOptions()
        requestOptions.headers["X-Algolia-UserToken"] = (Insights.shared(appId: algoliaApplicationID)?.userToken).map { $0.rawValue }
        
        client.multipleQueries(queries: queries) { result in
            
            if case .success(let response) = result {
                completion(response.convertHits() , nil)
            }else if case .failure (let error) = result{
                completion(nil , error)
            }
        }
    }
}
