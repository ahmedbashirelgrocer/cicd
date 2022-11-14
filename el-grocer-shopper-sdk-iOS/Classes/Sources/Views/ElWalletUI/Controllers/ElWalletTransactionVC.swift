//
//  ElWalletTransactionVC.swift
//  ElGrocerShopper
//
//  Created by Salman on 09/05/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class ElWalletTransactionVC: UIViewController, NavigationBarProtocol {

    @IBOutlet weak var elwalletHeadingLabel: UILabel! {
        didSet {
            elwalletHeadingLabel.text = localizedString("txt_elwallet_balance", comment: "")
        }
    }
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.showsVerticalScrollIndicator = false
        }
    }
    
    var allMOonthTransections : [(sectionDate: String, transactions: [Transaction])] = []
    var allTransection: [Transaction] = [Transaction]()
    var balance: Double?
    let limmit: Int = 10
    var offset: Int = 0
    var isGettingTransection: Bool = false
    var isFirstTime: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setInitialAppearence()
    }
    
    private func setInitialAppearence() {
        
        self.setupNavigationAppearence()
        self.registerCellsForTableView()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
        callGetAllTransection()
    }
    func callGetAllTransection() {
        self.offset = self.allTransection.count
        guard !isGettingTransection else {return}
        guard self.allTransection.count % 10 == 0 || self.allTransection.count == 0 else{
            return
        }
        isGettingTransection = true
        if isFirstTime {
            let _ = SpinnerView.showSpinnerViewInView(self.view)
        }
        self.getAllTransections(offset: self.allTransection.count)
    }
    
    func setupNavigationAppearence() {
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        //self.addBackButton()
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.barTintColor = .navigationBarWhiteColor()
        self.title = localizedString("txt_title_transaction_history", comment: "")
        
        self.balanceLabel.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: balance ?? 0.0)
        
    }
    func filterTransectionInArray(transectionArray: [Transaction]) {
        var section = 0
        for transaction in transectionArray {
            let date = transaction.createdAt?.convertStringToCurrentTimeZoneDate()
            let month = date?.monthName(.short) ?? ""
            let year = date?.year ?? 0000
            let newMonthYear = month + " \(year)"
            if allMOonthTransections.count == 0 {
                allMOonthTransections.append((newMonthYear, [transaction] ))
            }else {
                if allMOonthTransections.last?.sectionDate == newMonthYear {
                    allMOonthTransections[section].transactions.append(transaction)
                } else {
                    section += 1
                    allMOonthTransections.append((newMonthYear, [transaction] ))
                }
            }
        }
        self.tableView.reloadDataOnMain()
    }
    
    private func registerCellsForTableView() {
        
        self.tableView.register(elWalletSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: elWalletSectionHeaderView.reuseId)
        
        self.tableView.register(elWalletSectionFooterView.nib, forHeaderFooterViewReuseIdentifier: elWalletSectionFooterView.reuseId)
        
        self.tableView.register(TransactionsCell.nib, forCellReuseIdentifier: TransactionsCell.reuseId)
        self.tableView.register(EmptyTransactionsCell.nib, forCellReuseIdentifier: EmptyTransactionsCell.reuseId)
    }
    
    override func backButtonClick() {
        guard let navCount = self.navigationController else {
            self.navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        if  navCount.viewControllers.count == 1 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }else{
             self.navigationController?.popViewController(animated: true)
        }
    }
    
    func backButtonClickedHandler() {
        backButtonClick()
    }
    
    
    fileprivate func getTransactionsCell(_ tableView: UITableView, indexPath: IndexPath) -> TransactionsCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionsCell.reuseId, for: indexPath) as! TransactionsCell
        if (allMOonthTransections[indexPath.section].transactions[indexPath.row]) != nil {
            cell.configure(allMOonthTransections[indexPath.section].transactions[indexPath.row])
            if indexPath.row == allMOonthTransections[indexPath.section].transactions.count - 1 {
                cell.lineView.isHidden = true
            }
            
        }
        
        return cell
    }
    
    fileprivate func getEmptyTransactionsCell(_ tableView: UITableView, indexPath: IndexPath) -> EmptyTransactionsCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTransactionsCell.reuseId, for: indexPath) as! EmptyTransactionsCell
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ElWalletTransactionVC {
    //api handling
    func getAllTransections(offset: Int) {
        ElWalletNetworkManager.sharedInstance().getTransactions(limmit: limmit, offset: offset) { result in
            SpinnerView.hideSpinnerView()
            switch (result) {
                case .success(let response):
                    debugPrint(response)
                if response["data"] != nil {
                    self.isGettingTransection = false
                    self.isFirstTime = false
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
                        let transactionData = try TransactionRecord.init(data: jsonData)
                        print(transactionData)
                        self.allTransection.append(contentsOf: transactionData.transactionHistory)
                        self.filterTransectionInArray(transectionArray: transactionData.transactionHistory)
                    } catch (let error){
                        print(error)
                    }
                }
                case .failure(let error):
                    debugPrint(error.localizedMessage)
            }
        }
        
    }
}

extension ElWalletTransactionVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let kLoadingDistance = 2 * kProductCellHeight + 8
        let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
        if y + kLoadingDistance > scrollView.contentSize.height && self.isGettingTransection == false {
            debugPrint("getlist")
            self.callGetAllTransection()
        }
    }
}

extension ElWalletTransactionVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.allMOonthTransections.count == 0 ? 1 : allMOonthTransections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allMOonthTransections.count > 0 {
            return allMOonthTransections[section].transactions.count == 0 ? 0 : allMOonthTransections[section].transactions.count
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if allMOonthTransections.count > 0 {
            return getTransactionsCell(tableView, indexPath: indexPath)
        } else {
            return getEmptyTransactionsCell(tableView, indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.allMOonthTransections.count > 0 {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "elWalletSectionHeaderView") as! elWalletSectionHeaderView
            headerView.configureHeaderView(title: allMOonthTransections[section].sectionDate, buttonName: "")
            headerView.moveToDetailsButton.isHidden = true
            return headerView
        }else{
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "elWalletSectionHeaderView") as! elWalletSectionHeaderView
            headerView.configureHeaderView(title: localizedString("txt_title_transaction_history", comment: ""), buttonName: "")
            headerView.moveToDetailsButton.isHidden = true
            return headerView
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "elWalletSectionFooterView") as! elWalletSectionFooterView
        //footerView.footerLabel.text = "TableView Footer \(section)"
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    /*
     func tableView(_ tableView: UITableView,
                    heightForHeaderInSection section: Int) -> CGFloat {
         return UITableView.automaticDimension
     }

     func tableView(_ tableView: UITableView,
                    estimatedHeightForHeaderInSection section: Int) -> CGFloat {
         return 50.0
     }
     */
}
