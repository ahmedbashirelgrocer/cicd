//
//  RecipeTableViewCell.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 16/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

struct Recipe {

    var recipeID : Int64? = -1
    var recipeName : String? = ""
    var recipeImageURL : String? = ""
    var recipeCategoryID : Int64? = -1
    var recipeCategoryName : String? = ""
    var recipePrepTime : Int64? = -1
    var recipeCookTime : Int64? = -1
    var recipeDescription : String? = ""
    var recipeForPeople : Int64? = -1
    var recipeDeepLink : String? = ""
    var recipeIsPublished : Bool? = false
    var recipeChef : CHEF? = nil
    var Steps : [RecipeSteps]? = nil
    var Ingredients : [RecipeIngredients]? = nil
    var isSaved : Bool = false
    var recipeImages : [String]? = nil
    var recipeSlug : String = ""
    var recipeStorylySlug : String = ""
    var recipeRetailerIds : [NSNumber]? = nil
    var recipeStoreTypes : [NSNumber]? = nil
    var recipeRetailerGroups : [NSNumber]? = nil
}
extension Recipe {
    
    init( recipeData : Dictionary<String,Any>){
        
        recipeID = recipeData["id"] as? Int64 ?? -1
        recipeName = recipeData["name"] as? String ?? ""
        recipeImageURL = recipeData["image_url"] as? String ?? ""
        if recipeImageURL?.isEmpty ?? false {
            recipeImageURL = recipeData["photo_url"] as? String ?? ""
        }
        recipeCategoryID = recipeData["category_id"] as? Int64 ?? -1
        
        if let categories = recipeData["categories"] as? [[String : Any]]{
            for category in categories{
                if category["id"] as? Int64 == categories[0]["id"] as? Int64{
                    recipeCategoryName = category["name"] as? String ?? ""
                }else{
                    let name = category["name"] as? String ?? ""
                    recipeCategoryName = recipeCategoryName! + "," + name 
                }
                
            }
        }
        
        recipeCategoryName = recipeCategoryName?.uppercased()
        
//        recipeCategoryName = recipeData["category_name"] as? String ?? ""
        recipePrepTime = recipeData["prep_time"] as? Int64 ?? -1
        recipeCookTime = recipeData["cook_time"] as? Int64 ?? -1
        recipeDescription = recipeData["description"] as? String ?? ""
        recipeForPeople = recipeData["for_people"] as? Int64 ?? -1
        recipeIsPublished = recipeData["is_published"] as? Bool ?? false
        recipeDeepLink = recipeData["deep_link"] as? String ?? ""
//        if let saved = recipeData["is_save"] as? Int{
//            if saved == 0{
//                isSaved = false
//            }else{
//                isSaved = true
//            }
//        }else{
//            isSaved = false
//        }
        isSaved = recipeData["is_saved"] as? Bool ?? false
        recipeImages = recipeData["images"] as? [String] ?? []
        if recipeImages != nil{
            if recipeImages!.count <= 0 {
                recipeImages = [recipeImageURL ?? ""]
            }
        }
        
        recipeSlug = recipeData["slug"] as? String ?? ""
        recipeStorylySlug = recipeData["storyly_slug"] as? String ?? ""
        recipeRetailerIds = recipeData["retailer_ids"] as? [NSNumber] ?? nil
        recipeRetailerGroups = recipeData["retailer_groups"] as? [NSNumber] ?? nil
        recipeStoreTypes = recipeData["store_types"] as? [NSNumber] ?? nil
        
        if let chefData : Dictionary<String, Any> = recipeData["chef"] as? Dictionary<String, Any> {
            
            recipeChef = CHEF.init(chefDict: chefData)
        }
        
        if let dataA : [Dictionary<String, Any>] = recipeData["cooking_steps"] as? [Dictionary<String, Any>] {
            
            if dataA.count > 0 {
                Steps =  RecipeSteps().initToGetArrayOfSteps(dataA)
            }else{
                Steps = nil
            }
        }
        
        if let dataA : [Dictionary<String, Any>] = recipeData["ingredients"] as? [Dictionary<String, Any>] {
            
            if dataA.count > 0 {
                 Ingredients = RecipeIngredients().initToGetArrayOfIngredients(dataA)
            }else{
                Ingredients = nil
            }
        }
        
    }
    
    
}

