//
//  RecipeDataHandler.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 19/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//


import Foundation
import FirebaseCrashlytics

protocol RecipeDataHandlerDelegate : class {
    // All optional
    func chefList(chefTotalA : [CHEF]) -> Void
    func recipeCatogeiresList(categoryTotalA : [RecipeCategoires]) -> Void
    func recipeList(recipeTotalA : [Recipe]) -> Void
    func recipeDetial(_ recipe : Recipe ) -> Void
    func addToCartCompleted() -> Void

}

extension RecipeDataHandlerDelegate {
    func chefList(chefTotalA : [CHEF]) -> Void {}
    func recipeCatogeiresList(categoryTotalA : [RecipeCategoires]) -> Void{}
    func recipeList(recipeTotalA : [Recipe]) -> Void{}
    func recipeDetial(_ recipe : Recipe ) -> Void{}
    func addToCartCompleted() -> Void{}
}

class RecipeDataHandler {
    
    weak var delegate : RecipeDataHandlerDelegate?
    private let KMaxDataGetLimit = "10"
    private let KSuccess = "success"
    private var apiHandler: ELGrocerRecipeMeduleAPI = {
        return ELGrocerRecipeMeduleAPI()
    }()
    lazy private(set) var chefList : [CHEF] = [CHEF]()
    lazy private(set) var recipeCategoryList : [RecipeCategoires] = [RecipeCategoires]()
    lazy private(set) var recipeList : [Recipe] = [Recipe]()
    private(set) var selectRecipeCategoires : RecipeCategoires?
    private(set) var selectChef : CHEF?
    var isSaveRecipe : Bool?
    var isApiCalling : Bool = false
//    func getAllChefList() -> Void {
//        let startingIndex  = String(describing: chefList.count)
//        apiHandler.getChefList(offset: startingIndex , Limit: "1000", chefID: "") { [weak self](result) in
//            guard let self = self else {return}
//            switch result {
//            case .success(let response):
//                guard (response["status"] as? String) == self.KSuccess else {
//                    return
//                }
//                if let arrayData = response["data"] {
//                    let chefData : [NSDictionary] = arrayData as! [NSDictionary]
//                    if (chefData.count) > 0 {
//                        self.chefList.removeAll()
//                        for data:NSDictionary in chefData {
//                            let chef : CHEF   =   CHEF.init(chefDict: data as! Dictionary<String, Any>)
//                            self.chefList.append(chef)
//                        }
//                    }
//                }
//                self.sendChefListData()
//            case .failure(let error):
//                error.showErrorAlert()
//            }
//
//        }
//    }
    
