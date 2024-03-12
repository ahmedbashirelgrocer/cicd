//
//  ELGrocerRecipeMeduleAPI.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 18/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import Foundation
// import AFNetworking

enum ElGrocerRecipeApiEndpoint : String {

    case GET_Chef = "v1/chefs"
    case GET_Chef_new = "v2/chefs"
    case GET_CategoryList = "v1/recipe_categories"
    case GET_CategoryList_new = "v2/recipe_categories"
    case GET_RecipeList = "v1/recipes"
    case GET_RecipeDetial = "v1/recipes/recipe_detail"
    case GET_RecipeDetial_new = "v2/recipes/recipe_detail"
    case GET_RecipeList_new = "v2/recipes"
    case GET_RecipeList_Saved = "v1/shopper_recipes/show"

    case POST_SaveRecipe = "v1/shopper_recipes/save"
    case POST_ElasticSearch = "v1/recipes/recipe_elastic_search"
    case POST_BulkAddToCart = "v2/shopper_cart_products/bulk_create_update"
}

class ELGrocerRecipeMeduleAPI : ElGrocerApi {
    
    
    private var recipeApiOperation:URLSessionDataTask?
    
    private var elgrocerApi = ElGrocerApi()
    
    func cancelAllRecipeAPICall(){
        if let recipe = NetworkCall.recipeApiOperation {
            recipe.cancel()
        }
    };
    
    /**
     API to get ChefList, need to provide offSet which is starting point and Limit which is total number of record required.
     
     - parameter offset:      starting point to limitize list
     - parameter Limit:       Limit of record like
     - parameter chefID:      if specfic chef data required
     - Throws: Either.failure(ElGrocerError(error: error as NSError)
     - Returns: list of chef in data Array
     
     - "status": "success",
     - "data": [{
     -  "id": 1,
     - "name": "Gulzar Hussain",
     - "image_url": "https://s3-eu-west-1.amazonaws.com/elgrocertest/chefs/photos/000/000/001/original/cefGulzar.jpeg?1555415262",
     - "insta": "@chefgulzar",
     - "blog": "https://www.masala.tv/category/chefs/gulzar-hussain/"
     - }]
     }
     */
    
    func getChefList(offset : String , Limit : String , chefID : String?="" ,retailerIDs : String , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        
        let urlStr = ElGrocerRecipeApiEndpoint.GET_Chef_new.rawValue
        var parameters : [String : String] = ["limit" : Limit , "offset" : offset]
        if !(chefID?.isEmpty)! {
            parameters["id"] = chefID
        }
        if !retailerIDs.isEmpty{
            parameters["retailer_ids"] = retailerIDs
        }else{
            return
        }
        
//        if Platform.isDebugBuild {
//            elDebugPrint("Service : \(urlStr)")
//            elDebugPrint(offset)
//            elDebugPrint("to")
//            elDebugPrint(Limit)
//            elDebugPrint("& ID : (in case available to add)")
//            elDebugPrint(chefID ?? "")
//
//        }
        
        NetworkCall.recipeApiOperation = NetworkCall.get(urlStr, parameters: parameters, progress: { (progress) in
              // elDebugPrint("Progress for API :  \(progress)")
        }, success: { (operation, response) in
            
//            if Platform.isDebugBuild {
//                elDebugPrint("API NAME : \(urlStr)")
//                elDebugPrint("PARAMS NAME : \(parameters)")
//                elDebugPrint("resPonse : \(String(describing: response))")
//            }
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            
            completionHandler(Either.success(response))
            
            
        }, failure: { (operation, error) in
//            if Platform.isDebugBuild {
//                elDebugPrint("API NAME : \(urlStr)")
//                elDebugPrint("PARAMS NAME : \(parameters)")
//                elDebugPrint("resPonse : \(error.localizedDescription)")
//            }
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
            
        })
    }
    