struct RecipeSteps {
    
    var recipeID : Int64? = -1
    var recipeStepsID : Int64? = -1
    var recipeStepNumber : Int64? = -1
    var recipeStepImageURL : String? = ""
    var recipeStepDetail : String? = ""
    
}

extension RecipeSteps {
    
    init( recipeSteps : Dictionary<String,Any>){
        
        recipeStepsID = recipeSteps["id"] as? Int64 ?? -1
        recipeID = recipeSteps["recipe_id"] as? Int64 ?? -1
        recipeStepNumber = recipeSteps["step_number"] as? Int64 ?? -1
        recipeStepDetail = recipeSteps["step_detail"] as? String ?? ""
        recipeStepImageURL = recipeSteps["image_url"] as? String ?? ""
        
    }
    
    func initToGetArrayOfSteps (_ arrayData : [Dictionary<String, Any>]) -> [RecipeSteps]? {
        var dataA : [RecipeSteps]?=nil
        if arrayData.count > 0 {
            dataA = []
        }
        for data:Dictionary<String, Any> in arrayData{
            let steps : RecipeSteps = RecipeSteps.init(recipeSteps: data)
            dataA?.append(steps)
        }
        return dataA
    }
    
}

struct RecipeIngredients {
    
    var recipeIngredientsID : Int64? = -1
    var recipeIngredientsProductID : Int64? = -1
    
    var recipeIngredientsBrandID : Int64? = -1
    var recipeIngredientsBrandName : String? = ""
    var recipeIngredientsBrandNameEn : String? = ""
    
    
    var recipeIngredientsSubCategoryID : Int64? = -1
    var recipeIngredientsSubCategoryName : String? = ""
    var recipeIngredientsSubCategoryNameEn : String? = ""
    
    var recipeIngredientsCategoryID : Int64? = -1
    var recipeIngredientsCategoryName : String? = ""
    var recipeIngredientsCategoryNameEn : String? = ""
   
    var recipeIngredientsQuantity : String? = ""
    var recipeIngredientsQuantityUnit : String? = ""
    var recipeIngredientsTotalQuantity : String? = ""
    var recipeID : Int64? = -1
    var recipeIngredientsImageURL : String? = ""
    var recipeIngredientsName : String? = ""

    var recipeIngredientsPrice :  NSNumber? = 0
    var recipeIngredientsIsPublished : NSNumber? = 1
    var recipeIngredientsIsAvailable : NSNumber? = 1
    var recipeIngredientsIsPromotion : NSNumber? = 0
    

    
    
    
}

extension RecipeIngredients {
    
    init( recipeIngredients : Dictionary<String,Any>){
        
        recipeIngredientsID = recipeIngredients["id"] as? Int64 ?? -1
        recipeIngredientsProductID = recipeIngredients["product_id"] as? Int64 ?? -1
        
        recipeIngredientsBrandID = recipeIngredients["brand_id"] as? Int64 ?? -1
        recipeIngredientsSubCategoryID = recipeIngredients["subcategory_id"] as? Int64 ?? -1
        
        recipeIngredientsQuantity = recipeIngredients["qty"] as? String ?? ""
        
//        if let qty = recipeIngredients["qty"] as? String {
//            recipeIngredientsQuantity = Float(qty)
//        }else{
//            recipeIngredientsQuantity = recipeIngredients["qty"] as? Float ?? 0.0
//        }
        
        
        recipeIngredientsQuantityUnit = recipeIngredients["qty_unit"] as? String ?? ""
        recipeIngredientsTotalQuantity = recipeIngredients["size_unit"] as? String ?? ""
        recipeID = recipeIngredients["recipe_id"] as? Int64 ?? -1
        recipeIngredientsImageURL = recipeIngredients["image_url"] as? String ?? ""
        recipeIngredientsName = recipeIngredients["name"] as? String ?? ""
        recipeIngredientsPrice = recipeIngredients["price"] as? NSNumber ?? 0
        

        if let isProductAvailable = recipeIngredients["is_available"] as? NSNumber {
            recipeIngredientsIsAvailable = isProductAvailable
        }else{
            recipeIngredientsIsAvailable = 1
        }
        
        if let isProductPublished = recipeIngredients["is_published"] as? NSNumber {
            recipeIngredientsIsPublished = isProductPublished
        }else{
            recipeIngredientsIsPublished = 1
        }
        
        if let isProductPublished = recipeIngredients["is_p"] as? NSNumber {
            recipeIngredientsIsPromotion = isProductPublished
        }else{
            recipeIngredientsIsPromotion = 0
        }
        
        if let brandDict = recipeIngredients["brand"] as? NSDictionary {
            
            let brandId = brandDict["id"] as? Int64 ?? -1
            let brandName = brandDict["name"] as? String ?? ""
            recipeIngredientsBrandID = brandId
            recipeIngredientsBrandName = brandName
            recipeIngredientsBrandNameEn = brandDict["slug"] as? String ?? ""
            
        }
        
        if let subCatDictA = recipeIngredients["subcategories"] as? [NSDictionary] {
            if subCatDictA.count > 0 {
                if let subCatDict = subCatDictA.first {
                    
                    recipeIngredientsSubCategoryID = subCatDict["id"] as? Int64 ?? -1
                    recipeIngredientsSubCategoryName = subCatDict["name"] as? String
                    recipeIngredientsSubCategoryNameEn = subCatDict["slug"] as? String
                
                }
            }
        }
        
        if let categories = recipeIngredients["categories"] as? [NSDictionary] {
            
            if let category = categories.first {
                recipeIngredientsCategoryID = category["id"] as? Int64 ?? -1
                recipeIngredientsCategoryName = category["name"] as? String
                recipeIngredientsCategoryNameEn = category["slug"] as? String
            }
            
        }

    }
    
