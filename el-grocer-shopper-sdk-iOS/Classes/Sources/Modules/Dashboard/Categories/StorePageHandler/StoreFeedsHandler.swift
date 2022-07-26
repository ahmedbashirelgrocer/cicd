//
//  StoreFeedsHandler.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 14/09/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation

enum ListLoadingOrder {
    case storePage
}
class StoreFeedsHandler {
    
    private var delegate : StoreFeedsDelegate?
    private var categories : [Category] = []
    var feeds : [StoreFeeds] = []
    var grocery : Grocery?
    var type : ListLoadingOrder {
        didSet {
            elDebugPrint("test")
        }
    }
    //Mark:- init
    init(_ type : ListLoadingOrder = .storePage , grocery : Grocery? , delegate : StoreFeedsDelegate) {
        self.type = type
        self.grocery = grocery
        self.delegate = delegate
    }
    
    func resetFeeds() {
        self.feeds.removeAll()
        self.setData()
        self.delegate?.fetchingCompleted(-1)
    }
    
    func setData() {
        if type == .storePage {
            self.setStorePageDataOrder()
        }else {
            self.setDefaultDataOrder (nil)
        }
    }
    
    // Mark:- Data Format
    func setStorePageDataOrder () {
        var tableCellIndex : Int = 0
        self.feeds.append(StoreFeeds.init(type: .Banner , index : tableCellIndex , grocery : self.grocery , delegate: delegate))
        tableCellIndex += 1
        self.feeds.append(StoreFeeds.init(type: .ListOfCategories , index : tableCellIndex, grocery : self.grocery , delegate: delegate))
        tableCellIndex += 1
        self.feeds.append(StoreFeeds.init(type: .Purchased , index : tableCellIndex, grocery : self.grocery ,  delegate: delegate))
        elDebugPrint("FeedCount : \(self.feeds.count)")
    }
    
    func setCategoriesForStorePage(_ categories : [Category]?) {
        
        if let data = categories {
            self.categories = data
        }
        var tableCellIndex = self.feeds.count - 1
        for (index , category) in self.categories.enumerated() {
            tableCellIndex += 1
            let feed = StoreFeeds.init(type: .TopSelling, category: category  , index : tableCellIndex , grocery : self.grocery , delegate: delegate)
            self.feeds.append(feed)
            if index < 5 {
                feed.getData()
            }else{
                feed.isRunning = false
                feed.isLoaded.value = false
            }
            if index == 0 {
                tableCellIndex += 1
                let bannerFeed = StoreFeeds.init(type: .Banner , index : tableCellIndex, grocery : self.grocery , delegate: delegate)
                self.feeds.append(bannerFeed)
                bannerFeed.getData()
            }
            
        }
        elDebugPrint("FeedCount : \(self.feeds.count)")
        
        
    }
    
    
    func setDefaultDataOrder (_ categories : [Category]?) {
        if let data = categories {
            self.categories = data
        }
        for (index , category) in self.categories.enumerated() {
            self.feeds.append(StoreFeeds.init(type: .TopSelling, category: category  , index : index, grocery: self.grocery , delegate: delegate))
        }
        elDebugPrint("FeedCount : \(self.feeds.count)")
    }
}
