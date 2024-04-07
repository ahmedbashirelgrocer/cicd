//
//  DeepLinkBottomGroceryVC.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 16/12/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import ThirdPartyObjC

class DeepLinkBottomGroceryVC: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet var superBGView: AWView! {
        didSet {
            superBGView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
            superBGView.roundWithShadow(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 8)
        }
    }
    @IBOutlet var titleShimmer: FBShimmeringView!
    @IBOutlet var titleshimmerContentView: UILabel!
    @IBOutlet var bottomShimmer: FBShimmeringView!
    @IBOutlet var bottomShimmerContentView: UILabel!
    @IBOutlet var tableViewShimmer: FBShimmeringView!
    @IBOutlet var tableViewShimmerContentView: UILabel!
    @IBOutlet var detailLabelYTopAnchor: NSLayoutConstraint!
    
    @IBOutlet var lblError: UILabel!
    var selectedGrocery: ((_ grocery : Grocery)->Void)?
    @IBOutlet var lblheader: UILabel! {
        didSet {
            lblheader.text = localizedString("No_Choose_The_Store", comment: "")
        }
    }
    @IBOutlet var lblFoundStore: UILabel!
    @IBOutlet var tableView: UITableView!
    var dataA : [Grocery] = []
    var product: Product?
    var deepLink : String = ""
    var source : String = ""
    var type : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
       // self.view.backgroundColor = .textfieldBackgroundColor()
        registerCell ()
    }
    func registerCell () {
        
        let elgrocerGroceryListTableViewCell = UINib(nibName: KElgrocerGroceryListTableViewCell, bundle: Bundle.resource)
        self.tableView.register(elgrocerGroceryListTableViewCell , forCellReuseIdentifier: KElgrocerGroceryListTableViewCell)
        
        let GroceryWithProductTableCell = UINib(nibName: "GroceryWithProductTableCell", bundle: Bundle.resource)
        self.tableView.register(GroceryWithProductTableCell , forCellReuseIdentifier: "GroceryWithProductTableCell")
        
    }
  
    func showShimmerView (_ isShimmer : Bool = false) {
        
        if isShimmer {
            
            self.titleshimmerContentView.backgroundColor = UIColor.borderGrayColor()
            self.bottomShimmerContentView.backgroundColor = UIColor.borderGrayColor()
            self.tableViewShimmerContentView.backgroundColor = UIColor.borderGrayColor()
            
            self.titleShimmer.contentView = self.titleshimmerContentView
            self.bottomShimmer.contentView = self.bottomShimmerContentView
            self.tableViewShimmer.contentView = self.tableViewShimmerContentView
            
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                self.titleShimmer.shimmeringDirection = .left
                self.bottomShimmer.shimmeringDirection = .left
                self.tableViewShimmer.shimmeringDirection = .left
            }
        }
        
        titleShimmer.isHidden = !isShimmer
        bottomShimmer.isHidden = !isShimmer
        tableViewShimmer.isHidden = !isShimmer
        
        lblheader.isHidden =  isShimmer
        lblFoundStore.isHidden = isShimmer
        tableView.isHidden = isShimmer
        
        self.titleShimmer.isShimmering = isShimmer
        self.bottomShimmer.isShimmering = isShimmer
        self.tableViewShimmer.isShimmering = isShimmer
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func sortArrayPiceBases (_ groceryA : [Grocery], product : Product) -> [Grocery] {
        
        var priceValue : NSNumber? = nil
        
       var dataA = groceryA
       
        
        dataA.sort { groceryOne, groceryTwo in
            
            var groceryOneProductPrice : NSNumber = NSNumber.init(value: 0.0)
            var groceryTwoProductPrice : NSNumber = NSNumber.init(value: 0.0)
            
            if let shopsA = product.shops {
                let shops = product.convertToDictionaryArray(text: shopsA)
                for shop in shops ?? [] {
                    if let dbID = shop["retailer_id"] as? Int {
                        if "\(dbID)" == groceryOne.getCleanGroceryID() {
                            if let price = shop["price"] as? NSNumber {
                                groceryOneProductPrice = price
                            }
                        }
                        if "\(dbID)" == groceryTwo.getCleanGroceryID() {
                            if let price = shop["price"] as? NSNumber {
                                groceryTwoProductPrice = price
                            }
                        }
                    }
                }
                
            }
            
            if let shopsA = product.promotionalShops {
                let shops = product.convertToDictionaryArray(text: shopsA)
                for shop in shops ?? [] {
                    if let dbID = shop["retailer_id"] as? Int {
                        if "\(dbID)" == groceryOne.getCleanGroceryID() {
                            if let price = shop["price"] as? NSNumber {
                                groceryOneProductPrice = price
                            }
                        }
                        if "\(dbID)" == groceryTwo.getCleanGroceryID() {
                            if let price = shop["price"] as? NSNumber {
                                groceryTwoProductPrice = price
                            }
                        }
                        
                    }
                }
            }
    
            return groceryOneProductPrice < groceryTwoProductPrice
        }
        
        return dataA
        
    }
    
    
    
    func configure (_ groceryA : [Grocery] ,product: Product, searchString : String, _ isNeedToShowFoundString : Bool = true) {
        
        self.product = product
        
        self.lblError.isHidden = true
        self.dataA = self.sortArrayPiceBases(groceryA, product: product)
        self.tableView.reloadData()
        
        if isNeedToShowFoundString   {
            
            let finalSearchString = " \"" + searchString + "\""
            let finalTitle = localizedString("lbl_weFound", comment: "") + " " +  self.getNumerals(num: groceryA.count) + " " + localizedString("lbl_StorethatSell", comment: "") + finalSearchString
            let attributedString = NSMutableAttributedString(string: finalTitle, attributes: [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14) , NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()])
            let nsRange = NSString(string: finalTitle).range(of: finalSearchString , options: String.CompareOptions.caseInsensitive)
            if nsRange.location != NSNotFound {
                attributedString.addAttribute(NSAttributedString.Key.font , value: UIFont.SFProDisplaySemiBoldFont(14) , range: nsRange )
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor , value: ApplicationTheme.currentTheme.labelPrimaryBaseTextColor , range: nsRange )
            }
            DispatchQueue.main.async {
                UIView.performWithoutAnimation {
                    self.lblFoundStore.attributedText = attributedString
                }
                
            }
            
        } else {
            self.lblFoundStore.attributedText = NSAttributedString.init(string: "")
            self.detailLabelYTopAnchor.constant = 0
        }
        
        DispatchQueue.main.async {
            self.showShimmerView(groceryA.count == 0)
        }
        
    }
    
    func showErrorMessage (_ message : String) {
        DispatchQueue.main.async {
            self.showShimmerView(false)
            self.lblError.text = message
            self.lblheader.isHidden = true
            self.tableView.isHidden = true
            self.lblFoundStore.isHidden = true
            self.lblError.isHidden = false
        }
    }
    

    func getNumerals(num: Int) -> String {
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" // You can set locale of your language
        {
            let number = NSNumber(value: num)
            let format = NumberFormatter()
            format.locale = Locale(identifier: "ar")
            let formatedNumber = format.string(from: number)
            return formatedNumber!
        } else {
            return "\(num)"
        }
    }
    
    
    @IBAction func crossAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135//tableView.bounds.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataA.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.dataA.count > 0 {
            let grocery = dataA[indexPath.row]
            if let selectedGrocery = selectedGrocery {
                selectedGrocery(grocery)
                if let product = self.product {
                    FireBaseEventsLogger.trackProductStoreSelection(store: grocery, product: product, deepLink: self.deepLink, position: indexPath.row + 1, source: self.source, type: self.type)
                }
                
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : GroceryWithProductTableCell = self.tableView.dequeueReusableCell(withIdentifier: "GroceryWithProductTableCell" , for: indexPath) as! GroceryWithProductTableCell
        if let product = product , let grocery = dataA[indexPath.row] as? Grocery{
            cell.configureGroceryAndProduct(grocery: grocery, product: product)
        }
        
        return cell
        
    }
   
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if let product = product , let grocery = dataA[indexPath.row] as? Grocery{
//            FireBaseEventsLogger.trackProductStoreListViewed(store: grocery, product: product, deepLink: self.deepLink, position: indexPath.row, source: self.source, type: self.type)
//        }
//    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard dataA.count > indexPath.row else {return}
        if let product = product , let grocery = dataA[indexPath.row] as? Grocery{
            FireBaseEventsLogger.trackProductStoreListViewed(store: grocery, product: product, deepLink: self.deepLink, position: indexPath.row + 1, source: self.source, type: self.type)
        }
    }
    
    
}
