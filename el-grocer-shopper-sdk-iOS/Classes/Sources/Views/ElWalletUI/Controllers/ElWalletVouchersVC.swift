//
//  ElWalletVouchersVC.swift
//  ElGrocerShopper
//
//  Created by Salman on 09/05/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class ElWalletVouchersVC: UIViewController, NavigationBarProtocol {

    @IBOutlet var lblDoYouHaveVoucher: UILabel! {
        didSet {
            lblDoYouHaveVoucher.text = localizedString("txt_do_you_have_voucher", comment: "")
        }
    }
    @IBOutlet var txtVoucherCode: UITextField! {
        didSet {
            txtVoucherCode.setPlaceHolder(text: localizedString("txt_voucher_code", comment: ""))
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                txtVoucherCode.textAlignment = .right
            }
        }
    }
    @IBOutlet var btnRedeem: UIButton! {
        didSet {
            btnRedeem.setTitle(localizedString("txt_redeem_capital", comment: ""), for: UIControl.State())
        }
    }
    @IBOutlet weak var vouchersTableView: UITableView!
    
    var viewModel = ElWalletHomeViewModel()
    var voucherData: VoucherRecord?
    var allVouchers: [Voucher] = [Voucher]()
    let limmit: Int = 10
    var offset: Int = 0
    var isGettingTransection: Bool = false
    var isFirstTime: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.registerCellsForTableView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setInitialAppearence()
        self.callGetAllVouchers()
    }
    
    private func setInitialAppearence() {
        
        self.setupNavigationAppearence()
        self.vouchersTableView.rowHeight = UITableView.automaticDimension
        self.vouchersTableView.estimatedRowHeight = 60
    }
    
    func setupNavigationAppearence() {
        self.navigationController?.navigationBar.isHidden = false
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        //self.addBackButton()
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.barTintColor = .navigationBarWhiteColor()
        self.title = localizedString("txt_active_vouchers_small", comment: "")
        
    }
    
    private func registerCellsForTableView() {
        
        vouchersTableView.estimatedRowHeight = UITableView.automaticDimension
        vouchersTableView.rowHeight = UITableView.automaticDimension
        self.vouchersTableView.register(elWalletSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: elWalletSectionHeaderView.reuseId)

        self.vouchersTableView.register(elWalletSectionFooterView.nib, forHeaderFooterViewReuseIdentifier: elWalletSectionFooterView.reuseId)

        self.vouchersTableView.register(VouchersCell.nib, forCellReuseIdentifier: VouchersCell.reuseId)
        self.vouchersTableView.register(EmptyVouchersCell.nib, forCellReuseIdentifier: EmptyVouchersCell.reuseId)
    }
    
    @IBAction func btnRedeemHandler(_ sender: Any) {
        if self.txtVoucherCode.text != "" {
            MixpanelEventLogger.trackElwalletActiveVoucherManualInPutRedeemClicked(code: txtVoucherCode.text ?? "")
            let _ = SpinnerView.showSpinnerView()
            self.viewModel.redeemVoucherWith(code: txtVoucherCode.text ?? "") { error, response in
                SpinnerView.hideSpinnerView()
                if error == nil {
                    if let valueInCents = (response?["data"] as? NSDictionary)?["value_cents"] as? NSNumber {
                        let value: Int = valueInCents.intValue / 100
                        self.navigateToSuccessVC(voucher:self.txtVoucherCode.text ?? "", isSuccess: true, voucherValue: String(value))
                    }else {
                        self.navigateToSuccessVC(voucher: self.txtVoucherCode.text ?? "", isSuccess: false, voucherValue: "")
                    }
                } else {
                    print("something wrong ho gaya")
                    MixpanelEventLogger.trackElwalletActiveVoucherVoucherRedeemError()
                    self.navigateToSuccessVC(voucher: self.txtVoucherCode.text ?? "", isSuccess: false, voucherValue: "")
                }
            }
        }
    }
    override func backButtonClick() {
        MixpanelEventLogger.trackElWalletUnifiedClose()
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
    func navigateToSuccessVC(voucher: String, isSuccess: Bool, voucherValue: String) {
        let vc = ElGrocerViewControllers.getPaymentSuccessVC()
        vc.controlerType = .voucher
        vc.isSuccess = isSuccess
        vc.voucher = voucher
        vc.voucherValue = voucherValue
        vc.ispushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func getVouchersCell(_ tableView: UITableView, indexPath: IndexPath) -> VouchersCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VouchersCell.reuseId, for: indexPath) as! VouchersCell
        cell.configure(allVouchers[indexPath.row])
        cell.viewDetailButton.tag = indexPath.row
        cell.redeemButton.tag = indexPath.row
        cell.showVoucherDetails = {
            self.vouchersTableView.beginUpdates()
            let objIndex = cell.viewDetailButton.tag
            let indexpath = IndexPath(row: cell.viewDetailButton.tag, section: 0)
            self.allVouchers[objIndex].showDetails = !self.allVouchers[objIndex].showDetails
            self.vouchersTableView.reloadRows(at: [indexpath], with: .automatic)
            self.vouchersTableView.endUpdates()
        }
        cell.redeemVoucher = { [weak self](voucher) in
            let _ = SpinnerView.showSpinnerView()
            MixpanelEventLogger.trackElwalletActiveVoucherInsideCardRedeemClicked(voucherId: String(voucher.id), voucherCode: voucher.code ?? "")
            self?.viewModel.redeemVoucherWith(code: voucher.code ?? "") { error, response in
                SpinnerView.hideSpinnerView()
                if error == nil {
                    if let valueInCents = (response?["data"] as? NSDictionary)?["value_cents"] as? NSNumber {
                        let value: Int = valueInCents.intValue / 100
                        self?.navigateToSuccessVC(voucher: voucher.code ?? "", isSuccess: true, voucherValue: String(value))
                    }else {
                        self?.navigateToSuccessVC(voucher: voucher.code ?? "", isSuccess: false, voucherValue: "")
                    }
                } else {
                    print("something wrong ho gaya")
                    MixpanelEventLogger.trackElwalletActiveVoucherVoucherRedeemError()
                    self?.navigateToSuccessVC(voucher: voucher.code ?? "", isSuccess: false, voucherValue: "")
                }
            }

        }
        return cell
    }
    
    fileprivate func getEmptyVouchersCell(_ tableView: UITableView, indexPath: IndexPath) -> EmptyVouchersCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EmptyVouchersCell.reuseId, for: indexPath) as! EmptyVouchersCell
        return cell
    }
    
    //MARK: API calling
    func callGetAllVouchers() {
        self.offset = self.allVouchers.count
        guard !isGettingTransection else {return}
        guard self.allVouchers.count % 10 == 0 || self.allVouchers.count == 0 else{
            return
        }
        isGettingTransection = true
        if isFirstTime {
           let _ = SpinnerView.showSpinnerViewInView(self.view)
        }
        self.getAllVouchers(offset: self.allVouchers.count)
    }


}