    func getAllChefList(retailerString : String , _ isForceZeroIndex : Bool = false) -> Void {
        var startingIndex  = String(describing: chefList.count)
        if isForceZeroIndex {
            startingIndex = "0"
        }
        debugPrint("callforchef: \(retailerString)")
        apiHandler.getChefList(offset: startingIndex , Limit: "1000", chefID: "" , retailerIDs: retailerString) { [weak self](result) in
            guard let self = self else {return}
            switch result {
            case .success(let response):
                guard (response["status"] as? String) == self.KSuccess else {
                    return
                }
                if let arrayData = response["data"] {
                    let chefData : [NSDictionary] = arrayData as! [NSDictionary]
                    if (chefData.count) > 0 {
                        self.chefList.removeAll()
                        for data:NSDictionary in chefData {
                            let chef : CHEF   =   CHEF.init(chefDict: data as! Dictionary<String, Any>)
                            self.chefList.append(chef)
                        }
                    }
                }
                self.sendChefListData()
            case .failure(let error):
                error.showErrorAlert()
            }
            
        }
    }
    
    
    func getNextChefList(retailerString : String) -> Void {
        let startingIndex  = String(describing: chefList.count)
        apiHandler.getChefList(offset: startingIndex , Limit: "10", chefID: "" , retailerIDs: retailerString) { [weak self](result) in
            guard let self = self else {return}

            switch result {
            case .success(let response):
                guard (response["status"] as? String) == self.KSuccess else {
                    return
                }
                if let arrayData = response["data"] {
                    let chefData : [NSDictionary] = arrayData as! [NSDictionary]
                    if (chefData.count) > 0 {
                        for data:NSDictionary in chefData {
                            let chef : CHEF   =   CHEF.init(chefDict: data as! Dictionary<String, Any>)
                            self.chefList.append(chef)
                        }
                    }
                }
                self.sendChefListData()
            case .failure(let error):
                error.showErrorAlert()
            }

        }
    }
    func getNextRecipeCategoryList(retailerId : String? , shoperId : String?) -> Void {
        let startingIndex  = String(describing: recipeCategoryList.count)
        apiHandler.getCategoryList(retailerId : retailerId , shoperId: shoperId, offset: startingIndex, Limit: "100000") { [weak self](result) in
            guard let self = self else {return}
            switch result {
            case .success(let response):
                guard (response["status"] as? String) == self.KSuccess else {
                    return
                }
                if shoperId != "" || shoperId != nil {
                    self.recipeCategoryList.removeAll()
                }
                if let arrayData = response["data"] {
                    let categoryData : [NSDictionary] = arrayData as! [NSDictionary]
                    if (categoryData.count) > 0 {
                        for data:NSDictionary in categoryData {
                            let category : RecipeCategoires   = RecipeCategoires.init(categoryID: data.object(forKey: "id") as? Int64, categoryName: data.object(forKey: "name") as? String, categorIymageURL: data.object(forKey: "image_url") as? String)
                            self.recipeCategoryList.append(category)
                        }
                    }
                }
                self.sendRecipeCategoryListData()
            case .failure(let error):
                error.showErrorAlert()
            }
        }
    }
    /**
     ======    Sucess Response       ========
     {
     "id": 1,
     "name": "Chicken Makhni Handi",
     "category_id": 2,
     "prep_time": 25,
     "cook_time": 30,
     "description": "Not Specific",
     "for_people": 2,
     "is_published": true,
     "image_url": "/system/recipes/photos/000/000/001/original/Chicken-Pad-Thai-3-688x459.jpg?1555528402",
     "chef": {
     "id": 1,
     "name": "Mehboob Khan",
     "image_url": "/system/chefs/photos/000/000/001/original/ChefMehboobKhan.jpg?1553168353",
     "insta": "@chefmahboobkhan",
     "blog": "http://thecookbook.pk/mehboob-khan/"
     }
     */
    //sab
//    func getNextRecipeList() -> Void {
//        let startingIndex  = String(describing: recipeList.count)
//        apiHandler.getRecipeList(offset: startingIndex, Limit: KMaxDataGetLimit, recipeID: nil , ChefID: nil  , nil , categoryID: nil) {  [weak self] (result) in
//            guard let self = self else {return}
//            switch result {
//            case .success(let response):
//                guard (response["status"] as? String) == self.KSuccess else {
//                    return
//                }
//                if let arrayData = response["data"] {
//                    let categoryData : [NSDictionary] = arrayData as! [NSDictionary]
//                    if (categoryData.count) > 0 {
//                        for data:NSDictionary in categoryData {
//                            let recipe : Recipe = Recipe.init(recipeData: data as! Dictionary<String, Any>)
//                            self.recipeList.append(recipe)
//                        }
//                    }
//                }
//                self.sendRecipeListData()
//            case .failure(let error):
//                error.showErrorAlert()
//            }
//
//        }
//
//    }
    
    
  
    
    
    func getNextRecipeList(retailersId : String , categroryId : Int64? , limit : String = "10" , _ isForceZeroIndex : Bool = false) -> Void {
        var startingIndex  = String(describing: recipeList.count)
        if isForceZeroIndex {
            startingIndex = "0"
        }
        debugPrint("callforrecipe:\(retailersId)")
        apiHandler.getRecipeListNew(offset: startingIndex, Limit: limit, recipeID: nil, ChefID: nil, shopperID: nil, categoryID: categroryId, retailerIDs: retailersId) {
            [weak self] (result) in
            guard let self = self else {return}
            switch result {
            case .success(let response):
                guard (response["status"] as? String) == self.KSuccess else {
                    return
                }
                self.recipeList.removeAll()
                if let arrayData = response["data"] {
                    let categoryData : [NSDictionary] = arrayData as! [NSDictionary]
                    if (categoryData.count) > 0 {
                        for data:NSDictionary in categoryData {
                            let recipe : Recipe = Recipe.init(recipeData: data as! Dictionary<String, Any>)
                            self.recipeList.append(recipe)
                        }
                    }
                }
                self.sendRecipeListData()
            case .failure(let error):
                error.showErrorAlert()
            }

        }

    }
    
