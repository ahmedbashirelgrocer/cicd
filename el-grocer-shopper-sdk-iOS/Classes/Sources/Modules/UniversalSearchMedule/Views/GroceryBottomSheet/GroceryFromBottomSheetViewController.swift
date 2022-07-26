//
//  GroceryFromBottomSheetViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 29/01/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import Shimmer
class GroceryFromBottomSheetViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet var titleShimmer: FBShimmeringView!
    @IBOutlet var titleshimmerContentView: UILabel!
    @IBOutlet var bottomShimmer: FBShimmeringView!
    @IBOutlet var bottomShimmerContentView: UILabel!
    @IBOutlet var tableViewShimmer: FBShimmeringView!
    @IBOutlet var tableViewShimmerContentView: UILabel!
    
    @IBOutlet var lblError: UILabel!
    var selectedGrocery: ((_ grocery : Grocery)->Void)?
    @IBOutlet var lblheader: UILabel! {
        didSet {
            lblheader.text = localizedString("No_Choose_The_Store", comment: "")
            lblheader.setH4SemiBoldStyle()
        }
    }
    @IBOutlet var lblFoundStore: UILabel!
    @IBOutlet var tableView: UITableView!
    var dataA : [Grocery] = []
    override func viewDidLoad() {
        if #available(iOS 11.0, *) {
            self.view.layer.cornerRadius = 12.0
            self.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
        super.viewDidLoad()
        self.tableView.backgroundColor = .textfieldBackgroundColor()
        self.view.backgroundColor = .textfieldBackgroundColor()
        registerCell ()
    }
    func registerCell () {
        
        let elgrocerGroceryListTableViewCell = UINib(nibName: KElgrocerGroceryListTableViewCell, bundle: Bundle.resource)
        self.tableView.register(elgrocerGroceryListTableViewCell , forCellReuseIdentifier: KElgrocerGroceryListTableViewCell)
        
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
    
    func configuer (_ groceryA : [Grocery] , searchString : String) {
        
        self.lblError.isHidden = true
        self.dataA = groceryA
        self.tableView.reloadData()
        let finalSearchString = " \"" + searchString + "\""
        let finalTitle = localizedString("lbl_weFound", comment: "") + " " +  self.getNumerals(num: groceryA.count) + " " + localizedString("lbl_StorethatSell", comment: "") //+ finalSearchString
        let attributedString1 = NSMutableAttributedString(string: finalTitle, attributes: [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14) , NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()])
        let attributedString2 = NSMutableAttributedString(string: finalSearchString, attributes: [NSAttributedString.Key.font : UIFont.SFProDisplayBoldFont(14) , NSAttributedString.Key.foregroundColor : UIColor.navigationBarColor()])
        attributedString1.append(attributedString2)
        /*
        let nsRange = NSString(string: finalTitle).range(of: finalSearchString , options: String.CompareOptions.caseInsensitive)
        if nsRange.location != NSNotFound {
            attributedString.addAttribute(NSAttributedString.Key.font , value: UIFont.SFProDisplaySemiBoldFont(14) , range: nsRange )
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor , value: UIColor.navigationBarColor() , range: nsRange )
        }*/
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                self.lblFoundStore.attributedText = attributedString1
            }
            self.showShimmerView(groceryA.count == 0)
        }
        
    }
    
    func configureForRecipe (_ groceryA : [Grocery] , searchString : String) {
        
        self.lblError.isHidden = true
        lblheader.text = localizedString("grocery_selection_From_Recipe_screen_title", comment: "")
        
        self.dataA = groceryA
        self.tableView.reloadData()
        //let finalSearchString = " \"" + searchString + "\""
        //let finalTitle = localizedString("lbl_weFound", comment: "") + " " +  self.getNumerals(num: groceryA.count) + " " + localizedString("lbl_StorethatSell", comment: "") + finalSearchString + " " + localizedString("lbl_Ingredients", comment: "")
        let finalTitle = localizedString("lbl_weFound", comment: "") + " " +  self.getNumerals(num: groceryA.count) + " " + localizedString("lbl_StorethatSell", comment: "") + " " + localizedString("lbl_Ingredients", comment: "")
        let attributedString = NSMutableAttributedString(string: finalTitle, attributes: [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14) , NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()])
        /*
        let nsRange = NSString(string: finalTitle).range(of: finalSearchString , options: String.CompareOptions.caseInsensitive)
        if nsRange.location != NSNotFound {
            attributedString.addAttribute(NSAttributedString.Key.font , value: UIFont.SFProDisplayBoldFont(14) , range: nsRange )
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor , value: UIColor.navigationBarColor() , range: nsRange )
        }*/
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                self.lblFoundStore.attributedText = attributedString
            }
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
       elDebugPrint("cell height for collction \(tableView.frame.height)")
        return self.tableView.bounds.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ElgrocerGroceryListTableViewCell = tableView.dequeueReusableCell(withIdentifier: KElgrocerGroceryListTableViewCell , for: indexPath) as! ElgrocerGroceryListTableViewCell
        cell.configuredGroceryData(dataA)
        cell.selectedGrocery = { [weak self] grocery in
            guard let self = self else {return}
            ElGrocerUtility.sharedInstance.deepLinkURL = ""
            let oldstore = ElGrocerUtility.sharedInstance.activeGrocery
            let lastItemCount = String(describing: ElGrocerUtility.sharedInstance.lastItemsCount )
            let indexForNew = self.dataA.firstIndex { (grocer) -> Bool in
                return grocer.dbID == grocery.dbID
            }
            let posstion = String((indexForNew ?? 0 ) + 1 )
            FireBaseEventsLogger.trackStoreListingStoreClick(OldStoreID: oldstore?.dbID ?? "" , OldStoreName: oldstore?.name ?? "" , NumberOfItemsOldStore: lastItemCount  , Position: posstion , RowView:  "1"  , NumberOfRetailers: "\(self.dataA.count)" , StoreCategoryID: String(describing:  0 )  , StoreCategoryName: localizedString("all_store", comment: "") )
            
            if let clouser = self.selectedGrocery {
                clouser(grocery)
            }
        }
        return cell
        
    }
    
}
