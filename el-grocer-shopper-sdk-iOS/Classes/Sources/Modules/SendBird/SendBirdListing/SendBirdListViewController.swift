//
//  SendBirdListViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 20/12/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import SendBirdDesk
import SendBirdSDK
import SendBirdUIKit
import RxCocoa
class SendBirdListViewController: UIViewController, NavigationBarProtocol, UIScrollViewDelegate, NoStoreViewDelegate {
    var openOffset: Int = 0
    var closeOffset: Int = 0
    var ticketList : [SBDSKTicket]? = []
    var closedTicketList : [SBDSKTicket]? = []
    var orderId: String = "0"
    var isApiCalling : Bool = false
    var closeIsApiCalling : Bool = false
    var nextValue : Bool = true
    var closedNextValue : Bool = true
    private let refreshControl = UIRefreshControl()
    private let SBDMainDelegateIdentifier = "UNIQUE_DELEGATE_ID_List"
    var showCloseTickets: Bool = false
    lazy var NoDataView : NoStoreView = {
        let noStoreView = NoStoreView.loadFromNib()
        noStoreView?.delegate = self
        noStoreView?.configureNoTicket()
        return noStoreView!
    }()
    func noDataButtonDelegateClick(_ state: actionState) {
        self.createSupportTicket()
    }
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentControl: UISegmentedControl!{
        didSet {
            segmentControl.layer.cornerRadius = segmentControl.layer.frame.height / 2
            segmentControl.layer.masksToBounds = true
        }
    }
    
    func getCurrentUser() -> UserProfile? {
        
        if UserDefaults.isUserLoggedIn(){
            let user = UserProfile.getOptionalUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            return user
        }else{
            return nil
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = localizedString("ios.ZDKRequests.requestList.title", comment: "")
        self.setSendbirdDelegate()
            // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        refreshControl.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        self.setSegmentApperance()
        self.handleArabicMode()
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        
        // Do any additional setup after loading the view.
    }
    func handleArabicMode() {
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.tableView.semanticContentAttribute = .forceLeftToRight
        }
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        
        refreshTicketData()
    }
    
    func refreshTicketData() {
        if self.showCloseTickets {
            self.closeIsApiCalling = true
            self.closeOffset = 0
            self.closedNextValue = true
            self.getCloseTickets()
        }else {
            self.isApiCalling = true
            self.openOffset = 0
            self.nextValue = true
            self.getOpenTickets()
        }
    }
    
    override func viewWillAppear(_ animated: Bool)  {
        
        Thread.OnMainThread {
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
            self.addBackButton(isGreen: false)
            self.addCreateTicketButton()
            self.refreshTicketData()
            self.tableView.reloadData()
        }
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        guard !isApiCalling else {return}
        self.isApiCalling = true
        self.closeIsApiCalling = true
        self.getOpenTickets()
        self.getCloseTickets()
    }
    
