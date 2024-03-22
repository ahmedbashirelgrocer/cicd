//
//  SettingViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 23/02/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

let kMoveToOrdersFromTableViewNotificationKey = "NavigateUserToOrdersFromSetting"
class SettingViewController: UIViewController {
    
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionHeaderModel<Int,String, ReusableTableViewCellViewModelType>>!
    private var viewModel: SettingViewModel!
    private var analyticsEventLogger: AnalyticsEngineType!
    private var navigator: SettingsNavigation!
    private var disposeBag = DisposeBag()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var lblversionNumber: UILabel!
    
    static func make(viewModel: SettingViewModel, analyticsEventLogger: AnalyticsEngineType = SegmentAnalyticsEngine.instance) -> SettingViewController {
        let vc = ElGrocerViewControllers.settingViewController()
        vc.viewModel = viewModel
        vc.analyticsEventLogger = analyticsEventLogger
        vc.navigator = SettingsNavigation(vc)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationCustimzation()
        self.registerTableViewCell()
        self.bindViews()
        self.setVersionNumber()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        self.navigationCustimzation()
    }
    private func registerTableViewCell() {
        
        let userInfoCellNib  = UINib(nibName: "UserInfoCell", bundle: Bundle.resource)
        self.tableView.register(userInfoCellNib, forCellReuseIdentifier: kUserInfoCellIdentifier)
        
        let loginCellNib  = UINib(nibName: "loginCell", bundle: Bundle.resource)
        self.tableView.register(loginCellNib, forCellReuseIdentifier: KloginCellIdentifier)
        
        let settingCellNib = UINib(nibName: "SettingCell", bundle: Bundle.resource)
        self.tableView.register(settingCellNib, forCellReuseIdentifier: kSettingCellIdentifier)
        
        
        let SignOutCellNib = UINib(nibName: "SignOutCell", bundle: Bundle.resource)
        self.tableView.register(SignOutCellNib, forCellReuseIdentifier: kSignOutCellIdentifier)
        
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableView.separatorColor =  AppSetting.theme.separatorColor
        self.tableView.backgroundColor = AppSetting.theme.tableViewBackgroundColor
    }
    
    private func navigationCustimzation() {
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        self.title = localizedString("Profile_Title", comment: "")
        //(self.navigationController as? ElGrocerNavigationController)?.navigationBar.topItem?.title = localizedString("Profile_Title", comment: "")
        self.view.backgroundColor = sdkManager.isShopperApp ? AppSetting.theme.navigationBarWhiteColor :  AppSetting.theme.navigationBarWhiteColor
        self.hidesBottomBarWhenPushed = true
        self.navigationItem.hidesBackButton = true
        
    }
    
    private func setVersionNumber() {
        if let version = PackageInfo.version {
            self.lblversionNumber.text = "v" + " " + version
        } else {
            self.lblversionNumber.text = "----"
        }
    }
    
    private func bindViews() {
        self.tableView.dataSource = nil
        self.dataSource = RxTableViewSectionedReloadDataSource(configureCell: { [self] dataSource, tableView, indexPath, viewModel in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUITableViewCell
            cell.selectionStyle = .none
            cell.configure(viewModel: viewModel)
            return cell
        },titleForHeaderInSection: { dataSource, sectionIndex in
            return dataSource[sectionIndex].header
        })

        self.viewModel.outputs.cellViewModels
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.action
            .subscribe(onNext: { [weak self] type in
                self?.navigator.handleNavigation(with: type)
            }).disposed(by: disposeBag)
    }
    
}

extension SettingViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.outputs.heightForCell(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        headerView.backgroundColor = .tableViewBackgroundColor()
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width - 30, height: 30))
        label.text = dataSource.sectionModels[section].header
        label.setH4SemiBoldStyle()
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataSource.sectionModels[section].header.count > 0 ? 30 : .leastNonzeroMagnitude
    }
    
}

extension SettingViewController: NavigationBarProtocol {
    
    func backButtonClickedHandler() {
        self.backButtonClick()
    }
    
    override func backButtonClick() {
        (self.navigationController as? ElGrocerNavigationController)?.navigationBar.topItem?.title = ""
        self.navigationController?.popViewController(animated: true)
    }
}