    func getSavedRecipeList(shopperId : String , categoryId : String?) -> Void {
        apiHandler.getSavedRecipeList(shopperID: shopperId , categoryId : categoryId){
            [weak self] (result) in
            guard let self = self else {return}
            switch result {
            case .success(let response):
                guard (response["status"] as? String) == self.KSuccess else {
                    return
                }
                self.recipeList.removeAll()
                if let arrayData = response["data"] {
                    let categoryData : [NSDictionary] = arrayData as! [NSDictionary]
                    if (categoryData.count) > 0 {
                        for data:NSDictionary in categoryData {
                            let recipe : Recipe = Recipe.init(recipeData: data as! Dictionary<String, Any>)
                            self.recipeList.append(recipe)
                        }
                    }
                }
                self.sendRecipeListData()
            case .failure(let error):
                error.showErrorAlert()
            }

        }

    }

    
    
//    func getNextRecipeListWithFilter(recipeID : Int64? , chefID : Int64? , categoryID : Int64? , withReset isNeedToReset : Bool) -> Void {
//        let startingIndex  = isNeedToReset ? "0" : String(describing: recipeList.count)
//        apiHandler.getRecipeList(offset: startingIndex, Limit: KMaxDataGetLimit, recipeID: recipeID, ChefID: chefID  , nil , categoryID: categoryID) {  [weak self] (result) in
//            guard let self = self else {return}
//            switch result {
//            case .success(let response):
//                guard (response["status"] as? String) == self.KSuccess else {
//                    return
//                }
//                if let arrayData = response["data"] {
//                    let categoryData : [NSDictionary] = arrayData as! [NSDictionary]
//                    if isNeedToReset { self.resetRecipeList() }
//                    if (categoryData.count) > 0 {
//                        for data:NSDictionary in categoryData {
//                            let recipe : Recipe = Recipe.init(recipeData: data as! Dictionary<String, Any>)
//                            self.recipeList.append(recipe)
//                        }
//                    }
//                    if self.recipeList.count > 0 {
//                        let serialQueue = DispatchQueue(label: "com.recipeList.SyncSerial")
//                        serialQueue.sync {
//                           ElGrocerUtility.sharedInstance.recipeList[String(describing: chefID)] = self.recipeList
//                        }
//                    }
//                }
//                self.sendRecipeListData()
//            case .failure(let error):
//                error.showErrorAlert()
//            }
//        }
//    }
    func getNextRecipeListWithFilter(recipeID : Int64? , chefID : Int64? , categoryID : Int64? , withReset isNeedToReset : Bool , retailersId : String) -> Void {
        
        guard !isApiCalling else {return}
        self.isApiCalling = true
        let startingIndex  = isNeedToReset ? "0" : String(describing: recipeList.count)
        apiHandler.getRecipeListNew(offset: startingIndex, Limit: KMaxDataGetLimit, recipeID: recipeID, ChefID: chefID, shopperID: nil, categoryID: categoryID, retailerIDs: retailersId) {
            [weak self] (result) in
            guard let self = self else {return}
            self.isApiCalling = false
            switch result {
            case .success(let response):
                guard (response["status"] as? String) == self.KSuccess else {
                    return
                }
                if let arrayData = response["data"] {
                    let categoryData : [NSDictionary] = arrayData as! [NSDictionary]
                    if isNeedToReset { self.resetRecipeList() }
                    if (categoryData.count) > 0 {
                        for data:NSDictionary in categoryData {
                            let recipe : Recipe = Recipe.init(recipeData: data as! Dictionary<String, Any>)
                            self.recipeList.append(recipe)
                        }
                    }
                    if self.recipeList.count > 0 {
                        let serialQueue = DispatchQueue(label: "com.recipeList.SyncSerial")
                        serialQueue.sync {
                           ElGrocerUtility.sharedInstance.recipeList[String(describing: chefID)] = self.recipeList
                        }
                    }
                }
                self.sendRecipeListData()
            case .failure(let error):
                error.showErrorAlert()
            }
        }
    }
    
    func saveRecipeApiCall(recipeID : Int64 , isSave : Bool, completionHandler:@escaping (Bool) -> Void) -> Void {
        
        var spinerView : SpinnerView? = nil
        if let topVc = UIApplication.topViewController() {
            spinerView = SpinnerView.showSpinnerViewInView(topVc.view)
        }
        apiHandler.postSaveRecipe(recipe_id: recipeID, isSaved: isSave) {
            [weak self] (result) in
            guard let self = self else {return}
            spinerView?.removeFromSuperview()
            switch result {
            case .success(let response):
                guard (response["status"] as? String) == self.KSuccess else {
                    return
                }
                if let Data = response["data"] as? NSDictionary{
                    if let message = Data["message"] as? String{
                        if message.elementsEqual("ok"){
                            completionHandler(true)
                        }else{
                            completionHandler(false)
                        }
                        
                    }
                    
                }
                
            case .failure(let error):
                print(error)
                spinerView?.removeFromSuperview()
                completionHandler(false)
            }
        }
    }


