//
//  ExclusiveDealsBottomSheet.swift
//  Adyen
//
//  Created by ELGROCER-STAFF on 26/03/2024.
//

import UIKit

class ExclusiveDealsBottomSheet: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headingLabel: UILabel!{
        didSet{
            headingLabel.text = localizedString("lbl_title_exclusive_deals", comment: "")
            headingLabel.setH3SemiBoldDarkStyle()
        }
    }
    
    typealias tapped = (_ promo: ExclusiveDealsPromoCode?, _ grocery: Grocery?)-> Void
    var promoTapped: tapped?
    var delegate: CopyAndShopDelegate?
    var promoA: [ExclusiveDealsPromoCode] = []
    var groceryA: [Grocery] = []
    
    
    @IBAction func crossTapped(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
     func copyAndShopTapped(promo: ExclusiveDealsPromoCode, grocery: Grocery){
         if let promoTapped = self.promoTapped {
             promoTapped(promo,grocery)
         }
//        self.dismiss(animated: false){
//        }
    }
}
extension ExclusiveDealsBottomSheet: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.promoA.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ExclusiveDealBottomSheetTableViewCell", for: indexPath) as! ExclusiveDealBottomSheetTableViewCell
        
        let promoCode = promoA[indexPath.row]
        let grocery = self.groceryA.first { Grocery in
            return (Int(Grocery.getCleanGroceryID()) ?? 0) == (promoCode.retailer_id ?? 0)
        }
        cell.configure(promoCode: promoCode, grocery: grocery)
        cell.promoTapped = {[weak self] promo, grocery in
            
            if let promo = promo , let grocery = grocery {
                self?.copyAndShopTapped(promo: promo, grocery: grocery)
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ExclusiveDealBottomSheetTableViewCell {
            DispatchQueue.main.async { [weak cell] in
                cell?.voucherBgView.addDashedBorderAroundView(color: ApplicationTheme.currentTheme.themeBasePrimaryBlackColor)
            }
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