    func setSegmentApperance() {
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white , NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(15) ]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        
        let titleTextAttributesUnselected = [NSAttributedString.Key.foregroundColor: UIColor.newBlackColor() , NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(14)]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributesUnselected, for: .normal)
        
        segmentControl.setTitle(localizedString("lbl_open_ticket", comment: ""), forSegmentAt: 0)
        segmentControl.setTitle(localizedString("lbl_close_ticket", comment: ""), forSegmentAt: 1)
        
    }
    
    @objc override func backButtonClick() {
        SBDMain.removeChannelDelegate(forIdentifier: SBDMainDelegateIdentifier)
        self.dismiss(animated: true)
    }
    
    func backButtonClickedHandler() {
        SBDMain.removeChannelDelegate(forIdentifier: SBDMainDelegateIdentifier)
        self.dismiss(animated: true)
    }
    
    func setSendbirdDelegate () {
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(SBUChannelCell.self, forCellReuseIdentifier: "SBUChannelCell")
        SBDMain.add(self as SBDChannelDelegate, identifier: SBDMainDelegateIdentifier)
        
      
    }
    
    @IBAction func segmentControlActionHandler(_ sender: Any) {
        
        self.showCloseTickets = (self.segmentControl.selectedSegmentIndex == 1)
        self.checkNoDataView()
//        self.tableView.reloadDataOnMain()
    }
    
    func getOpenTickets() {
        
        guard self.nextValue else {return}
        
        if self.openOffset == 0 {
            let _ = SpinnerView.showSpinnerViewInView(self.view)
        }
        
        SBDSKTicket.getOpenedList(withOffset: self.openOffset, customFieldFilter: [:]) { (tickets, hasNext, error) in
            
            
            Thread.OnMainThread {
                self.refreshControl.endRefreshing()
                SpinnerView.hideSpinnerView()
            }
            
          
            guard error == nil else {
                Thread.OnMainThread {
                    error?.showSBDErrorAlert()
                }
                self.isApiCalling  = false
                return
            }
            
            
            
            if self.openOffset == 0 {
                self.ticketList = []
//                self.tableView.reloadDataOnMain()
                self.checkNoDataView()
            }
            
           
            self.nextValue = hasNext
             
            if let list = tickets {
                for tic in list {
                    self.ticketList?.append(tic)
                }
            }
            
            self.ticketList =  self.ticketList?.uniqued()
            
            if hasNext {
                self.openOffset += self.ticketList?.count ?? 0
            }
            
//            self.tableView.reloadDataOnMain()
            self.checkNoDataView()
            self.isApiCalling  = false
        }
        
        
    }
    func getCloseTickets(){
        
        guard self.closedNextValue else {return}
        
        if self.closeOffset == 0 {
            let _ = SpinnerView.showSpinnerViewInView(self.view)
        }
        
        var customFieldFilter = [String: String]()
        
        if let shopperUser = self.getCurrentUser(){
            customFieldFilter = ["shopperid": shopperUser.dbID.stringValue]
//            customFieldFilter["orderid"] = "0"
        }
        
        SBDSKTicket.getClosedList(withOffset: self.closeOffset, customFieldFilter: customFieldFilter) { (tickets, hasNext, error) in
            
            
            Thread.OnMainThread {
                self.refreshControl.endRefreshing()
                SpinnerView.hideSpinnerView()
            }
            
            guard error == nil else {
                Thread.OnMainThread {
                    error?.showSBDErrorAlert()
                }
                self.closeIsApiCalling  = false
                return
            }
            if self.closeOffset == 0 {
                self.closedTicketList = []
                self.tableView.reloadDataOnMain()
            }
            self.closedNextValue = hasNext
             
            if let list = tickets {
                for tic in list {
                    self.closedTicketList?.append(tic)
                }
            }
            
           elDebugPrint("closed Tickets: \(tickets?.count)")
            self.closedTicketList =  self.closedTicketList?.uniqued()
            
            if hasNext {
                self.closeOffset += self.closedTicketList?.count ?? 0
            }
            self.tableView.reloadDataOnMain()
            self.closeIsApiCalling  = false
        }
    }
    
    func openChannelFromTicket(ticket: SBDSKTicket) {
        
        guard let urlData = ticket.channel?.channelUrl else {
            return
        }
        let title = ticket.title
        
        if title?.contains("Order:") ?? false {
            let data : [String] = title?.components(separatedBy: "Order:") ?? []
            if (data.count) > 1 {
                let orderData = data[1] as NSString
                self.orderId = orderData.replacingOccurrences(of: "_shopper", with: "")
                self.orderId = self.orderId.replacingOccurrences(of: " ", with: "")
            }
        }else {
            self.orderId = "0"
        }
        
        Thread.OnMainThread { let _ = SpinnerView.showSpinnerViewInView(self.view) }
        SBDGroupChannel.getWithUrl(urlData) { SBDchannel, error in
            SpinnerView.hideSpinnerView()
            guard let channel = SBDchannel , error == nil else{
                error?.showSBDErrorAlert()
                return
            }
            Thread.OnMainThread {
                let channelController = ElgrocerChannelController(channel: channel)
                channelController.setOrderId(orderDbId: self.orderId)
                channelController.isClosedTicket = self.showCloseTickets
                channelController.shouldPop = true
                channelController.ticket = ticket
                //let naviVC = ElGrocerNavigationController(rootViewController: channelController)
                self.navigationController?.pushViewController(channelController, animated: true)
            }
        }
    }
    
    func checkNoDataView() {
        Thread.OnMainThread {
            if self.showCloseTickets {
                if self.closedTicketList?.count ?? 0 == 0 {
                    self.tableView.backgroundView = self.NoDataView
                }else {
                    self.tableView.backgroundView = UIView()
                }
            }else {
                if self.ticketList?.count ?? 0 == 0 {
                    self.tableView.backgroundView = self.NoDataView
                }else {
                    self.tableView.backgroundView = UIView()
                }
            }
        }
        
        self.tableView.reloadDataOnMain()
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
extension SendBirdListViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.showCloseTickets {
            return closedTicketList?.count ?? 0
        }else {
            return ticketList?.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SBUChannelCell", for: indexPath) as! SBUChannelCell
        
        if showCloseTickets {
            if let channel = closedTicketList?[indexPath.row].channel {
                cell.configure(channel: channel)
                let profileUrl = closedTicketList?[indexPath.row].agent?.profileUrl ?? ""
                cell.coverImage.setImage(withCoverUrl: profileUrl)
            }
        }else {
            if let channel = ticketList?[indexPath.row].channel {
                cell.configure(channel: channel)
                cell.coverImage.setImage(withImage: UIImage(name: "logo-bg")!)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.showCloseTickets {
            if indexPath.row < closedTicketList?.count ?? 0 {
                let ticket = closedTicketList![indexPath.row]
                self.openChannelFromTicket(ticket: ticket)
            }
        }else {
            if indexPath.row < ticketList?.count ?? 0 {
                let ticket = ticketList![indexPath.row]
                self.openChannelFromTicket(ticket: ticket)
            }
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
    
        if maximumOffset - currentOffset <= 70.0 {
            if self.showCloseTickets {
                guard !closeIsApiCalling else {return}
                self.closeIsApiCalling = true
                self.getCloseTickets()
            }else {
                guard !isApiCalling else {return}
                self.isApiCalling = true
                self.getOpenTickets()
            }
            
        }
    }
    
    
}
extension SendBirdListViewController {
    func addCreateTicketButton() {
        
        var image: UIImage! = UIImage(name: "addIconWhite")
        if #available(iOS 13.0, *) {
            image = image.withTintColor(ApplicationTheme.currentTheme.newBlackColor)
        } else { }
        let menuButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        
        let size = self.navigationController?.navigationBar.frame.size.height
        if let height = size {
            let width = image.size.width + 25
            menuButton.frame = CGRect(x: 0, y: 0, width: width, height: height)
        }
        menuButton.setImage(image, for: UIControl.State())
        menuButton.setImage(image, for: UIControl.State.highlighted)
        menuButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        menuButton.addTarget(self, action: #selector(SendBirdListViewController.createSupportTicket), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuButton)
    }
    
    @objc func createSupportTicket() {
        if let user = SBDMain.getCurrentUser() {
            let deskManager = SendBirdDeskManager(controller: self, orderId: "0", type: .agentSupport)
            deskManager.logIn(isWithChat: false) {
                deskManager.getOpenedTicket { (isFound , openticket, ticketsCount) in
                    
                    if isFound, let ticketUrl = openticket?.channel?.channelUrl {
                        deskManager.callSendBirdChat(orderId: "0", controller: self, channelUrl: ticketUrl)
                    }else {
                        deskManager.createTicketWithCustomParams(orderId: "0", user: user.nickname!, controller: self)
                    }
                }
            }
        }
    }
}

extension SendBirdListViewController : SBDConnectionDelegate, SBDUserEventDelegate, SBDChannelDelegate {
    
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
      //  elDebugPrint("\(sender.unrea)")
        
        if UIApplication.shared.applicationState == .active {
            self.tableView.reloadData()
        }
        
    }
    
    func channel(_ sender: SBDBaseChannel, didUpdate message: SBDBaseMessage) {
        elDebugPrint("")
    }
    
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        elDebugPrint("")
    }
    
    func channel(_ channel: SBDBaseChannel, didReceiveMention message: SBDBaseMessage) {
        elDebugPrint("")
    }
    
    func channelWasChanged(_ sender: SBDBaseChannel) {
        elDebugPrint("")
    }
    
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        elDebugPrint("")
    }
    
    func channelWasFrozen(_ sender: SBDBaseChannel) {
        elDebugPrint("")
    }
    
    func channelWasUnfrozen(_ sender: SBDBaseChannel) {
        elDebugPrint("")
    }
    
    func channel(_ sender: SBDBaseChannel, createdMetaData: [String : String]?) {
        elDebugPrint("")
    }
    
    func channel(_ sender: SBDBaseChannel, updatedMetaData: [String : String]?) {
        elDebugPrint("")
    }
    
    func channel(_ sender: SBDBaseChannel, deletedMetaDataKeys: [String]?) {
        elDebugPrint("")
    }
    
    func channel(_ sender: SBDBaseChannel, createdMetaCounters: [String : NSNumber]?) {
        elDebugPrint("")
    }
    
    func channel(_ sender: SBDBaseChannel, updatedMetaCounters: [String : NSNumber]?) {
        elDebugPrint("")
    }
    
    func channel(_ sender: SBDBaseChannel, deletedMetaCountersKeys: [String]?) {
        elDebugPrint("")
    }
    
    func channelWasHidden(_ sender: SBDGroupChannel) {
        elDebugPrint("")
    }
    
    func channel(_ sender: SBDGroupChannel, didReceiveInvitation invitees: [SBDUser]?, inviter: SBDUser?) {
    }
    
    func channel(_ sender: SBDGroupChannel, didDeclineInvitation invitee: SBDUser?, inviter: SBDUser?) {
    }
    
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
    }
    
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
    }
    
    func channelDidUpdateDeliveryReceipt(_ sender: SBDGroupChannel) {
    }
    
    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
    }
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        
        elDebugPrint("unreadMentionCount\(sender.unreadMentionCount)")
    }
    
    func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
    }
    
    func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
    }
    
    func channel(_ sender: SBDBaseChannel, userWasMuted user: SBDUser) {
    }
    
    func channel(_ sender: SBDBaseChannel, userWasUnmuted user: SBDUser) {
    }
    
    func channel(_ sender: SBDBaseChannel, userWasBanned user: SBDUser) {
    }
    
    func channel(_ sender: SBDBaseChannel, userWasUnbanned user: SBDUser) {
    }
    
    func channelDidChangeMemberCount(_ channels: [SBDGroupChannel]) {
    }
    
    func channelDidChangeParticipantCount(_ channels: [SBDOpenChannel]) {
    }
    
    
}
