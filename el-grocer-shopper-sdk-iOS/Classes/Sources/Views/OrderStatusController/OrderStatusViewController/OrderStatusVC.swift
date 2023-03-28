//
//  OrderStatusVC.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 15/06/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class OrderStatusVC: UIViewController {

    @IBOutlet var orderStatusTableView: UITableView!{
        didSet{
            statusHeaderView.frame = CGRect(x: 0.5, y: 0.1, width: ScreenSize.SCREEN_WIDTH , height: orderStatusHeaderHeight)
        }
    }
    
    lazy var statusHeaderView : orderStatusHeaderView = {
        let nib = orderStatusHeaderView.loadFromNib()
        return nib!
    }()
    
    var shouldScroll : Bool = false
    var orderType : OrderType = .CandC
    var statusType : OrderStatus = .pending
    var currentHeaderHeight = orderStatusHeaderMinHeight
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addImageHeader()
        RegisterCell()
        self.orderStatusTableView.delegate = self
        self.orderStatusTableView.dataSource = self
    }
    
    func RegisterCell(){
        
        let warningCell = UINib(nibName: "warningAlertCell" , bundle: Bundle.resource)
        self.orderStatusTableView.register(warningCell, forCellReuseIdentifier: "warningAlertCell")
        
        let OrderStatusDetailCell = UINib(nibName: "OrderStatusDetailCell" , bundle: Bundle.resource)
        self.orderStatusTableView.register(OrderStatusDetailCell, forCellReuseIdentifier: "OrderStatusDetailCell")
        
        let CandCLocationCell = UINib(nibName: "CandCLocationCell" , bundle: Bundle.resource)
        self.orderStatusTableView.register(CandCLocationCell, forCellReuseIdentifier: "CandCLocationCell")
        
        let bannerCell = UINib(nibName: KGenericBannersCell , bundle: Bundle.resource)
        self.orderStatusTableView.register(bannerCell, forCellReuseIdentifier: KGenericBannersCell)
        
        
        self.orderStatusTableView.delegate = self
        self.orderStatusTableView.dataSource = self
        self.orderStatusTableView.separatorStyle = .none
        
        
    }
    
    
    func addImageHeader () {
        
        if statusType == .inSubtitution{
            currentHeaderHeight = orderStatusHeaderHeight
        }
        
        statusHeaderView.frame = CGRect(x: 0.5, y: 0, width: ScreenSize.SCREEN_WIDTH , height: currentHeaderHeight)
        statusHeaderView.clipsToBounds = true
        statusHeaderView.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(statusHeaderView)
        //statusHeaderView.registerCell()
        orderStatusTableView.contentInset = UIEdgeInsets(top: currentHeaderHeight + 30 , left: 0, bottom: 0, right: 0)
        self.view.bringSubviewToFront(self.statusHeaderView)
        if currentHeaderHeight == orderStatusHeaderMinHeight{
            statusHeaderView.btnOrderStatus.visibility = .goneY
        }
      //  self.statusHeaderView.loadOrderStatusLabel(status: statusType.rawValue , orderType: orderType)
        
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

extension OrderStatusVC : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if statusHeaderView is orderStatusHeaderView{
            var y = -scrollView.contentOffset.y
            if shouldScroll{
                y = -scrollView.contentOffset.y
                let height = max(y, currentHeaderHeight)
                if height < currentHeaderHeight + 24 {
                    if currentHeaderHeight == orderStatusHeaderHeight{
                        self.statusHeaderView.btnOrderStatus.visibility = .visible
                    }else{
                        self.statusHeaderView.btnOrderStatus.visibility = .goneY
                    }
                    self.statusHeaderView.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: currentHeaderHeight)
                    self.statusHeaderView.bGWidthConstraint.constant = 0
                    self.statusHeaderView.bGTopConstraint.constant = 0
                    self.statusHeaderView.cardBGView.clipsToBounds = true
                    
                }else{
                    self.statusHeaderView.bGWidthConstraint.constant = -32
                    self.statusHeaderView.bGTopConstraint.constant = 16
                    self.statusHeaderView.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH , height: height)
                    self.statusHeaderView.cardBGView.clipsToBounds = false
                    if currentHeaderHeight == orderStatusHeaderHeight{
                        self.statusHeaderView.btnOrderStatus.visibility = .visible
                    }
                    
                }
                
                
                
            }else{
                shouldScroll = true
                y = -scrollView.contentOffset.y
                let height = max(y, currentHeaderHeight)
                scrollView.contentOffset.y = -height
                self.statusHeaderView.bGWidthConstraint.constant = -32
                self.statusHeaderView.bGTopConstraint.constant = 16
                if currentHeaderHeight == orderStatusHeaderMinHeight{
                    self.statusHeaderView.btnOrderStatus.visibility = .visible
                }
                self.statusHeaderView.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH , height: height)
                  
                
            }
        }
        
    }
}
extension OrderStatusVC : UITableViewDelegate , UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if orderType == .delivery{
            return 4
        }
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if orderType == .delivery{
            if section == 3{
                return 30
            }else{
                return CGFloat.leastNormalMagnitude
            }
            
        }else{
            if section == 3{
                return 30
            }else{
                return CGFloat.leastNormalMagnitude
            }
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return nil
//    }
//
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.section == 0{
            return KWarningAlertCellHeight
        }else if indexPath.section == 1{
            return 80
        }else if indexPath.section == 2{
            if orderType == .delivery{
                //return kBannerCellHeight + 10
                return kCandCLocationCellHeight
            }else{
                return kCandCLocationCellHeight
            }
        }else{
            return ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner()
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            if orderType == .delivery{
                if statusType == .pending{
                    return 1
                }
                return 2
            }else{
                if statusType == .pending{
                    return 3
                }else if statusType == .canceled{
                    return 0
                }else{
                    return 2
                }
            }
        }else if section == 1{
            if orderType == .delivery{
                if statusType == .pending || statusType == .accepted{
                    return 2
                }
                return 3
            }else{
                if statusType == .pending || statusType == .canceled{
                    return 4
                }else{
                    return 5
                }
            }
        }
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        //sab
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "warningAlertCell", for: indexPath) as! warningAlertCell
            return cell
            
        }else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderStatusDetailCell", for: indexPath) as! OrderStatusDetailCell
            if orderType == .delivery{
                if indexPath.row == 0{
                    if statusType == .pending || statusType == .accepted || statusType == .canceled{
                        cell.setAppearence(cellType: .orderDetailButton)
                    }else if statusType == .STATUS_CHECKING_OUT || statusType == .STATUS_READY_TO_DELIVER{
                        cell.setAppearence(cellType: .pickrInfoWithoutChat)
                    }else{
                        cell.setAppearence(cellType: .callButton)
                    }
                }else if indexPath.row == 1{
                    if statusType == .pending || statusType == .accepted || statusType == .canceled{
                        cell.setAppearence(cellType: .location)
                    }else{
                        cell.setAppearence(cellType: .orderDetailButton)
                    }
                }else{
                    cell.setAppearence(cellType: .location)
                }
            }else{
                if indexPath.row == 0{
                    if statusType == .pending || statusType == .canceled{
                        cell.setAppearence(cellType: .orderDetailButton)
                    }else{
                        cell.setAppearence(cellType: .pickrInfoWithoutChat)
                    }
                }else if indexPath.row == 1{
                    if statusType == .pending || statusType == .canceled{
                        cell.setAppearence(cellType: .location)
                    }else{
                        cell.setAppearence(cellType: .orderDetailButton)
                    }
                }else if indexPath.row == 2{
                    if statusType == .pending || statusType == .canceled{
                        cell.setAppearence(cellType: .collectorDetails)
                    }else{
                        cell.setAppearence(cellType: .location)
                    }
                   
                }else if indexPath.row == 3{
                    if statusType == .pending || statusType == .canceled{
                        cell.setAppearence(cellType: .carDetails)
                    }else{
                        cell.setAppearence(cellType: .collectorDetails)
                    }
                }else if indexPath.row == 4{
                    if statusType != .pending || statusType != .canceled{
                        cell.setAppearence(cellType: .carDetails)
                    }
                }
            }
            return cell
        }else if indexPath.section == 2{
            if orderType == .delivery{
                
//                let cell = tableView.dequeueReusableCell(withIdentifier: KGenericBannersCell, for: indexPath) as! GenericBannersCell
//                return cell
                let cell = tableView.dequeueReusableCell(withIdentifier: "CandCLocationCell", for: indexPath) as! CandCLocationCell
                return cell
                
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "CandCLocationCell", for: indexPath) as! CandCLocationCell
                return cell
            }
            
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: KGenericBannersCell, for: indexPath) as! GenericBannersCell
       // cell.configured([Banner]())
//        if let campaign = self.currentBanner {
//            cell.configured(campaign)
//        }
//        cell.bannerList.bannerCliked = { [weak self] (bannerLink) in
//            guard let self = self  else {   return   }
//            // self.bannerTapHandlerWithBannerLink(bannerLink)
//        }
        return cell
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}