    func getRecipeElasticSearchedList( searchString : String? , chefID : Int64? , categoryID : Int64? , retailerId : String , storeType_iDs : String , groupIds : [String] , withReset isNeedToReset : Bool) -> Void {
        let pageFraction  = (Double(recipeList.count) / 10.0).rounded(.up) + 1
        let pageNumber  = isNeedToReset ? 0 : pageFraction
        
        AlgoliaApi.sharedInstance.searchQueryForRecipe(searchString ?? "", pageNumber: Int(pageNumber) , retailerId: retailerId, storeIds: storeType_iDs, groupIds: groupIds , categoryId: categoryID , chefId: chefID) { [weak self] (content , error ) in
            
            guard let self = self else {return}
            if error != nil {
              
            } else if content != nil {
           
                if let categoryData = content?["hits"] as? [NSDictionary] {
                     debugPrint(categoryData)
                    if isNeedToReset { self.resetRecipeList() ; self.resetCategoryList() }
                    
                    if (categoryData.count) > 0 {
                        for data:NSDictionary in categoryData {
                            let recipe : Recipe = Recipe.init(recipeData: data as! Dictionary<String, Any> )
                            self.recipeList.append(recipe)
                            var categoryList : [NSDictionary] = []
                            if let categoryListdata = data["categories"] as? [NSDictionary] {
                                categoryList = categoryListdata
                            }
                            if categoryID == nil {
                                for cate in categoryList {
                                    var name = cate["name"] as? String
                                    if ElGrocerUtility.sharedInstance.isArabicSelected() {
                                        let arabicName = cate["name_ar"] as? String
                                        if !(arabicName?.contains("null") ?? true) && arabicName?.count ?? 0 > 0 {
                                            name = arabicName
                                        }
                                    }
                                    let cate : RecipeCategoires = RecipeCategoires.init(categoryID: cate["id"] as? Int64, categoryName: name , categorIymageURL: cate["image_url"] as? String)
                                    self.recipeCategoryList.append(cate)
                                }
                                self.recipeCategoryList = self.recipeCategoryList.unique { $0.categoryID }
                            }
                            
                        }
                    }
                }
                if categoryID == nil {
                    self.sendRecipeCategoryListData()
                }
                self.sendRecipeListData()
                
            }
            
            
            
        }
      
/*
        apiHandler.getRecipeListFromSearch(pageNumber: Int(pageNumber) , searchString: searchString , ChefID: chefID, categoryID: categoryID) { [weak self] (result) in
            guard let self = self else {return}
            switch result {
            case .success(let response):
                guard (response["status"] as? String) == self.KSuccess else {
                    return
                }
                if let arrayData = response["data"] {
                    let categoryData : [NSDictionary] = arrayData as! [NSDictionary]
                    if isNeedToReset { self.resetRecipeList() }
                    if (categoryData.count) > 0 {
                        for data:NSDictionary in categoryData {
                            let recipe : Recipe = Recipe.init(recipeData: data["_source"] as! Dictionary<String, Any>)
                            self.recipeList.append(recipe)
                        }
                    }
                }
                self.sendRecipeListData()
            case .failure(let error):
                if error.code == 10000 {
                    // cancel operation
                }else{
                   error.showErrorAlert()
                }
               
            }
        }
        
        */
    }
    
    func getRecipDetail (_ recipeID : Int64 , retailerID : String? = "") -> Void {
        
        //guard retailerID != nil else {return}
        apiHandler.getRecipeData(recipeID: "\(recipeID)", retailerID: retailerID != nil  ? retailerID! : "" ) { [weak self] (result) in
            guard let self = self else {return}
            // Answers.CustomEvent(withName: "recipeLink", customAttributes: ["recipeLink" : result] )
            switch result {
            case .success(let response):
                guard (response["status"] as? String) == self.KSuccess else {
                    return
                }
                if let arrayData = response["data"] as? NSDictionary{
                    //sab
                    //if let recipeDetialData : [NSDictionary] = arrayData as? [NSDictionary] {
                        //if (recipeDetialData.count) > 0 {
                            //for data:NSDictionary in recipeDetialData {
                                let recipe : Recipe = Recipe.init(recipeData: arrayData as! Dictionary<String, Any>)
                                    self.sendRecipeDetail(recipe)
                            //}
                        //}
                    //}
                   
                }
            case .failure(let error):
                error.showErrorAlert()
            }
        }
        
    }