    /**
     API to get specfic  ChefList, static setting limit and offset as we expecting solid one record.
     
     - parameter chefID:      ID of required chef detail
     
     */
    /* func getChefData(chefID : String! , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
     
     let urlStr = ElGrocerRecipeApiEndpoint.GET_Chef.rawValue
     let parameters = ["offset" : "0" , "limit" : "1" , "id" :  chefID ]
     if Platform.isDebugBuild {
     elDebugPrint("Service : \(urlStr)")
     elDebugPrint("0")
     elDebugPrint("to")
     elDebugPrint("1")
     elDebugPrint("& ID")
     elDebugPrint(chefID)
     }
     self.recipeApiOperation = self.requestManager.get(urlStr, parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response: Any) -> Void in
     if Platform.isDebugBuild {
     elDebugPrint("API NAME : \(urlStr)")
     elDebugPrint("PARAMS NAME : \(parameters)")
     elDebugPrint("resPonse : \(response)")
     }
     guard let response = response as? NSDictionary else {
     completionHandler(Either.failure(ElGrocerError.parsingError()))
     return
     }
     completionHandler(Either.success(response))
     
     }) { (operation: AFHTTPRequestOperation!, error: Error) -> Void in
     if Platform.isDebugBuild {
     elDebugPrint("API NAME : \(urlStr)")
     elDebugPrint("PARAMS NAME : \(parameters)")
     elDebugPrint("resPonse : \(error.localizedDescription)")
     }
     if InValidSessionNavigation.CheckErrorCase(ElGrocerError(error: error as NSError)) {
                
                completionHandler(Either.failure(ElGrocerError(error: error as NSError)))
            }
     
     }
     }
     */
    
    
    /**
     API to getCategoryList, need to provide offSet which is starting point and Limit which is total number of record required.
     
     - parameter offset:      starting point to limitize list
     - parameter Limit:            URL of call
     
     */
    
//    func getCategoryList(offset : String , Limit : String , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
//
//
//        let urlStr = ElGrocerRecipeApiEndpoint.GET_CategoryList.rawValue
//        let parameters = ["limit" : Limit , "offset" : offset]
//        if Platform.isDebugBuild {
//            elDebugPrint("Service : \(urlStr)")
//            elDebugPrint(offset)
//            elDebugPrint("to")
//            elDebugPrint(Limit)
//        }
//        NetworkCall.recipeApiOperation = NetworkCall.get(urlStr, parameters: parameters, progress: { (progress) in
//              // elDebugPrint("Progress for API :  \(progress)")
//        }, success: { (operation, response) in
//
////            if Platform.isDebugBuild {
////                elDebugPrint("API NAME : \(urlStr)")
////                elDebugPrint("PARAMS NAME : \(parameters)")
////                elDebugPrint("resPonse : \(String(describing: response))")
////            }
//            guard let response = response as? NSDictionary else {
//                completionHandler(Either.failure(ElGrocerError.parsingError()))
//                return
//            }
//
//            completionHandler(Either.success(response))
//
//        }, failure: { (operation, error) in
////
////            if Platform.isDebugBuild {
////                elDebugPrint("API NAME : \(urlStr)")
////                elDebugPrint("PARAMS NAME : \(parameters)")
////                elDebugPrint("resPonse : \(error.localizedDescription)")
////            }
             //   InValidSessionNavigation.CheckErrorCase(ElGrocerError(error: error as NSError))
  //completionHandler(Either.failure(ElGrocerError(error: error as NSError)))
//
//        })
//
//    }
    func getCategoryList(retailerId : String? , shoperId : String?,offset : String , Limit : String , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        
        let urlStr = ElGrocerRecipeApiEndpoint.GET_CategoryList_new.rawValue
        var parameters = ["limit" : Limit , "offset" : offset]
        if let retrId = retailerId{
            parameters["retailer_ids"] = retrId
        }
        if let shoperID = shoperId{
            parameters["shopper_id"] = shoperID
        }
        if Platform.isDebugBuild {
            elDebugPrint("Service : \(urlStr)")
            elDebugPrint(offset)
            elDebugPrint("to")
            elDebugPrint(Limit)
        }
        NetworkCall.recipeApiOperation = NetworkCall.get(urlStr, parameters: parameters, progress: { (progress) in
              // elDebugPrint("Progress for API :  \(progress)")
        }, success: { (operation, response) in
            
//            if Platform.isDebugBuild {
//                elDebugPrint("API NAME : \(urlStr)")
//                elDebugPrint("PARAMS NAME : \(parameters)")
//                elDebugPrint("resPonse : \(String(describing: response))")
//            }
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            
            completionHandler(Either.success(response))
            
        }, failure: { (operation, error) in
//
//            if Platform.isDebugBuild {
//                elDebugPrint("API NAME : \(urlStr)")
//                elDebugPrint("PARAMS NAME : \(parameters)")
//                elDebugPrint("resPonse : \(error.localizedDescription)")
//            }
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
            
        })
        
    }

    
    