    func initToGetArrayOfIngredients (_ arrayData : [Dictionary<String, Any>]) -> [RecipeIngredients]? {
        var dataA : [RecipeIngredients]?=nil
        if arrayData.count > 0 {
            dataA = []
        }
        for data:Dictionary<String, Any> in arrayData{
            let ingredients : RecipeIngredients = RecipeIngredients.init(recipeIngredients: data)
            dataA?.append(ingredients)
        }
        return dataA
    }
}


let KRecipeTableViewCellIdentifier = "RecipeTableViewCell"
let KRecipeTableViewCellHeight = 335.0
//let KRecipeCellRatio = 1.35

class RecipeTableViewCell: UITableViewCell {
    
    var changeRecipeSaveStateTo: ((_ isSave : Bool? , _ recipe : Recipe?)->Void)?
    
    @IBOutlet weak var addWidth: NSLayoutConstraint!
    
    lazy var placeholderPhoto : UIImage = {
        return UIImage(name: "product_placeholder")!
    }()
    
    @IBOutlet var chefImage: UIImageView!{
        didSet{
            chefImage.visibility = .goneX
        }
    }
    @IBOutlet var recipeImage: UIImageView!
    @IBOutlet var gradiantView: UIView!{
        didSet{
            gradiantView.alpha = 0.56
        }
    }
    @IBOutlet var recipeDetailBGView: UIView!{
        didSet{
            recipeDetailBGView.layer.cornerRadius = 8
        }
    }
    @IBOutlet var lblRecipeName: UILabel! { // used as recipe name
        didSet{
            lblRecipeName.setH4SemiBoldWhiteStyle()
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                lblRecipeName.textAlignment = .right
            }
        }
    }
    @IBOutlet var lblRecipeChefName: UILabel! { // used as chef/brand name
        didSet{
            lblRecipeChefName.setBody3RegWhiteStyle()
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                lblRecipeChefName.textAlignment = .right
            }
        }
    }
    @IBOutlet var saveRecipeBGView: AWView!{
        didSet{
            saveRecipeBGView.cornarRadius = 22
            saveRecipeBGView.alpha = 1
        }
    }
    @IBOutlet var saveRecipeImageView: UIImageView!
    @IBOutlet var saveRecipeButton: UIButton!
    
    
    var selectedRecipe : Recipe? = nil
    lazy var dataHandler : RecipeDataHandler = {
        let dataH = RecipeDataHandler()
        return dataH
    }()
    
    let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // setGradientBackgroundTopToBottom()
    }
    override func layerWillDraw(_ layer: CALayer) {
        // gradiantView.bounds = self.recipeImage.bounds
    }
    
    //MARK: Appearence
    func setGradientBackgroundTopToBottom() {
        gradiantView.fadeView(style: .bottom, percentage: 1)
    }
    
    func setRecipe(_ recipe : Recipe) {
        self.selectedRecipe = recipe
        self.lblRecipeName.text = recipe.recipeName
        self.lblRecipeChefName.text = localizedString("by", comment: "") + " " + (recipe.recipeChef?.chefName ?? "")
        self.setImage(recipe.recipeImageURL)
        if let isSaved = recipe.isSaved as? Bool{
            setSaveFilled(isSaved)
        }
        
        
    }
    
    func setSaveFilled(_ filled : Bool = false){
        if filled{
            self.saveRecipeImageView.image = UIImage(name: "saveFilled")
        }else{
            self.saveRecipeImageView.image = UIImage(name: "saveUnfilled")
        }
    }
    
    func setImage(_ url : String? ) {
        if url != nil && url?.range(of: "http") != nil {
            
            self.recipeImage.sd_setImage(with: URL(string: url!), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 7), completed: {[weak self] (image, error, cacheType, imageURL) in
                guard let self = self else {
                    return
                }
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.recipeImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {[weak self] () -> Void in
                        guard let self = self else {
                            return
                        }
                        self.recipeImage.image = image
                        }, completion: nil)
                }
               
            })
        }
    }
    
    func setChefImage(_ url : String? ) {
        if url != nil && url?.range(of: "http") != nil {
            
            self.chefImage.sd_setImage(with: URL(string: url!), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: {[weak self] (image, error, cacheType, imageURL) in
                guard let self = self else {
                    return
                }
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.recipeImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {[weak self] () -> Void in
                        guard let self = self else {
                            return
                        }
                        self.chefImage.image = image
                        }, completion: nil)
                }
            })
        }
    }





    
  //sab
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//        //self.setUpApearance()
//    }
//
//    func setUpApearance() {
//
//        self.categoryLable.shadowColor = UIColor.lightGray
//        self.categoryLable.shadowOffset = CGSize.init(width: 0.0, height: -0.5)
//        self.dishNameLable.shadowColor = UIColor.lightGray
//        self.dishNameLable.shadowOffset = CGSize.init(width: 0.0, height: -0.5)
//
//    }
    
    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        if !self.recipeImageView.isAnimate {
//            self.recipeImageView.roundCorners(corners: [.topLeft, .topRight], radius: 15.0)
//        }
//        chefImageView.layer.cornerRadius = chefImageView.frame.size.height/2
//        recipeImageView.clipsToBounds = true
//        recipeImageView.layer.masksToBounds = true
//        chefImageView.clipsToBounds = true
//        chefImageView.layer.masksToBounds = true
        
//        self.gradientViewRecipeName.colors = [UIColor.colorWithHexString(hexString: "b1bacb").cgColor,UIColor.black.cgColor]
//        self.gradientViewRecipeName.alpha = 0.047
//        self.gradientViewRecipeName.layer.shadowColor = UIColor.black.cgColor
//        self.gradientViewRecipeName.layer.shadowOpacity = 0.30
        
    }
   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func configuredCell (_ recipe : Recipe? , _ recipeCartList : [RecipeCart]? ) {

//        if let notNilRecipe = recipe {
//
//            self.categoryLable.text = notNilRecipe.recipeCategoryName?.uppercased()
//            self.dishNameLable.text = notNilRecipe.recipeName
//
//            if let recipeURL = notNilRecipe.recipeImageURL {
//                self.setCellImage(recipeURL , inImageView: self.recipeImageView)
//            }
//
//            guard notNilRecipe.recipeChef != nil else {
//                return
//            }
//            self.chefNameLable.text = notNilRecipe.recipeChef?.chefName
//            if let chefImageURL = notNilRecipe.recipeChef!.chefImageURL {
//                self.setCellImage( chefImageURL , inImageView: self.chefImageView)
//            }
//
//            if let dataA : [RecipeCart] = recipeCartList {
//                let filterA =   dataA.filter() { $0.recipeID == notNilRecipe.recipeID}
//                if filterA.count > 0 {
//                    self.setAddViewSelected()
//                    return
//                }
//            }
//            self.setAddViewUnSelected()
//        }
        
    }


    func setAddViewSelected () -> Void {

    }

    func setAddViewUnSelected () -> Void {

    }
    
 
    @IBAction func saveButtonAction(_ sender: Any) {
        
        guard self.selectedRecipe != nil else {return}
        if let topVc = UIApplication.topViewController() {
            if topVc is savedRecipesVC {
                return
            }
        }
        
        if let isSaved = self.selectedRecipe?.isSaved {
            if isSaved {
                apiCallSaveRecipe(recipe: self.selectedRecipe!, isSave: false)
                return
            }
        }
        apiCallSaveRecipe(recipe: self.selectedRecipe!, isSave: true)
        
    }
    
    
    func apiCallSaveRecipe(recipe : Recipe , isSave : Bool) {
        
        guard UserDefaults.isUserLoggedIn() else {
            
            let signInVC = ElGrocerViewControllers.signInViewController()
            signInVC.isForLogIn = true
            signInVC.isCommingFrom = .saveRecipe
            signInVC.dismissMode = .dismissModal
            signInVC.recipeId =  recipe.recipeID
            let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
            navController.viewControllers = [signInVC]
            navController.modalPresentationStyle = .fullScreen
            if let topVc = UIApplication.topViewController() {
                topVc.present(navController, animated: true, completion: nil)
            }
            return
        }
        
        
        dataHandler.saveRecipeApiCall(recipeID: recipe.recipeID!, isSave: isSave) { (Done) in
            if Done {
                
                if isSave {
                    let msg = localizedString("recipe_save_success", comment: "")
                    ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "saveFilled") , -1 , false) { (sender , index , isUnDo) in  }
                }
                
                if let clouser = self.changeRecipeSaveStateTo {
                    clouser (isSave, self.selectedRecipe)
                }
            }
        }
        
    }
    
    
    

    func makeSkelotonShimmerCell () {

        self.lblRecipeName.isAnimate = true
        self.lblRecipeChefName.isAnimate = true
        self.recipeImage.isAnimate = true
        self.startShimmerAnimation()

    }

    fileprivate func setCellImage(_ urlString : String? , inImageView : UIImageView?=nil ) {

        guard urlString != nil && urlString!.range(of: "http") != nil && inImageView != nil else {
            inImageView?.image = self.placeholderPhoto
            return
        }

        inImageView?.clipsToBounds = true
        inImageView!.sd_setImage(with: URL(string: urlString! ), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in

            if cacheType == SDImageCacheType.none {
                UIView.transition(with: inImageView! , duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { [weak self]() -> Void in
                    guard let self = self else {return}
                    guard image != nil else {
                        inImageView?.image = self.placeholderPhoto
                        return
                    }
                    inImageView?.image = image
                    }, completion: nil)
            }
            guard error == nil else {return}
             inImageView?.image = image

        })

    }


    
}