extension ElWalletVouchersVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allVouchers.count == 0 ? 1 : allVouchers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if allVouchers.count>0 {
            return getVouchersCell(tableView, indexPath: indexPath)
        } else {
            return getEmptyVouchersCell(tableView, indexPath: indexPath)
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "elWalletSectionHeaderView") as! elWalletSectionHeaderView
        headerView.configureHeaderView(title: localizedString("txt_active_vouchers", comment: ""), buttonName: "")
        headerView.moveToDetailsButton.isHidden = true
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "elWalletSectionFooterView") as! elWalletSectionFooterView
        //footerView.footerLabel.text = "TableView Footer \(section)"
        return footerView
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? VouchersCell {
            MixpanelEventLogger.trackElwalletActiveVoucherView(id: String(cell.voucher?.id ?? -1), code: cell.voucher?.code ?? "")
            DispatchQueue.main.async { [weak cell] in
                cell?.voucherCodeBorderView.addDashedBorderAroundView(color: ApplicationTheme.currentTheme.themeBaseSecondaryDarkColor)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension ElWalletVouchersVC {
    //api handling
    func getAllVouchers(offset: Int) {
        ElWalletNetworkManager.sharedInstance().getVouchers(limmit: limmit, offset: offset) { result in
            SpinnerView.hideSpinnerView()
            switch (result) {
                case .success(let response):
                    debugPrint(response)
                if let data = response["data"] as? NSDictionary {
                    self.isGettingTransection = false
                    self.isFirstTime = false
                    
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                        let transactionData = try VoucherRecord.init(data: jsonData)
                        print(transactionData)
                        self.allVouchers.append(contentsOf: transactionData.vouchers)
                        self.vouchersTableView.reloadDataOnMain()
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
extension ElWalletVouchersVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let kLoadingDistance = 2 * kProductCellHeight + 8
        let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
        if y + kLoadingDistance > scrollView.contentSize.height && self.isGettingTransection == false {
            debugPrint("getlist")
            self.callGetAllVouchers()
        }
    }
}