    func getRecipeList(offset : String , Limit : String ,  recipeID : Int64? ,  ChefID : Int64? , _ subcategoryID : Int64? ,  categoryID : Int64? , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        let urlStr = ElGrocerRecipeApiEndpoint.GET_RecipeList.rawValue
        var parameters : [String : Any] = ["limit" : Limit , "offset" : offset ]
        
        if let catID = categoryID {
            parameters["category_id"] = catID
        }
        if let subCatID = subcategoryID {
            parameters["subcategory_id"] = subCatID
        }
        if let chef = ChefID {
            parameters["chef_id"] = chef
        }
        if let recID = recipeID {
            parameters["id"] = recID
        }
//        if Platform.isDebugBuild {
//            elDebugPrint("API NAME : \(urlStr)")
//            elDebugPrint("PARAMS NAME : \(parameters)")
//        }
        
        
       NetworkCall.get(urlStr, parameters: parameters , progress: { (progress) in
              // elDebugPrint("Progress for API :  \(progress)")
        }, success: { (operation, response) in
            
//            if Platform.isDebugBuild {
//                elDebugPrint("API NAME : \(urlStr)")
//                elDebugPrint("PARAMS NAME : \(parameters)")
//                elDebugPrint("resPonse : \(String(describing: response))")
//            }
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            
            completionHandler(Either.success(response))
            
        }, failure: { (operation, error) in
            
//            if Platform.isDebugBuild {
//                elDebugPrint("API NAME : \(urlStr)")
//                elDebugPrint("PARAMS NAME : \(parameters)")
//                elDebugPrint("resPonse : \(error.localizedDescription)")
//            }
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        })
        
        
    }
    
    func getRecipeListNew(offset : String , Limit : String ,  recipeID : Int64? ,  ChefID : Int64? ,shopperID : String?,  categoryID : Int64?,retailerIDs : String , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        let urlStr = ElGrocerRecipeApiEndpoint.GET_RecipeList_new.rawValue
        var parameters : [String : Any] = ["limit" : Limit , "offset" : offset ]
        
        if let catID = categoryID {
            parameters["category_id"] = catID
        }
        if let shoperID = UserDefaults.getLogInUserID() as? String {
            parameters["shopper_id"] = shoperID
        }
        if let chef = ChefID {
            parameters["chef_id"] = chef
        }
        if let recID = recipeID {
            parameters["id"] = recID
        }
        if !retailerIDs.isEmpty{
            parameters["retailer_ids"] = retailerIDs
        }else{
            return
        }
        
//        if Platform.isDebugBuild {
//            elDebugPrint("API NAME : \(urlStr)")
//            elDebugPrint("PARAMS NAME : \(parameters)")
//        }
        
        
       NetworkCall.get(urlStr, parameters: parameters , progress: { (progress) in
              // elDebugPrint("Progress for API :  \(progress)")
        }, success: { (operation, response) in
            
//            if Platform.isDebugBuild {
//                elDebugPrint("API NAME : \(urlStr)")
//                elDebugPrint("PARAMS NAME : \(parameters)")
//                elDebugPrint("resPonse : \(String(describing: response))")
//            }
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            
            completionHandler(Either.success(response))
            
        }, failure: { (operation, error) in
            
//            if Platform.isDebugBuild {
//                elDebugPrint("API NAME : \(urlStr)")
//                elDebugPrint("PARAMS NAME : \(parameters)")
//                elDebugPrint("resPonse : \(error.localizedDescription)")
//            }
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        })
        
        
    }
    