extension UITableViewCell {


    func startShimmerAnimation() {

        for animateView in getSubViewsForAnimate() {
            animateView.clipsToBounds = true
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.withAlphaComponent(0.8).cgColor, UIColor.clear.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.7, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.8)
            gradientLayer.frame = animateView.bounds
            animateView.layer.mask = gradientLayer

            let animation = CABasicAnimation(keyPath: "transform.translation.x")
            animation.duration = 1.5
            animation.fromValue = -animateView.frame.size.width
            animation.toValue = animateView.frame.size.width
            animation.repeatCount = .infinity

            gradientLayer.add(animation, forKey: "")
        }
    }

    func stopShimmerAnimation() {
        for animateView in getSubViewsForAnimate() {
            animateView.layer.removeAllAnimations()
            animateView.layer.mask = nil
        }
    }

    private func getSubViewsForAnimate() -> [UIView] {
        var obj: [UIView] = []
        for objView in self.contentView.subviewsRecursive() {
            obj.append(objView)
        }
        return obj.filter({ (obj) -> Bool in
            obj.shimmerAnimation
        })
    }




}


var associateObjectValue: Int = 0

extension UIView {

    fileprivate var isAnimate: Bool {
        get {
            return objc_getAssociatedObject(self, &associateObjectValue) as? Bool ?? false
        }
        set {
            return objc_setAssociatedObject(self, &associateObjectValue, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    @IBInspectable var shimmerAnimation: Bool {
        get {
            return isAnimate
        }
        set {
            self.isAnimate = newValue
        }
    }

    func subviewsRecursive() -> [UIView] {
        return subviews + subviews.flatMap { $0.subviewsRecursive() }
    }
    
    
    

}