    func addRecipeProductToCart( retailerID : String? , recipeIngrediants : [RecipeIngredients]) -> Void {

        let productA  = self.returnArrayOfProductFromRecipeIngrediantsArray(ingregiants: recipeIngrediants)
 
        apiHandler.addRecipeToCart(retailerID: retailerID! , productsArray: productA) { [weak self] (result) in
            guard let self = self else {return}
            SpinnerView.hideSpinnerView()
            switch result {
            case .success(let response):
                guard (response["status"] as? String) == self.KSuccess else {
                    ElGrocerError.init(code: 500).showErrorAlert()
                    return
                }
                if let isAddedToCart : Bool = response["data"] as? Bool {
                    if !isAddedToCart {
                        //fail case
                        ElGrocerError.init(code: 500).showErrorAlert()
                        return
                    }
                }
                self.addToCartSuccess()
            case .failure(let error):
                error.showErrorAlert()
            }
        }
    }
    
    func addRecipeToCart( retailerID : String? , recipe : Recipe) -> Void {

        let productA  = self.returnArrayOfProductFromRecipeIngrediantsArray(ingregiants: recipe.Ingredients)
 
        apiHandler.addRecipeToCart(retailerID: retailerID! , productsArray: productA) { [weak self] (result) in
            guard let self = self else {return}
            SpinnerView.hideSpinnerView()
            switch result {
            case .success(let response):
                guard (response["status"] as? String) == self.KSuccess else {
                    ElGrocerError.init(code: 500).showErrorAlert()
                    return
                }
                if let isAddedToCart : Bool = response["data"] as? Bool {
                    if !isAddedToCart {
                        //fail case
                        ElGrocerError.init(code: 500).showErrorAlert()
                        return
                    }
                }
                self.addToCartSuccess()
            case .failure(let error):
                error.showErrorAlert()
            }
        }
    }

    fileprivate func returnArrayOfProductFromRecipeIngrediantsArray (ingregiants : [RecipeIngredients]?) -> [Dictionary<String, Any>]? {

        if let arrayData = ingregiants {
            var productA : [Dictionary<String, Any>] = [Dictionary<String, Any>]()
            for ingre: RecipeIngredients in arrayData {
                 productA.append( ["product_id": ingre.recipeIngredientsProductID!  , "quantity": 1])
//                productA.append( ["product_id": ingre.recipeIngredientsProductID!  , "quantity": ingre.recipeIngredientsQuantity!])
            }
            return productA
        }
        return nil

    }




    // MARK:- setter - remover
    
    func resetCategoryList() {
        self.recipeCategoryList.removeAll()
    }
    
    func resetRecipeList() {
        self.recipeList.removeAll()
    }
    func setFilterRecipeCategory(_ category : RecipeCategoires?) {
        self.selectRecipeCategoires = category
    }
    func setFilterChef(_ chef : CHEF?) {
        self.selectChef = chef
    }

}
extension RecipeDataHandler {
    
    //MARK:- delegate methods returns
    func sendChefListData() -> Void {
        if self.delegate != nil {
            self.delegate?.chefList(chefTotalA: self.chefList)
        }
    }
    func sendRecipeCategoryListData() -> Void {
        if self.delegate != nil {
            self.delegate?.recipeCatogeiresList(categoryTotalA: recipeCategoryList)
        }
    }
    func sendRecipeListData() -> Void {
        self.filterData()
        if self.delegate != nil {
            self.delegate?.recipeList(recipeTotalA: self.recipeList)
        }
    }
    func sendRecipeDetail(_ recipe : Recipe) -> Void {
        if self.delegate != nil {
            self.delegate?.recipeDetial(recipe)
        }
    }
    func addToCartSuccess() -> Void {
        if self.delegate != nil {
            self.delegate?.addToCartCompleted()
        }
    }
    func filterData() {
        self.recipeList = self.recipeList.unique { $0.recipeID }
        //self.recipeList = self.recipeList.filter() {$0.recipeIsPublished == true}
    }
    func saveRecipe(_ save : Bool) -> Void{
        self.isSaveRecipe = save
    }
    
}
extension Array {
    func unique<T:Hashable>(map: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }
        return arrayOrdered
    }
    mutating func move(from oldIndex: Index, to newIndex: Index) {
        // Don't work for free and use swap when indices are next to each other - this
        // won't rebuild array and will be super efficient.
        if oldIndex == newIndex { return }
        if abs(newIndex - oldIndex) == 1 { return self.swapAt(oldIndex, newIndex) }
        self.insert(self.remove(at: oldIndex), at: newIndex)
    }
    func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
        var arr = array
        let element = arr.remove(at:fromIndex)
        arr.insert(element, at: toIndex)
        return arr
    }
    
}
public extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
    func indexes(of element: Element) -> [Int] {
        return self.enumerated().filter({ element == $0.element }).map({ $0.offset })
    }
   
}