    func getSavedRecipeList(shopperID : String , categoryId : String?, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        let urlStr = ElGrocerRecipeApiEndpoint.GET_RecipeList_Saved.rawValue
        var parameters : [String : Any] = [:]
        
        parameters["shopper_id"] = shopperID

        if let categroyID = categoryId {
            parameters["category_id"] = categroyID
        }
                
        
//        if Platform.isDebugBuild {
//            elDebugPrint("API NAME : \(urlStr)")
//            elDebugPrint("PARAMS NAME : \(parameters)")
//        }
        
        
       NetworkCall.get(urlStr, parameters: parameters , progress: { (progress) in
              // elDebugPrint("Progress for API :  \(progress)")
        }, success: { (operation, response) in
            
//            if Platform.isDebugBuild {
//                elDebugPrint("API NAME : \(urlStr)")
//                elDebugPrint("PARAMS NAME : \(parameters)")
//                elDebugPrint("resPonse : \(String(describing: response))")
//            }
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            
            completionHandler(Either.success(response))
            
        }, failure: { (operation, error) in
            
//            if Platform.isDebugBuild {
//                elDebugPrint("API NAME : \(urlStr)")
//                elDebugPrint("PARAMS NAME : \(parameters)")
//                elDebugPrint("resPonse : \(error.localizedDescription)")
//            }
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        })
        
        
    }
    
    func postSaveRecipe(recipe_id : Int64? , isSaved : Bool?, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        //self.setAccessTokenRecipe()
        
        
        let urlStr = ElGrocerRecipeApiEndpoint.POST_SaveRecipe.rawValue
        var parameters : [String : Any] = [:]
        if let recipe_id = recipe_id {
            parameters["recipe_id"] = recipe_id
        }
        if let is_saved = isSaved {
            parameters["is_saved"] = is_saved
        }
       
      //  parameters["shopper_id"] = UserDefaults.getLogInUserID
        
        
        
        NetworkCall.post(urlStr, parameters: parameters, progress: { (progress) in
              // elDebugPrint("Progress for API :  \(progress)")
        }, success: { (operation, response) in
            
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            
            completionHandler(Either.success(response))
            
        }, failure: { (operation, error) in

            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
            
        })
        
    }
    
    func setAccessTokenRecipe() {
    
     NetworkCall.setAuthenticationToken()
    
    self.requestManager.requestSerializer.setValue(UserDefaults.getAccessToken(), forHTTPHeaderField: "Authentication-Token")
    self.requestManager.requestSerializer.setValue(UserDefaults.getAccessToken(), forHTTPHeaderField: "Authentication-Token")
    
    var currentLang = LanguageManager.sharedInstance.getSelectedLocale()
    // //elDebugPrint("Current Language:%@",currentLang)
    
    if currentLang == "Base" {
    currentLang = "en"
    }
    self.requestManager.requestSerializer.setValue(currentLang, forHTTPHeaderField: "Locale")
      
    }
    
