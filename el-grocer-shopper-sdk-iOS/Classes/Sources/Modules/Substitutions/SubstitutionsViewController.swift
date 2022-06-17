//
//  SubstitutionsViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 24/08/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit

class SubstitutionsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var chooseSubstitutionsTitle: UILabel!
    @IBOutlet weak var chooseSubstitutionsMessage: UILabel!
    
    @IBOutlet weak var tblExpandable: UITableView!
    
    @IBOutlet var confirmButton: UIButton!

    // MARK: Variables
    var order:Order!
    var orderItems:[ShoppingBasketItem]!

    var cellDescriptors = [CellDescriptor]()
    var visibleRows = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = localizedString("substitutions_title_new", comment: "")

        addBackButton()
        
        self.setChooseSubstitutionsViewAppearance()
        self.configureTableView()
        self.configureConfirmButtonAppearence()
        
        self.setDataInView()
        self.updateServerAboutSubstitution()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getIndicesOfVisibleRows() {
        
        self.visibleRows = 0
        
        for currentSectionCells in cellDescriptors {
            
            if currentSectionCells.isVisible == true {
                self.visibleRows += 1
            }
        }
        
        print("Visible Rows Count:%d",self.visibleRows)
    }
    
    // MARK: Appearance
    
    private func setChooseSubstitutionsViewAppearance() {
        
        self.chooseSubstitutionsTitle.font = UIFont.SFProDisplaySemiBoldFont(17.0)
        self.chooseSubstitutionsTitle.textColor = UIColor.black
        self.chooseSubstitutionsTitle.text = localizedString("choose_substitutions_title_new", comment: "")
        
        self.chooseSubstitutionsMessage.font = UIFont.SFProDisplayNormalFont(14.0)
        self.chooseSubstitutionsMessage.textColor = UIColor.lightGray
        self.chooseSubstitutionsMessage.text = localizedString("products_out_of_stock_message_new", comment: "")
    }
    
    func configureTableView() {
        
        self.tblExpandable.tableFooterView = UIView(frame: CGRect.zero)
        
        let substitutionsCellNib = UINib(nibName: "SubstitutionsCell", bundle: Bundle.resource)
        self.tblExpandable.register(substitutionsCellNib, forCellReuseIdentifier:kSubstitutionsCell)
        
        let substitutionsProductCellNib = UINib(nibName: "SubstitutionsProductCell", bundle: Bundle.resource)
        self.tblExpandable.register(substitutionsProductCellNib, forCellReuseIdentifier:kSubstitutionsProductCell)
    }
    
    fileprivate func configureConfirmButtonAppearence(){
        
        self.confirmButton.setTitle(localizedString("ok_button_title", comment: ""), for: UIControl.State())
        self.confirmButton.titleLabel?.font =  UIFont.SFProDisplaySemiBoldFont(12.0)
    }
    
    fileprivate func setConfirmButtonEnabled(_ enabled:Bool) {
        
        self.confirmButton.isEnabled = enabled
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.confirmButton.alpha = enabled ? 1 : 0.3
        })
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let currentCellDescriptor = cellDescriptors[indexPath.row]
        
        if currentCellDescriptor.cellIdentifier == kSubstitutionsProductCell && currentCellDescriptor.isVisible == true {
             return kSubstitutionsProductCellHeight
        }else{
            return kSubstitutionsCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.cellDescriptors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentCellDescriptor = cellDescriptors[indexPath.row]
        
        if currentCellDescriptor.cellIdentifier == kSubstitutionsProductCell && currentCellDescriptor.isVisible == true {
            
            let substitutionsProductCell = tableView.dequeueReusableCell(withIdentifier: kSubstitutionsProductCell, for: indexPath) as! SubstitutionsProductCell
            substitutionsProductCell.configureCellWithOrder(self.order, withParentProduct: currentCellDescriptor.product, andWithProducts: currentCellDescriptor.products)
            substitutionsProductCell.delegate = self
            return substitutionsProductCell
            
        }else{
            
            let substitutionsCell = tableView.dequeueReusableCell(withIdentifier: kSubstitutionsCell, for: indexPath) as! SubstitutionsCell
            substitutionsCell.delegate = self
            
            let product = currentCellDescriptor.product
            let item = shoppingItemForProduct(product!)
            
            substitutionsCell.configureWithProduct(item!, product: product!, order:self.order, currentRow: indexPath.row)
            
            if item?.isSubtituted == 1 || currentCellDescriptor.isExpanded == true{
                substitutionsCell.setSubstitutionButtonSelected(true, isOpen: currentCellDescriptor.isExpanded)
            }else{
                substitutionsCell.setSubstitutionButtonSelected(false, isOpen: false)
            }
            
            return substitutionsCell
        }
    }
    
    //MARK: TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if  let cell = tableView.cellForRow(at: indexPath) as? SubstitutionsCell {
           
            cell.chooseSubtituteButton.isSelected = !cell.chooseSubtituteButton.isSelected
            
            if cell.chooseSubtituteButton.isSelected {
                
                cell.viewBase.shadowOpacity = 0.0
                cell.backgroundColor        = UIColor.white
                
            }else{
                cell.viewBase.shadowOpacity = 0.4
                cell.backgroundColor        = UIColor.clear
            }
            
            let indexOfTappedRow = (indexPath as NSIndexPath).row
            self.showViewForChooseSubtitutionsWithTappedRowIndex(indexOfTappedRow)
            
        }
        
    }
    
    // MARK: Actions
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmButtonHandler(_ sender: Any) {
        let subtitutionBasketVC = ElGrocerViewControllers.substitutionsBasketViewController()
        subtitutionBasketVC.order = self.order
        self.navigationController?.pushViewController(subtitutionBasketVC, animated: true)
    }

    // MARK: Data 
    
    private func setDataInView() {
        
        self.orderItems = ShoppingBasketItem.getBasketItemsForOrder(order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        let subtitutedProducts = OrderSubstitution.getSubtitutedProductsForOrderBasket(order, grocery: nil, context:DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        print("Subtituted Products Count:",subtitutedProducts.count)
        
        for product in subtitutedProducts {
            
            let suggestedProducts = OrderSubstitution.getSuggestedProductsForSubtitutedProductFromOrder(order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            print("Suggested Products Count:",suggestedProducts.count)
            
            let cellDescriptor:CellDescriptor = CellDescriptor.init()
            
            cellDescriptor.isExpandable = true
            cellDescriptor.isExpanded = false
            cellDescriptor.isVisible = true
            cellDescriptor.cellIdentifier = kSubstitutionsCell
            cellDescriptor.product = product
            cellDescriptor.order = order
            
            cellDescriptors.append(cellDescriptor)
        }
        
        self.checkIfAllProductsSubtitutionIsComplete()
//        self.tblExpandable.reloadData()
    }
    
    // MARK: Helpers
    fileprivate func shoppingItemForProduct(_ product:Product) -> ShoppingBasketItem? {
        for item in self.orderItems {
            
            if product.dbID == item.productId {
                return item
            }
        }
        
        return nil
    }
    
    private func checkIfAllProductsSubtitutionIsComplete(){
        
        let subtitutedItems = self.orderItems.filter() { $0.hasSubtitution == true}
        
        var isEnabled = false
        
        for item in subtitutedItems {
            
            if item.isSubtituted > 0{
                isEnabled = true
            }else{
                isEnabled = false
                break
            }
        }
        
        self.setConfirmButtonEnabled(isEnabled)
    }
    
    @objc func reloadData(){
        self.tblExpandable.reloadData()
    }
    
    func showViewForChooseSubtitutionsWithTappedRowIndex(_ indexOfTappedRow:NSInteger){
        
        let currentCellDescriptor = cellDescriptors[indexOfTappedRow]
        
        if currentCellDescriptor.isExpandable == true {
            
            var shouldExpandAndShowSubRows = false
            if currentCellDescriptor.isExpanded == false {
                // In this case the cell should expand.
                shouldExpandAndShowSubRows = true
            }
            
            currentCellDescriptor.isExpanded = shouldExpandAndShowSubRows
            let reloadIndexPath = IndexPath(row: indexOfTappedRow + 1, section: 0)
            
            if shouldExpandAndShowSubRows == false {
                //azeem come here
//                let product = currentCellDescriptor.product
//                let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                
                cellDescriptors.remove(at: indexOfTappedRow + 1)
                tblExpandable.deleteRows(at: [reloadIndexPath], with: UITableView.RowAnimation.fade)
                
            }else{
                
                let product = currentCellDescriptor.product
                
                let suggestedProducts = OrderSubstitution.getSuggestedProductsForSubtitutedProductFromOrder(self.order, product: product!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                
                print("Suggested Products Count:",suggestedProducts.count)
                
                let cellDescriptor:CellDescriptor = CellDescriptor.init()
                
                cellDescriptor.isExpandable = false
                cellDescriptor.isExpanded = false
                cellDescriptor.isVisible = shouldExpandAndShowSubRows
                cellDescriptor.cellIdentifier = kSubstitutionsProductCell
                
                cellDescriptor.product = product
                cellDescriptor.order = self.order
                
                cellDescriptor.products = suggestedProducts
                
                cellDescriptors.insert(cellDescriptor, at: indexOfTappedRow + 1)
                self.tblExpandable.insertRows(at: [reloadIndexPath], with:  UITableView.RowAnimation.fade)
                self.tblExpandable.scrollToRow(at: reloadIndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
            }
            
            self.perform(#selector(self.reloadData), with: nil, afterDelay: 0.5)
        }
    }
    
    func updateServerAboutSubstitution(){
        
        let orderId = String(describing: self.order.dbID)
        
        ElGrocerApi.sharedInstance.orderSubstitutionNotification(orderId, completionHandler: { (result) -> Void in
            
            switch result {
            case .success(_):
                print("Successfully update about Substitution")
                
            case .failure(let error):
                print("Error:%@",error.localizedMessage)
            }
        })
    }
}


extension SubstitutionsViewController: SubstitutionsCellProtocol {
    
    
//    func removeProductToBasketFromQuickRemove(_ product: Product) {
//        
//        var productQuantity = 0
//        
//        // If the product already is in the basket, just increment its quantity by 1
//        if let product = SubstitutionBasketItem.checkIfProductIsInSubstitutionBasket(product, grocery: self.grocery, order: self.order, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
//            productQuantity = product.count.intValue - 1
//        }
//        
//        if productQuantity < 0 {return}
//        
//        if productQuantity == 0 {
//            
//            //remove product from substitution basket
//            SubstitutionBasketItem.removeProductFromSubstitutionBasket(product, grocery: self.grocery, order: self.order, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
//            
//            let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: self.subtituteProduct, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
//            
//            basketItem!.isSubtituted = 0
//            
//        } else {
//            
//            //Add or update item in basket
//            SubstitutionBasketItem.addOrUpdateProductInSubstitutionBasket(product, subtitutedProduct: self.subtituteProduct, grocery: self.grocery, order: self.order, quantity: productQuantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
//        }
//        
//        DatabaseHelper.sharedInstance.saveDatabase()
//    
//    }
//    
//    
    
    
    func chooseSubtituteWithProductIndex(_ index:NSInteger){
        
        let indexOfTappedRow = index
        self.showViewForChooseSubtitutionsWithTappedRowIndex(indexOfTappedRow)
    }
    
    func discardSubtituteWithProductIndex(_ index:NSInteger){
        
        let indexOfTappedRow = index
        
        let currentCellDescriptor = cellDescriptors[indexOfTappedRow]
        let product = currentCellDescriptor.product
        
        /* ---------- Here we are clearing suggested product for that subtituted product ---------- */
        SubstitutionBasketItem.clearAvailableSuggestionsForSubtitutedProduct(self.order, subtitutedProduct: product!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        /* ---------- Here we are setting subtituted status for that product ---------- */
        let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: product!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        //basketItem!.isSubtituted = basketItem!.isSubtituted != 0 ? 0 : 2
        if basketItem?.isSubtituted == 2  {
            basketItem!.isSubtituted = 0
        }else{
            basketItem!.isSubtituted = 2
        }
        DatabaseHelper.sharedInstance.saveDatabase()
        
        var delayTime = 0.1
        
        if currentCellDescriptor.isExpanded == true {
            // In this case the cell is already expanded so we are unexpanded it here.
            currentCellDescriptor.isExpanded = false
            cellDescriptors.remove(at: indexOfTappedRow + 1)
            let reloadIndexPath = IndexPath(row: indexOfTappedRow + 1, section: 0)
            self.tblExpandable.deleteRows(at: [reloadIndexPath], with: UITableView.RowAnimation.fade)
            
            delayTime = 0.5
        }
        
        self.perform(#selector(self.reloadData), with: nil, afterDelay: delayTime)
        
        self.checkIfAllProductsSubtitutionIsComplete()
    }
}


extension SubstitutionsViewController: SubstitutionsProductCellProtocol {
    
    func checkForProductsSubtitutionCompletion(){
        self.checkIfAllProductsSubtitutionIsComplete()
        self.reloadData()
    }
}