    func getRecipeData(recipeID : String! , retailerID : String , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        let urlStr = ElGrocerRecipeApiEndpoint.GET_RecipeDetial_new.rawValue
        var parameters : [String : Any] = [ "id" :  recipeID! ]
        parameters["shopper_id"] = UserDefaults.getLogInUserID() ?? ""
        if !retailerID.isEmpty {
            // parameters["retailer_id"] = retailerID
            // parameters["retailer_id"] =  ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
        }
    
        

        NetworkCall.get(urlStr, parameters: parameters, progress: { (progress) in
              // elDebugPrint("Progress for API :  \(progress)")
        }, success: { (operation, response) in
            
//            if Platform.isDebugBuild {
//                elDebugPrint("API NAME : \(urlStr)")
//                elDebugPrint("PARAMS NAME : \(parameters)")
//                elDebugPrint("resPonse : \(String(describing: response))")
//            }
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            completionHandler(Either.success(response))
            
        }, failure: { (operation, error) in
            
//            if Platform.isDebugBuild {
//                elDebugPrint("API NAME : \(urlStr)")
//                elDebugPrint("PARAMS NAME : \(parameters)")
//                elDebugPrint("resPonse : \(error.localizedDescription)")
//            }
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        })
       
    }
    
    
    func getRecipeListFromSearch(pageNumber : Int? , searchString : String? ,  ChefID : Int64? ,  categoryID : Int64? , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        
        NetworkCall.recipeApiOperation?.cancel()
        
        let urlStr = ElGrocerRecipeApiEndpoint.POST_ElasticSearch.rawValue
        var parameters : [String : Any] = [:]
        if let search = searchString {
            if !search.isEmpty {
                parameters["search_input"] = search
            }
        }
        if let page = pageNumber {
            parameters["page"] = page
        }
        if let catID = categoryID {
            parameters["category_id"] = catID
        }
        if let chef = ChefID {
            parameters["chef_id"] = chef
        }
        if Platform.isDebugBuild {
            elDebugPrint("API NAME : \(urlStr)")
            elDebugPrint("PARAMS NAME : \(parameters)")
        }
        NetworkCall.recipeApiOperation = NetworkCall.post(urlStr, parameters: parameters, progress: { (progress) in
              // elDebugPrint("Progress for API :  \(progress)")
        }, success: { (operation, response) in
            
//            if Platform.isDebugBuild {
//                elDebugPrint("API NAME : \(urlStr)")
//                elDebugPrint("PARAMS NAME : \(parameters)")
//                elDebugPrint("resPonse : \(String(describing: response))")
//            }
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            
            completionHandler(Either.success(response))
            
        }, failure: { (operation, error) in
//
//            if Platform.isDebugBuild {
//                elDebugPrint("API NAME : \(urlStr)")
//                elDebugPrint("PARAMS NAME : \(parameters)")
//                elDebugPrint("resPonse : \(error.localizedDescription)")
//            }
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
            
        })
        
    }
    
    
    
    func addRecipeToCart(retailerID : String , productsArray : [Dictionary<String, Any>]? , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        guard UserDefaults.isUserLoggedIn() else {
            return
        }
        
        let urlStr = ElGrocerRecipeApiEndpoint.POST_BulkAddToCart.rawValue
        var parameters : [String : Any] = [:]
        if !retailerID.isEmpty {
            parameters["retailer_id"] = retailerID
            parameters["retailer_id"] =  ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
        }
        if let products = productsArray {
            parameters["products"] = products
        }
        
        let time = ElGrocerUtility.sharedInstance.getCurrentMillis()
        parameters["delivery_time"] = time as AnyObject
        
        guard productsArray?.count ?? 0 > 0 && !retailerID.isEmpty else {
            completionHandler(Either.failure(ElGrocerError.init(error: NSError.init(domain: "", code: 404, userInfo: [:]))))
            return
        }
        
        if UserDefaults.isOrderInEdit() {
            if let orderDBID : NSNumber = UserDefaults.getEditOrderDbId(){
                parameters["order_id"] = orderDBID
            }
        }
     
        setAccessToken()
        NetworkCall.recipeApiOperation = NetworkCall.post(urlStr, parameters: parameters, progress: { (progress) in
              // elDebugPrint("Progress for API :  \(progress)")
        }, success: { (operation, response) in
            
//            if Platform.isDebugBuild {
//                elDebugPrint("API NAME : \(urlStr)")
//                elDebugPrint("PARAMS NAME : \(parameters)")
//                elDebugPrint("resPonse : \(String(describing: response))")
//            }
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            
            completionHandler(Either.success(response))
            
        }, failure: { (operation, error) in
            
//            if Platform.isDebugBuild {
//                elDebugPrint("API NAME : \(urlStr)")
//                elDebugPrint("PARAMS NAME : \(parameters)")
//                elDebugPrint("resPonse : \(error.localizedDescription)")
//            }
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
            
        })
       
    }
    
}
